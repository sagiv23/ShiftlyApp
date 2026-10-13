import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shiftly/main.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/models/wage_entry.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/services/persistence_service.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_page_route.dart';

class ShiftProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  final GoogleDriveService _driveService = GoogleDriveService();
  String? _authToken;
  bool _isBYOS = false;
  bool _autoSyncEnabled = true;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Shift>? _cachedShifts;
  List<Shift>? _cachedFilteredShifts;
  List<Expense>? _cachedExpenses;
  List<Expense>? _cachedIncomes;
  List<JobType>? _cachedJobTypes;
  Map<String, List<Shift>>? _cachedShiftsGroupedByMonth;
  Map<String, List<Expense>>? _cachedExpensesGroupedByMonth;
  Map<String, List<Expense>>? _cachedIncomesGroupedByMonth;

  void _invalidateCache() {
    _cachedShifts = null;
    _cachedFilteredShifts = null;
    _cachedExpenses = null;
    _cachedIncomes = null;
    _cachedJobTypes = null;
    _cachedShiftsGroupedByMonth = null;
    _cachedExpensesGroupedByMonth = null;
    _cachedIncomesGroupedByMonth = null;
  }

  ShiftProvider(this._persistence);

  bool _hasSyncedOnStartup = false;
  SettingsProvider? _settingsProvider;

  void updateAuthStatus(
    String? token,
    bool isBYOS,
    bool autoSyncEnabled, {
    SettingsProvider? settingsProvider,
  }) {
    final bool tokenChanged = _authToken != token;
    _authToken = token;
    _isBYOS = isBYOS;
    _autoSyncEnabled = autoSyncEnabled;
    _settingsProvider = settingsProvider;
    _settingsProvider?.updateAuthToken(token);
    _settingsProvider?.setOnAutomaticSettingsChanged(() {
      applyAutomaticExpensesAndIncomesToAllShifts();
    });

    if (token == null) {
      _hasSyncedOnStartup = false;
      _invalidateCache();
      return;
    }

    if (!_isBYOS && (!_hasSyncedOnStartup || tokenChanged)) {
      _hasSyncedOnStartup = true;
      Future.microtask(() => syncWithServer());
    }
  }

  Future<void> applyAutomaticExpensesAndIncomesToAllShifts() async {
    final settings = _settingsProvider;
    if (settings == null) return;

    final shiftsList = _persistence.shiftsBox.values.toList();
    if (shiftsList.isEmpty) return;

    bool changed = false;

    for (var shift in shiftsList) {
      final targetExpenses =
          settings.automaticExpenseEnabled &&
              settings.defaultAutomaticExpenses.isNotEmpty
          ? settings.defaultAutomaticExpenses
                .map(
                  (e) => AutomaticExpense(
                    description: e.description,
                    amount: e.amount,
                  ),
                )
                .toList()
          : null;

      final targetIncomes =
          settings.automaticIncomeEnabled &&
              settings.defaultAutomaticIncomes.isNotEmpty
          ? settings.defaultAutomaticIncomes
                .map(
                  (e) => AutomaticExpense(
                    description: e.description,
                    amount: e.amount,
                  ),
                )
                .toList()
          : null;

      shift.automaticExpenses = targetExpenses;
      shift.automaticIncomes = targetIncomes;
      await shift.save();
      _syncShiftToServer(shift);
      changed = true;
    }

    if (changed) {
      _triggerBackup();
      _invalidateCache();
      notifyListeners();
    }
  }

  DateTime? _lastBackupTime;

  DateTime? get lastBackupTime => _lastBackupTime;

  Future<bool> manualBackup() async {
    return await _performBackup();
  }

  Future<void> _triggerBackup() async {
    if (_autoSyncEnabled) {
      await _performBackup();
    }
  }

  Future<bool> _performBackup() async {
    if (_isBYOS) {
      try {
        final data = {
          'shifts': shifts.map((s) => s.toJson()).toList(),
          'expenses': _persistence.expensesBox.values
              .map((e) => e.toJson())
              .toList(),
          'jobTypes': jobTypes.map((j) => j.toJson()).toList(),
          'settings': {
            'defaultAutomaticExpenses':
                _settingsProvider?.defaultAutomaticExpenses
                    .map((e) => e.toJson())
                    .toList() ??
                [],
            'defaultAutomaticIncomes':
                _settingsProvider?.defaultAutomaticIncomes
                    .map((e) => e.toJson())
                    .toList() ??
                [],
            'automaticExpenseEnabled':
                _settingsProvider?.automaticExpenseEnabled ?? false,
            'automaticIncomeEnabled':
                _settingsProvider?.automaticIncomeEnabled ?? false,
          },
        };
        await _driveService.uploadBackup(data);
        _lastBackupTime = DateTime.now();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Backup failed: $e');
        return false;
      }
    }
    return false;
  }

  Future<Map<String, int>> restoreFromBYOS() async {
    if (!_isBYOS) {
      debugPrint('Restore: Not in BYOS mode.');
      return {'shifts': 0, 'jobs': 0, 'expenses': 0};
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int shiftCount = 0;
    int jobCount = 0;
    int expCount = 0;

    try {
      final data = await _driveService.downloadBackup().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('BYOS download timed out'),
      );
      if (data == null) {
        debugPrint('Restore: No backup data found on Drive.');
        return {'shifts': 0, 'jobs': 0, 'expenses': 0};
      }

      debugPrint('Restore: Data found. Parsing...');

      if (data['settings'] != null && data['settings'] is Map) {
        await _settingsProvider?.updateSettingsFromProfile(
          Map<String, dynamic>.from(data['settings'] as Map),
        );
      }

      if (data['jobTypes'] != null && data['jobTypes'] is List) {
        for (var jobData in data['jobTypes']) {
          try {
            final map = Map<String, dynamic>.from(jobData as Map);
            final job = JobType.fromJson(map);
            await _persistence.jobTypesBox.put(job.id, job);
            jobCount++;
          } catch (e) {
            debugPrint('Restore: Failed to parse job: $e');
          }
        }
      }

      if (data['expenses'] != null && data['expenses'] is List) {
        for (var expData in data['expenses']) {
          try {
            final map = Map<String, dynamic>.from(expData as Map);
            final exp = Expense.fromJson(map);
            await _persistence.expensesBox.put(exp.id, exp);
            expCount++;
          } catch (e) {
            debugPrint('Restore: Failed to parse expense: $e');
          }
        }
      }

      if (data['shifts'] != null && data['shifts'] is List) {
        final shiftsList = data['shifts'] as List;
        debugPrint('Restore: Found ${shiftsList.length} shifts in backup.');
        for (var shiftData in shiftsList) {
          try {
            final map = Map<String, dynamic>.from(shiftData as Map);
            final shift = Shift.fromJson(map);
            await _persistence.shiftsBox.put(shift.id, shift);
            shiftCount++;
          } catch (e) {
            debugPrint('Restore: Failed to parse shift: $e. Data: $shiftData');
          }
        }
      }

      debugPrint('Restore complete. Shifts: $shiftCount, Jobs: $jobCount');
      _lastBackupTime = DateTime.now();
      _invalidateCache();
      return {'shifts': shiftCount, 'jobs': jobCount, 'expenses': expCount};
    } catch (e) {
      debugPrint('Restore from BYOS failed with major error: $e');
      _errorMessage = e.toString();
      return {'shifts': 0, 'jobs': 0, 'expenses': 0};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncWithServer({bool? keepLocal}) async {
    if (_authToken == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get remote data with timeout safety
      final remoteJobTypes = await _apiService
          .getJobTypes(_authToken!)
          .timeout(const Duration(seconds: 12));
      final remoteExpenses = await _apiService
          .getExpenses(_authToken!)
          .timeout(const Duration(seconds: 12));
      final remoteShifts = await _apiService
          .getShifts(_authToken!)
          .timeout(const Duration(seconds: 12));
      try {
        final remoteProfile = await _apiService
            .getProfile(_authToken!)
            .timeout(const Duration(seconds: 8));
        await _settingsProvider?.updateSettingsFromProfile(remoteProfile);
      } catch (e) {
        debugPrint('Failed to sync profile settings during server sync: $e');
      }

      // 2. Handle conflicts if requested
      if (keepLocal == false) {
        await _persistence.shiftsBox.clear();
        await _persistence.jobTypesBox.clear();
        await _persistence.expensesBox.clear();
      }

      // 3. Save remote to local
      for (var jobData in remoteJobTypes) {
        List<WageEntry>? wageHistory;
        final rawWageHistory =
            jobData['wage_history'] ?? jobData['wageHistory'];
        if (rawWageHistory != null && rawWageHistory is List) {
          wageHistory = rawWageHistory
              .map(
                (e) => WageEntry.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        }
        final rateVal = jobData['hourly_rate'] ?? jobData['hourlyRate'];
        final hourlyRate = rateVal != null
            ? double.parse(rateVal.toString())
            : AppConstants.defaultHourlyRate;

        final job = JobType(
          id: jobData['id'].toString(),
          name: jobData['name'].toString(),
          hourlyRate: hourlyRate,
          wageHistory: wageHistory,
        );
        await _persistence.jobTypesBox.put(job.id, job);
      }

      for (var expData in remoteExpenses) {
        final exp = Expense(
          id: expData['id'].toString(),
          date: DateTime.parse(expData['date'].toString()),
          description: expData['description']?.toString() ?? '',
          amount: double.parse((expData['amount'] ?? 0).toString()),
          isIncome: expData['is_income'] == true || expData['isIncome'] == true,
        );
        await _persistence.expensesBox.put(exp.id, exp);
      }

      for (var shiftData in remoteShifts) {
        final shift = Shift.fromJson(
          Map<String, dynamic>.from(shiftData as Map),
        );
        await _persistence.shiftsBox.put(shift.id, shift);
      }

      // 4. Upload local to server via Batch Endpoints
      if (keepLocal != false) {
        await _settingsProvider?.syncSettingsToServer(_authToken!);
        final jobTypeItems = jobTypes
            .map(
              (job) => {
                'id': job.id,
                'name': job.name,
                'hourly_rate': job.hourlyRate,
                'wage_history': job.wageHistory
                    ?.map(
                      (e) => {
                        'startDate': e.startDate.toIso8601String(),
                        'hourlyRate': e.hourlyRate,
                      },
                    )
                    .toList(),
              },
            )
            .toList();
        await _apiService.batchUpsertJobTypes(_authToken!, jobTypeItems);

        final allFinancialItems = [
          ...expenses.map(
            (exp) => {
              'id': exp.id,
              'date': exp.date.toIso8601String().split('T')[0],
              'description': exp.description,
              'amount': exp.amount,
              'is_income': false,
            },
          ),
          ...incomes.map(
            (inc) => {
              'id': inc.id,
              'date': inc.date.toIso8601String().split('T')[0],
              'description': inc.description,
              'amount': inc.amount,
              'is_income': true,
            },
          ),
        ];
        await _apiService.batchUpsertExpenses(_authToken!, allFinancialItems);

        final shiftItems = shifts.map((shift) {
          final job = getJobTypeById(shift.jobTypeId);
          final rate =
              shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 0.0;
          return {
            'id': shift.id,
            'job_type_id': shift.jobTypeId,
            'date': shift.date.toIso8601String().split('T')[0],
            'start_time': shift.startTime.toIso8601String(),
            'end_time': shift.endTime.toIso8601String(),
            'tips': shift.tips,
            'break_type': shift.breakType?.toString().split('.').last,
            'unpaid_break_minutes': shift.unpaidBreakMinutes,
            'hourly_rate': rate,
            'automatic_expenses': shift.automaticExpenses
                ?.map((e) => {'description': e.description, 'amount': e.amount})
                .toList(),
            'automatic_incomes': shift.automaticIncomes
                ?.map((e) => {'description': e.description, 'amount': e.amount})
                .toList(),
            'description': shift.description,
            'total_pay': shift.calculateTotalPay(rate),
          };
        }).toList();
        await _apiService.batchUpsertShifts(_authToken!, shiftItems);
      }

      _invalidateCache();
    } catch (e) {
      if (e.toString().contains('unauthorized')) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          AppPageRoute.fadeScale(
            const AuthScreen(),
            duration: const Duration(milliseconds: 200),
          ),
          (route) => false,
        );
      }
      debugPrint('Sync failed: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateAuthToken(String? token) {
    _authToken = token;
  }

  Future<void> _syncJobTypeToServer(JobType job) async {
    if (_authToken == null) return;
    await _apiService.upsertJobType(_authToken!, {
      'id': job.id,
      'name': job.name,
      'hourly_rate': job.hourlyRate,
      'wage_history': job.wageHistory
          ?.map(
            (e) => {
              'startDate': e.startDate.toIso8601String(),
              'hourlyRate': e.hourlyRate,
            },
          )
          .toList(),
    });
  }

  Future<void> _syncExpenseToServer(Expense expense) async {
    if (_authToken == null) return;
    await _apiService.upsertExpense(_authToken!, {
      'id': expense.id,
      'date': expense.date.toIso8601String().split('T')[0],
      'description': expense.description,
      'amount': expense.amount,
      'is_income': expense.isIncome,
    });
  }

  Future<void> _syncShiftToServer(Shift shift) async {
    if (_authToken == null) return;
    final job = getJobTypeById(shift.jobTypeId);
    final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 0.0;

    await _apiService.upsertShift(_authToken!, {
      'id': shift.id,
      'job_type_id': shift.jobTypeId,
      'date': shift.date.toIso8601String().split('T')[0],
      'start_time': shift.startTime.toIso8601String(),
      'end_time': shift.endTime.toIso8601String(),
      'tips': shift.tips,
      'break_type': shift.breakType?.toString().split('.').last,
      'unpaid_break_minutes': shift.unpaidBreakMinutes,
      'hourly_rate': rate,
      'automatic_expenses': shift.automaticExpenses
          ?.map((e) => {'description': e.description, 'amount': e.amount})
          .toList(),
      'automatic_incomes': shift.automaticIncomes
          ?.map((e) => {'description': e.description, 'amount': e.amount})
          .toList(),
      'description': shift.description,
      'total_pay': shift.calculateTotalPay(rate),
    });
  }

  ShiftFilter? _activeFilter;

  ShiftFilter? get activeFilter => _activeFilter;

  void setFilter(ShiftFilter? filter) {
    _activeFilter = filter;
    _cachedFilteredShifts = null;
    _cachedShiftsGroupedByMonth = null;
    notifyListeners();
  }

  void clearFilter() {
    _activeFilter = null;
    _cachedFilteredShifts = null;
    _cachedShiftsGroupedByMonth = null;
    notifyListeners();
  }

  // Shifts
  List<Shift> get shifts {
    if (_cachedShifts != null) return _cachedShifts!;
    _cachedShifts = _persistence.shiftsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedShifts!;
  }

  List<Shift> findOverlappingShifts({
    required DateTime start,
    required DateTime end,
    String? excludeShiftId,
  }) {
    return shifts
        .where(
          (shift) =>
              shift.id != excludeShiftId &&
              shift.startTime.isBefore(end) &&
              start.isBefore(shift.endTime),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Shift> get filteredShifts {
    if (_cachedFilteredShifts != null) return _cachedFilteredShifts!;

    final allShifts = shifts;
    final ShiftFilter? filter = _activeFilter;
    if (filter == null || !filter.isActive) {
      _cachedFilteredShifts = allShifts;
      return _cachedFilteredShifts!;
    }

    _cachedFilteredShifts = allShifts.where((shift) {
      final job = getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
          job?.getRateForDate(shift.date) ??
          AppConstants.defaultHourlyRate;
      final totalPay = shift.calculateTotalPay(rate);

      if (filter.minWage != null && totalPay < filter.minWage!) return false;
      if (filter.maxWage != null && totalPay > filter.maxWage!) return false;

      if (filter.minTips != null && shift.tips < filter.minTips!) return false;
      if (filter.maxTips != null && shift.tips > filter.maxTips!) return false;

      final expenses = shift.totalAutomaticExpenses;
      if (filter.minExpenses != null && expenses < filter.minExpenses!) {
        return false;
      }
      if (filter.maxExpenses != null && expenses > filter.maxExpenses!) {
        return false;
      }

      final duration = shift.netHours;
      if (filter.minDuration != null && duration < filter.minDuration!) {
        return false;
      }
      if (filter.maxDuration != null && duration > filter.maxDuration!) {
        return false;
      }

      if (filter.startDate != null && shift.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && shift.date.isAfter(filter.endDate!)) {
        return false;
      }

      if (filter.typeIds != null &&
          filter.typeIds!.isNotEmpty &&
          !filter.typeIds!.contains(shift.jobTypeId)) {
        return false;
      }

      return true;
    }).toList();

    return _cachedFilteredShifts!;
  }

  // Expenses
  List<Expense> get expenses {
    if (_cachedExpenses != null) return _cachedExpenses!;
    _cachedExpenses =
        _persistence.expensesBox.values.where((e) => !e.isIncome).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedExpenses!;
  }

  List<Expense> get incomes {
    if (_cachedIncomes != null) return _cachedIncomes!;
    _cachedIncomes =
        _persistence.expensesBox.values.where((e) => e.isIncome).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedIncomes!;
  }

  List<JobType> get jobTypes {
    if (_cachedJobTypes != null) return _cachedJobTypes!;
    _cachedJobTypes = _persistence.jobTypesBox.values.toList();
    return _cachedJobTypes!;
  }

  bool get _remindersEnabled =>
      _persistence.settingsBox.get('shiftRemindersEnabled', defaultValue: true);

  double get _reminderDuration => _persistence.settingsBox.get(
    'shiftReminderDurationHours',
    defaultValue: 4.0,
  );

  Future<void> addShift(Shift shift, {Map<String, String>? l10n}) async {
    await _persistence.shiftsBox.put(shift.id, shift);
    _scheduleReminder(shift, l10n: l10n);
    _syncShiftToServer(shift);
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> updateShift(Shift shift, {Map<String, String>? l10n}) async {
    await shift.save();
    _scheduleReminder(shift, l10n: l10n);
    _syncShiftToServer(shift);
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> deleteShift(String id) async {
    await _persistence.shiftsBox.delete(id);
    NotificationService.cancelNotification(id.hashCode);
    if (_authToken != null) {
      await _apiService.deleteShift(_authToken!, id);
    }
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  void _scheduleReminder(Shift shift, {Map<String, String>? l10n}) {
    if (!_remindersEnabled || l10n == null) return;

    final job = getJobTypeById(shift.jobTypeId);
    NotificationService.scheduleShiftReminder(
      id: shift.id.hashCode,
      shiftName: job?.name ?? 'Shift',
      startTime: shift.startTime,
      reminderDurationHours: _reminderDuration,
      title: l10n['title'] ?? 'Shift Reminder',
      bodyTemplate: l10n['body'] ?? 'Your shift ({name}) starts in {time}!',
      hoursLabel: l10n['hours'] ?? 'hours',
      minutesLabel: l10n['minutes'] ?? 'minutes',
      channelName: l10n['channelName'] ?? 'Shift Reminders',
      channelDescription:
          l10n['channelDesc'] ?? 'Reminders before shift starts',
    );
  }

  void refreshAllReminders(Map<String, String> l10n) {
    for (var shift in shifts) {
      NotificationService.cancelNotification(shift.id.hashCode);
    }

    if (_remindersEnabled) {
      for (var shift in shifts) {
        _scheduleReminder(shift, l10n: l10n);
      }
    }
  }

  // Expense Methods
  Future<void> addExpense(Expense expense) async {
    await _persistence.expensesBox.put(expense.id, expense);
    _syncExpenseToServer(expense);
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    _syncExpenseToServer(expense);
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _persistence.expensesBox.delete(id);
    if (_authToken != null) {
      await _apiService.deleteExpense(_authToken!, id);
    }
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> addJobType(JobType jobType) async {
    await _persistence.jobTypesBox.put(jobType.id, jobType);
    _syncJobTypeToServer(jobType);
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> updateJobType(JobType jobType) async {
    if (jobType.isInBox) {
      await jobType.save();
    } else {
      await _persistence.jobTypesBox.put(jobType.id, jobType);
    }
    _syncJobTypeToServer(jobType);
    _triggerBackup();
    await _resyncShiftRatesForJob(jobType);
    _invalidateCache();
    notifyListeners();
  }

  Future<void> deleteJobType(String id) async {
    await _persistence.jobTypesBox.delete(id);
    if (_authToken != null) {
      await _apiService.deleteJobType(_authToken!, id);
    }
    _triggerBackup();
    _invalidateCache();
    notifyListeners();
  }

  Future<void> _resyncShiftRatesForJob(JobType job) async {
    for (final shift in _persistence.shiftsBox.values) {
      if (shift.jobTypeId != job.id) continue;
      final rate = job.getRateForDate(shift.date);
      if (shift.hourlyRate != rate) {
        shift.hourlyRate = rate;
        await shift.save();
      }
    }
  }

  JobType? getJobTypeById(String id) {
    var job = _persistence.jobTypesBox.get(id);
    if (job != null) return job;
    return jobTypes.firstWhereOrNull((j) => j.id == id);
  }

  Map<String, List<Shift>> get shiftsGroupedByMonth {
    if (_cachedShiftsGroupedByMonth != null) {
      return _cachedShiftsGroupedByMonth!;
    }
    _cachedShiftsGroupedByMonth = groupBy(
      filteredShifts,
      (Shift s) => "${s.date.year}-${s.date.month.toString().padLeft(2, '0')}",
    );
    return _cachedShiftsGroupedByMonth!;
  }

  Map<String, List<Expense>> get expensesGroupedByMonth {
    if (_cachedExpensesGroupedByMonth != null) {
      return _cachedExpensesGroupedByMonth!;
    }
    _cachedExpensesGroupedByMonth = groupBy(
      expenses,
      (Expense e) =>
          "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}",
    );
    return _cachedExpensesGroupedByMonth!;
  }

  Map<String, List<Expense>> get incomesGroupedByMonth {
    if (_cachedIncomesGroupedByMonth != null) {
      return _cachedIncomesGroupedByMonth!;
    }
    _cachedIncomesGroupedByMonth = groupBy(
      incomes,
      (Expense e) =>
          "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}",
    );
    return _cachedIncomesGroupedByMonth!;
  }

  // ── Filter Helpers ────────────────────────────────────────────────
  double get maxCapturedWage {
    if (shifts.isEmpty) return 0;
    return shifts
        .map((s) {
          final job = getJobTypeById(s.jobTypeId);
          final rate =
              s.hourlyRate ??
              job?.getRateForDate(s.date) ??
              AppConstants.defaultHourlyRate;
          return s.calculateTotalPay(rate);
        })
        .reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedTips {
    if (shifts.isEmpty) return 0;
    return shifts.map((s) => s.tips).reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedExpenses {
    if (shifts.isEmpty) return 0;
    return shifts
        .map((s) => s.totalAutomaticExpenses)
        .reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedDuration {
    if (shifts.isEmpty) return 0;
    return shifts.map((s) => s.netHours).reduce((a, b) => a > b ? a : b);
  }

  Future<void> factoryReset() async {
    for (var shift in shifts) {
      NotificationService.cancelNotification(shift.id.hashCode);
    }
    await _persistence.deleteAllData();
    _invalidateCache();
    notifyListeners();
  }
}
