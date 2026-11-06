import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/shift_template.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/persistence_service.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/number_utils.dart';

enum MonthlyProgressMode { month, financialGoal }

class SettingsProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  String? _authToken;
  VoidCallback? _onAutomaticSettingsChanged;

  SettingsProvider(this._persistence) {
    _loadSettings();
  }

  void updateAuthToken(String? token) {
    _authToken = token;
  }

  void setOnAutomaticSettingsChanged(VoidCallback? callback) {
    _onAutomaticSettingsChanged = callback;
  }

  ThemeMode _themeMode = ThemeMode.system;
  double _paidBreakDurationMinutes = 20.0;
  double _unpaidBreakDurationMinutes = 45.0;
  bool _hasCompletedOnboarding = false;
  bool _automaticExpenseEnabled = false;
  List<AutomaticExpense> _defaultAutomaticExpenses = [];
  bool _automaticIncomeEnabled = false;
  List<AutomaticExpense> _defaultAutomaticIncomes = [];
  String _currencySymbol = AppConstants.defaultCurrencySymbol;
  Locale _locale = const Locale('he', 'IL');
  bool _breaksEnabled = true;
  bool _autoSyncEnabled = true;
  String? _cookieConsent;
  OvertimeRules _overtimeRules = const OvertimeRules();
  ShabbatHolidayRules _shabbatHolidayRules = const ShabbatHolidayRules();
  MonthlyProgressMode _monthlyProgressMode = MonthlyProgressMode.month;
  double _monthlyFinancialGoal = 0;
  List<ShiftTemplate> _shiftTemplates = [];

  List<ShiftTemplate> get shiftTemplates => List.unmodifiable(_shiftTemplates);

  ThemeMode get themeMode => _themeMode;

  OvertimeRules get overtimeRules => _overtimeRules;

  ShabbatHolidayRules get shabbatHolidayRules => _shabbatHolidayRules;

  MonthlyProgressMode get monthlyProgressMode => _monthlyProgressMode;

  double get monthlyFinancialGoal => _monthlyFinancialGoal;

  double get paidBreakDurationMinutes => _paidBreakDurationMinutes;

  double get unpaidBreakDurationMinutes => _unpaidBreakDurationMinutes;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  bool get automaticExpenseEnabled => _automaticExpenseEnabled;

  List<AutomaticExpense> get defaultAutomaticExpenses =>
      _defaultAutomaticExpenses;

  bool get automaticIncomeEnabled => _automaticIncomeEnabled;

  List<AutomaticExpense> get defaultAutomaticIncomes =>
      _defaultAutomaticIncomes;

  String get currencySymbol => _currencySymbol;

  Locale get locale => _locale;

  bool get breaksEnabled => _breaksEnabled;

  bool get autoSyncEnabled => _autoSyncEnabled;

  String? get cookieConsent => _cookieConsent;

  bool get isCookieConsentSet => _cookieConsent != null;

  void _loadSettings() {
    final box = _persistence.settingsBox;
    _themeMode = ThemeMode
        .values[box.get('themeMode', defaultValue: ThemeMode.system.index)];
    _paidBreakDurationMinutes = box.get(
      'paidBreakDurationMinutes',
      defaultValue: 20.0,
    );
    _unpaidBreakDurationMinutes = box.get(
      'unpaidBreakDurationMinutes',
      defaultValue: 45.0,
    );
    _hasCompletedOnboarding = box.get(
      'hasCompletedOnboarding',
      defaultValue: false,
    );
    _automaticExpenseEnabled = box.get(
      'automaticExpenseEnabled',
      defaultValue: false,
    );
    _automaticIncomeEnabled = box.get(
      'automaticIncomeEnabled',
      defaultValue: false,
    );
    _currencySymbol = box.get(
        'currencySymbol', defaultValue: AppConstants.defaultCurrencySymbol);
    _breaksEnabled = box.get('breaksEnabled', defaultValue: true);
    _autoSyncEnabled = box.get('autoSyncEnabled', defaultValue: true);
    _cookieConsent = box.get('cookieConsent');
    final storedProgressMode = box.get('monthlyProgressMode');
    _monthlyProgressMode = MonthlyProgressMode.values.firstWhere(
      (mode) => mode.name == storedProgressMode,
      orElse: () => MonthlyProgressMode.month,
    );
    _monthlyFinancialGoal = box.get('monthlyFinancialGoal', defaultValue: 0.0);
    _applyCrashlyticsConsent(_cookieConsent);
    final String? localeCode = box.get('locale');
    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      _locale = const Locale('he', 'IL');
    }

    final List? storedExpenses = box.get('defaultAutomaticExpenses');
    if (storedExpenses != null) {
      _defaultAutomaticExpenses = List<AutomaticExpense>.from(storedExpenses);
    } else {
      _defaultAutomaticExpenses = [];
    }

    final List? storedIncomes = box.get('defaultAutomaticIncomes');
    if (storedIncomes != null) {
      _defaultAutomaticIncomes = List<AutomaticExpense>.from(storedIncomes);
    } else {
      _defaultAutomaticIncomes = [];
    }

    final rawOvertime = box.get('overtimeRules');
    if (rawOvertime != null) {
      try {
        if (rawOvertime is Map) {
          _overtimeRules = OvertimeRules.fromJson(
            Map<String, dynamic>.from(rawOvertime),
          );
        } else if (rawOvertime is String) {
          _overtimeRules = OvertimeRules.fromJson(
            jsonDecode(rawOvertime) as Map<String, dynamic>,
          );
        }
      } catch (e) {
        debugPrint('Failed to parse stored overtime rules: $e');
        _overtimeRules = const OvertimeRules(enabled: true);
      }
    } else {
      _overtimeRules = const OvertimeRules(enabled: true);
      box.put('overtimeRules', _overtimeRules.toJson());
    }

    final rawShabbat = box.get('shabbatHolidayRules');
    if (rawShabbat != null) {
      try {
        if (rawShabbat is Map) {
          _shabbatHolidayRules = ShabbatHolidayRules.fromJson(
            Map<String, dynamic>.from(rawShabbat),
          );
        } else if (rawShabbat is String) {
          _shabbatHolidayRules = ShabbatHolidayRules.fromJson(
            jsonDecode(rawShabbat) as Map<String, dynamic>,
          );
        }
      } catch (e) {
        debugPrint('Failed to parse stored shabbat holiday rules: $e');
        _shabbatHolidayRules = const ShabbatHolidayRules(enabled: true);
      }
    } else {
      _shabbatHolidayRules = const ShabbatHolidayRules(enabled: true);
      box.put('shabbatHolidayRules', _shabbatHolidayRules.toJson());
    }

    final rawTemplates = box.get('shiftTemplates');
    if (rawTemplates != null) {
      try {
        final List list = rawTemplates is String
            ? jsonDecode(rawTemplates)
            : rawTemplates;
        _shiftTemplates = list
            .map(
              (e) =>
              ShiftTemplate.fromJson(Map<String, dynamic>.from(e as Map)),
        )
            .toList();
        _updateDefaultTemplatesForLocale(_locale);
      } catch (e) {
        debugPrint('Failed to parse stored shift templates: $e');
        _seedDefaultShiftTemplates(_locale);
      }
    } else {
      _seedDefaultShiftTemplates(_locale);
    }

    notifyListeners();
  }

  void _seedDefaultShiftTemplates([Locale? locale]) {
    final loc = locale ?? _locale;
    final l = lookupAppLocalizations(loc);

    _shiftTemplates = [
      ShiftTemplate(
        id: 'template_morning',
        name: l.shift_template_morning,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        breakType: BreakType.unpaid,
      ),
      ShiftTemplate(
        id: 'template_evening',
        name: l.shift_template_evening,
        startTime: const TimeOfDay(hour: 16, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
        breakType: BreakType.unpaid,
      ),
      ShiftTemplate(
        id: 'template_night',
        name: l.shift_template_night,
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 8, minute: 0),
        breakType: BreakType.unpaid,
      ),
    ];
    _persistence.settingsBox.put(
      'shiftTemplates',
      _shiftTemplates.map((t) => t.toJson()).toList(),
    );
  }

  void _updateDefaultTemplatesForLocale(Locale locale) {
    final l = lookupAppLocalizations(locale);

    for (int i = 0; i < _shiftTemplates.length; i++) {
      final t = _shiftTemplates[i];
      if (t.id == 'template_morning') {
        _shiftTemplates[i] = t.copyWith(name: l.shift_template_morning);
      } else if (t.id == 'template_evening') {
        _shiftTemplates[i] = t.copyWith(name: l.shift_template_evening);
      } else if (t.id == 'template_night') {
        _shiftTemplates[i] = t.copyWith(name: l.shift_template_night);
      }
    }
    _persistence.settingsBox.put(
      'shiftTemplates',
      _shiftTemplates.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> saveShiftTemplates(List<ShiftTemplate> templates) async {
    _shiftTemplates = List.from(templates);
    await _persistence.settingsBox.put(
      'shiftTemplates',
      _shiftTemplates.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> addShiftTemplate(ShiftTemplate template) async {
    _shiftTemplates.add(template);
    await _persistence.settingsBox.put(
      'shiftTemplates',
      _shiftTemplates.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> updateShiftTemplate(ShiftTemplate template) async {
    final idx = _shiftTemplates.indexWhere((t) => t.id == template.id);
    if (idx != -1) {
      _shiftTemplates[idx] = template;
      await _persistence.settingsBox.put(
        'shiftTemplates',
        _shiftTemplates.map((t) => t.toJson()).toList(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteShiftTemplate(String templateId) async {
    _shiftTemplates.removeWhere((t) => t.id == templateId);
    await _persistence.settingsBox.put(
      'shiftTemplates',
      _shiftTemplates.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> setOvertimeRules(OvertimeRules rules) async {
    final err = rules.validate();
    if (err != null) {
      throw ArgumentError(err);
    }
    _overtimeRules = rules;
    await _persistence.settingsBox.put('overtimeRules', rules.toJson());
    notifyListeners();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> setShabbatHolidayRules(ShabbatHolidayRules rules) async {
    final err = rules.validate();
    if (err != null) {
      throw ArgumentError(err);
    }
    _shabbatHolidayRules = rules;
    await _persistence.settingsBox.put('shabbatHolidayRules', rules.toJson());
    notifyListeners();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> updateSettingsFromProfile(Map<String, dynamic> data) async {
    final box = _persistence.settingsBox;

    final rawExpenses = data['automatic_expenses'] ?? data['automaticExpenses'];
    if (rawExpenses != null) {
      List<dynamic> list = rawExpenses is String
          ? jsonDecode(rawExpenses)
          : rawExpenses;
      _defaultAutomaticExpenses = list
          .map(
            (e) =>
                AutomaticExpense.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      await box.put('defaultAutomaticExpenses', _defaultAutomaticExpenses);
    }

    final rawIncomes = data['automatic_incomes'] ?? data['automaticIncomes'];
    if (rawIncomes != null) {
      List<dynamic> list = rawIncomes is String
          ? jsonDecode(rawIncomes)
          : rawIncomes;
      _defaultAutomaticIncomes = list
          .map(
            (e) =>
                AutomaticExpense.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      await box.put('defaultAutomaticIncomes', _defaultAutomaticIncomes);
    }

    final expEnabled =
        data['automatic_expense_enabled'] ?? data['automaticExpenseEnabled'];
    if (expEnabled != null) {
      _automaticExpenseEnabled =
          expEnabled == true || expEnabled.toString() == 'true';
      await box.put('automaticExpenseEnabled', _automaticExpenseEnabled);
    }

    final incEnabled =
        data['automatic_income_enabled'] ?? data['automaticIncomeEnabled'];
    if (incEnabled != null) {
      _automaticIncomeEnabled =
          incEnabled == true || incEnabled.toString() == 'true';
      await box.put('automaticIncomeEnabled', _automaticIncomeEnabled);
    }

    await syncAutomaticItemsFromServer();

    notifyListeners();
  }

  Future<void> syncAutomaticItemsFromServer([String? customToken]) async {
    final token = customToken ?? _authToken;
    if (token == null || token.isEmpty) return;
    try {
      final items = await _apiService.getAutomaticItems(token);
      if (items.isNotEmpty) {
        List<AutomaticExpense> exps = [];
        List<AutomaticExpense> incs = [];
        bool expEnabled = _automaticExpenseEnabled;
        bool incEnabled = _automaticIncomeEnabled;

        for (var item in items) {
          final desc = item['description']?.toString() ?? '';
          final amount = NumberUtils.parseDouble(item['amount']);
          final isIncome = NumberUtils.parseBool(
            item['is_income'] ?? item['isIncome'],
          );
          final enabled = NumberUtils.parseBool(
            item['is_enabled'] ?? item['isEnabled'],
          );

          final ae = AutomaticExpense(description: desc, amount: amount);
          if (isIncome) {
            incs.add(ae);
            if (enabled) incEnabled = true;
          } else {
            exps.add(ae);
            if (enabled) expEnabled = true;
          }
        }

        _defaultAutomaticExpenses = exps;
        _defaultAutomaticIncomes = incs;
        _automaticExpenseEnabled = expEnabled;
        _automaticIncomeEnabled = incEnabled;

        final box = _persistence.settingsBox;
        await box.put('defaultAutomaticExpenses', exps);
        await box.put('defaultAutomaticIncomes', incs);
        await box.put('automaticExpenseEnabled', expEnabled);
        await box.put('automaticIncomeEnabled', incEnabled);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to sync automatic items from server: $e');
    }
  }

  Future<void> syncSettingsToServer([String? customToken]) async {
    final token = customToken ?? _authToken;
    if (token == null || token.isEmpty) return;
    try {
      await _apiService.updateUserSettings(
        token,
        automaticExpenses: _defaultAutomaticExpenses
            .map((e) => e.toJson())
            .toList(),
        automaticIncomes: _defaultAutomaticIncomes
            .map((e) => e.toJson())
            .toList(),
        automaticExpenseEnabled: _automaticExpenseEnabled,
        automaticIncomeEnabled: _automaticIncomeEnabled,
      );

      final List<Map<String, dynamic>> autoItems = [
        ..._defaultAutomaticExpenses.map(
          (e) => {
            'id': 'exp_${e.description}',
            'description': e.description,
            'amount': e.amount,
            'is_income': false,
            'is_enabled': _automaticExpenseEnabled,
          },
        ),
        ..._defaultAutomaticIncomes.map(
          (e) => {
            'id': 'inc_${e.description}',
            'description': e.description,
            'amount': e.amount,
            'is_income': true,
            'is_enabled': _automaticIncomeEnabled,
          },
        ),
      ];

      await _apiService.batchUpsertAutomaticItems(token, autoItems);
    } catch (e) {
      debugPrint('Failed to sync settings to server: $e');
    }
  }

  Future<void> resetUserSettings() async {
    _defaultAutomaticExpenses = [];
    _defaultAutomaticIncomes = [];
    _automaticExpenseEnabled = false;
    _automaticIncomeEnabled = false;
    final box = _persistence.settingsBox;
    await box.delete('defaultAutomaticExpenses');
    await box.delete('defaultAutomaticIncomes');
    await box.delete('automaticExpenseEnabled');
    await box.delete('automaticIncomeEnabled');
    notifyListeners();
  }

  Future<void> setCookieConsent(String choice) async {
    _cookieConsent = choice;
    await _persistence.settingsBox.put('cookieConsent', choice);
    _applyCrashlyticsConsent(choice);
    notifyListeners();
  }

  void _applyCrashlyticsConsent(String? choice) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          choice == 'all',
        );
      } catch (e) {
        debugPrint('Crashlytics consent update skipped: $e');
      }
    }
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    _autoSyncEnabled = enabled;
    await _persistence.settingsBox.put('autoSyncEnabled', enabled);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _persistence.settingsBox.put('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setBreakDurations(double paid, double unpaid) async {
    _paidBreakDurationMinutes = paid;
    _unpaidBreakDurationMinutes = unpaid;
    await _persistence.settingsBox.put('paidBreakDurationMinutes', paid);
    await _persistence.settingsBox.put('unpaidBreakDurationMinutes', unpaid);
    notifyListeners();
  }

  Future<void> setAutomaticExpenseEnabled(bool enabled) async {
    _automaticExpenseEnabled = enabled;
    await _persistence.settingsBox.put('automaticExpenseEnabled', enabled);
    notifyListeners();
    syncSettingsToServer();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> setAutomaticIncomeEnabled(bool enabled) async {
    _automaticIncomeEnabled = enabled;
    await _persistence.settingsBox.put('automaticIncomeEnabled', enabled);
    notifyListeners();
    syncSettingsToServer();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    _currencySymbol = symbol;
    await _persistence.settingsBox.put('currencySymbol', symbol);
    notifyListeners();
  }

  Future<void> setMonthlyProgressMode(MonthlyProgressMode mode) async {
    _monthlyProgressMode = mode;
    await _persistence.settingsBox.put('monthlyProgressMode', mode.name);
    notifyListeners();
  }

  Future<void> setMonthlyFinancialGoal(double amount) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Monthly financial goal must be greater than zero.',
      );
    }
    _monthlyFinancialGoal = amount;
    await _persistence.settingsBox.put('monthlyFinancialGoal', amount);
    notifyListeners();
  }

  Future<void> setBreaksEnabled(bool enabled) async {
    _breaksEnabled = enabled;
    await _persistence.settingsBox.put('breaksEnabled', enabled);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _persistence.settingsBox.put('locale', locale.languageCode);
    _updateDefaultTemplatesForLocale(locale);
    notifyListeners();
  }

  Future<void> updateDefaultAutomaticExpenses(
    List<AutomaticExpense> expenses,
  ) async {
    _defaultAutomaticExpenses = expenses;
    if (expenses.isNotEmpty && !_automaticExpenseEnabled) {
      _automaticExpenseEnabled = true;
      await _persistence.settingsBox.put('automaticExpenseEnabled', true);
    }
    await _persistence.settingsBox.put('defaultAutomaticExpenses', expenses);
    notifyListeners();
    syncSettingsToServer();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> updateDefaultAutomaticIncomes(
    List<AutomaticExpense> incomes,
  ) async {
    _defaultAutomaticIncomes = incomes;
    if (incomes.isNotEmpty && !_automaticIncomeEnabled) {
      _automaticIncomeEnabled = true;
      await _persistence.settingsBox.put('automaticIncomeEnabled', true);
    }
    await _persistence.settingsBox.put('defaultAutomaticIncomes', incomes);
    notifyListeners();
    syncSettingsToServer();
    _onAutomaticSettingsChanged?.call();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _persistence.settingsBox.put('hasCompletedOnboarding', true);
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _hasCompletedOnboarding = completed;
    await _persistence.settingsBox.put('hasCompletedOnboarding', completed);
    notifyListeners();
  }

  Future<void> resetAllSettings() async {
    _themeMode = ThemeMode.system;
    _paidBreakDurationMinutes = 20.0;
    _unpaidBreakDurationMinutes = 45.0;
    _hasCompletedOnboarding = false;
    _automaticExpenseEnabled = false;
    _defaultAutomaticExpenses = [];
    _automaticIncomeEnabled = false;
    _defaultAutomaticIncomes = [];
    _currencySymbol = AppConstants.defaultCurrencySymbol;
    _locale = const Locale('he', 'IL');
    _breaksEnabled = true;
    _monthlyProgressMode = MonthlyProgressMode.month;
    _monthlyFinancialGoal = 0;
    _overtimeRules = const OvertimeRules(enabled: true);
    _shabbatHolidayRules = const ShabbatHolidayRules(enabled: true);
    await _persistence.settingsBox.put(
        'overtimeRules', _overtimeRules.toJson());
    await _persistence.settingsBox.put(
        'shabbatHolidayRules', _shabbatHolidayRules.toJson());
    await _persistence.settingsBox.delete('monthlyProgressMode');
    await _persistence.settingsBox.delete('monthlyFinancialGoal');
    notifyListeners();
  }
}
