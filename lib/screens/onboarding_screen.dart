import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/wage_entry.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/main_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/add_shift/shift_template_chips.dart';
import 'package:shiftly/widgets/app_icon.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 7;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State
  late double _paidMinutes;
  late double _unpaidMinutes;
  late bool _autoExpenseEnabled;
  late bool _autoIncomeEnabled;
  late String _currencySymbol;
  late MonthlyProgressMode _monthlyProgressMode;
  late TextEditingController _monthlyFinancialGoalController;
  late Locale _locale;
  late bool _breaksEnabled;
  late OvertimeRules _onboardingOvertimeRules;
  late ShabbatHolidayRules _onboardingShabbatRules;
  late TextEditingController _onboardingOtThresholdController;
  late TextEditingController _onboardingOtTier1LimitController;
  late TextEditingController _onboardingOtTier1MultiplierController;
  late TextEditingController _onboardingOtTier2MultiplierController;
  late TextEditingController _onboardingShabbatMultiplierController;
  late TextEditingController _onboardingHolidayMultiplierController;
  final List<TextEditingController> _autoAmountControllers = [];
  final List<TextEditingController> _autoDescControllers = [];
  final List<TextEditingController> _autoIncomeAmountControllers = [];
  final List<TextEditingController> _autoIncomeDescControllers = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _paidMinutes = settings.paidBreakDurationMinutes;
    _unpaidMinutes = settings.unpaidBreakDurationMinutes;
    _autoExpenseEnabled = settings.automaticExpenseEnabled;
    _autoIncomeEnabled = settings.automaticIncomeEnabled;
    _currencySymbol = settings.currencySymbol;
    _monthlyProgressMode = settings.monthlyProgressMode;
    _monthlyFinancialGoalController = TextEditingController(
      text: settings.monthlyFinancialGoal > 0
          ? settings.monthlyFinancialGoal.toStringAsFixed(2)
          : '',
    );
    _locale = settings.locale;
    _breaksEnabled = settings.breaksEnabled;
    _onboardingOvertimeRules = settings.overtimeRules;
    _onboardingShabbatRules = settings.shabbatHolidayRules;

    _onboardingOtThresholdController = TextEditingController(
      text: _onboardingOvertimeRules.regularHoursThreshold.toStringAsFixed(1),
    );
    _onboardingOtTier1LimitController = TextEditingController(
      text: _onboardingOvertimeRules.tier1HoursLimit.toStringAsFixed(1),
    );
    _onboardingOtTier1MultiplierController = TextEditingController(
      text: (_onboardingOvertimeRules.tier1Multiplier * 100).toStringAsFixed(0),
    );
    _onboardingOtTier2MultiplierController = TextEditingController(
      text: (_onboardingOvertimeRules.tier2Multiplier * 100).toStringAsFixed(0),
    );
    _onboardingShabbatMultiplierController = TextEditingController(
      text: (_onboardingShabbatRules.shabbatMultiplier * 100).toStringAsFixed(
        0,
      ),
    );
    _onboardingHolidayMultiplierController = TextEditingController(
      text: (_onboardingShabbatRules.holidayMultiplier * 100).toStringAsFixed(
        0,
      ),
    );

    for (var e in settings.defaultAutomaticExpenses) {
      _autoAmountControllers.add(
        TextEditingController(
          text: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
        ),
      );
      _autoDescControllers.add(TextEditingController(text: e.description));
    }
    if (_autoAmountControllers.isEmpty) {
      _autoAmountControllers.add(TextEditingController());
      _autoDescControllers.add(TextEditingController());
    }

    for (var e in settings.defaultAutomaticIncomes) {
      _autoIncomeAmountControllers.add(
        TextEditingController(
          text: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
        ),
      );
      _autoIncomeDescControllers.add(
        TextEditingController(text: e.description),
      );
    }
    if (_autoIncomeAmountControllers.isEmpty) {
      _autoIncomeAmountControllers.add(TextEditingController());
      _autoIncomeDescControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthlyFinancialGoalController.dispose();
    _onboardingOtThresholdController.dispose();
    _onboardingOtTier1LimitController.dispose();
    _onboardingOtTier1MultiplierController.dispose();
    _onboardingOtTier2MultiplierController.dispose();
    _onboardingShabbatMultiplierController.dispose();
    _onboardingHolidayMultiplierController.dispose();
    for (var c in _autoAmountControllers) {
      c.dispose();
    }
    for (var c in _autoDescControllers) {
      c.dispose();
    }
    for (var c in _autoIncomeAmountControllers) {
      c.dispose();
    }
    for (var c in _autoIncomeDescControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding({bool skipIncomplete = false}) async {
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    var progressMode = _monthlyProgressMode;
    final financialGoal = double.tryParse(
      _monthlyFinancialGoalController.text.trim(),
    );
    if (progressMode == MonthlyProgressMode.financialGoal &&
        (financialGoal == null ||
            !financialGoal.isFinite ||
            financialGoal <= 0)) {
      if (!skipIncomplete) {
        UIUtils.showSnackBar(
          context,
          l.monthly_progress_invalid_goal,
          isError: true,
        );
        return;
      }
      progressMode = MonthlyProgressMode.month;
    }

    List<AutomaticExpense> expenses = [];
    if (_autoExpenseEnabled) {
      for (int i = 0; i < _autoAmountControllers.length; i++) {
        final amountText = _autoAmountControllers[i].text.trim();
        final desc = _autoDescControllers[i].text.trim();

        if (amountText.isEmpty && desc.isEmpty) continue;
        final amount = double.tryParse(amountText);
        if (skipIncomplete && (desc.isEmpty || amount == null || amount <= 0)) {
          continue;
        }
        if (desc.isEmpty) {
          UIUtils.showSnackBar(
            context,
            l.settings_dialog_error_enter_desc,
            isError: true,
          );
          return;
        }
        if (amount == null || amount <= 0) {
          UIUtils.showSnackBar(
            context,
            l.onboarding_auto_expenses_invalid_amount,
            isError: true,
          );
          return;
        }
        expenses.add(AutomaticExpense(description: desc, amount: amount));
      }
    }

    List<AutomaticExpense> incomes = [];
    if (_autoIncomeEnabled) {
      for (int i = 0; i < _autoIncomeAmountControllers.length; i++) {
        final amountText = _autoIncomeAmountControllers[i].text.trim();
        final desc = _autoIncomeDescControllers[i].text.trim();

        if (amountText.isEmpty && desc.isEmpty) continue;
        final amount = double.tryParse(amountText);
        if (skipIncomplete && (desc.isEmpty || amount == null || amount <= 0)) {
          continue;
        }
        if (desc.isEmpty) {
          UIUtils.showSnackBar(
            context,
            l.settings_dialog_error_enter_income_desc,
            isError: true,
          );
          return;
        }
        if (amount == null || amount <= 0) {
          UIUtils.showSnackBar(
            context,
            l.onboarding_auto_expenses_invalid_amount,
            isError: true,
          );
          return;
        }
        incomes.add(AutomaticExpense(description: desc, amount: amount));
      }
    }

    await settings.setBreakDurations(_paidMinutes, _unpaidMinutes);
    await settings.setBreaksEnabled(_breaksEnabled);
    await settings.setAutomaticExpenseEnabled(_autoExpenseEnabled);
    await settings.updateDefaultAutomaticExpenses(expenses);
    await settings.setAutomaticIncomeEnabled(_autoIncomeEnabled);
    await settings.updateDefaultAutomaticIncomes(incomes);
    await settings.setCurrencySymbol(_currencySymbol);
    await settings.setLocale(_locale);
    if (progressMode == MonthlyProgressMode.financialGoal) {
      await settings.setMonthlyFinancialGoal(financialGoal!);
    }
    await settings.setMonthlyProgressMode(progressMode);

    final threshold =
        double.tryParse(_onboardingOtThresholdController.text) ?? 8.0;
    final tier1Limit =
        double.tryParse(_onboardingOtTier1LimitController.text) ?? 2.0;
    final tier1Mult =
        (double.tryParse(_onboardingOtTier1MultiplierController.text) ??
            125.0) /
        100.0;
    final tier2Mult =
        (double.tryParse(_onboardingOtTier2MultiplierController.text) ??
            150.0) /
        100.0;

    final updatedOtRules = _onboardingOvertimeRules.copyWith(
      regularHoursThreshold: threshold,
      tier1HoursLimit: tier1Limit,
      tier1Multiplier: tier1Mult,
      tier2Multiplier: tier2Mult,
    );
    await settings.setOvertimeRules(updatedOtRules);

    final shabbatMult =
        (double.tryParse(_onboardingShabbatMultiplierController.text) ??
            150.0) /
        100.0;
    final holidayMult =
        (double.tryParse(_onboardingHolidayMultiplierController.text) ??
            150.0) /
        100.0;
    final updatedShabbatRules = _onboardingShabbatRules.copyWith(
      shabbatMultiplier: shabbatMult,
      holidayMultiplier: holidayMult,
    );
    await settings.setShabbatHolidayRules(updatedShabbatRules);

    await settings.completeOnboarding();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      AppPageRoute.fadeScale(
        const MainScreen(),
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPage(pageIndex: 0, child: _buildWelcomePage()),
                  _buildPage(pageIndex: 1, child: _buildJobTypesPage()),
                  _buildPage(pageIndex: 2, child: _buildShiftTemplatesPage()),
                  _buildPage(pageIndex: 3, child: _buildBreakSettingsPage()),
                  _buildPage(pageIndex: 4, child: _buildPayRulesPage()),
                  _buildPage(pageIndex: 5, child: _buildAutoExpensePage()),
                  _buildPage(pageIndex: 6, child: _buildAutoIncomePage()),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppTheme.electricCyan : AppTheme.brightCyan;
    final inactive = isDark
        ? AppTheme.darkSurfaceElevated
        : AppTheme.lightBorder;
    final progressAnimationDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 240);
    final progressLabel = l.onboarding_step_progress(
      _currentPage + 1,
      _pageCount,
    );
    const stepIcons = [
      Icons.tune_rounded,
      Icons.work_outline_rounded,
      Icons.auto_awesome_rounded,
      Icons.schedule_rounded,
      Icons.rule_rounded,
      Icons.payments_outlined,
      Icons.account_balance_wallet_rounded,
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progressLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: 320,
                      child: Row(
                        children: List.generate(_pageCount * 2 - 1, (index) {
                          if (index.isOdd) {
                            final completed = index ~/ 2 < _currentPage;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: progressAnimationDuration,
                                height: 2,
                                color: completed ? accent : inactive,
                              ),
                            );
                          }

                          final step = index ~/ 2;
                          final completed = step < _currentPage;
                          final active = step == _currentPage;
                          final color = completed || active ? accent : inactive;
                          return AnimatedContainer(
                            duration: progressAnimationDuration,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: active
                                  ? accent.withValues(alpha: 0.16)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color,
                                width: active ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              completed ? Icons.check_rounded : stepIcons[step],
                              size: 15,
                              color: color,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentPage < _pageCount - 1)
            TextButton(
              onPressed: () => _finishOnboarding(skipIncomplete: true),
              style: TextButton.styleFrom(minimumSize: const Size(80, 48)),
              child: Text(l.onboarding_skip_setup),
            ),
        ],
      ),
    );
  }

  Widget _buildPage({required Widget child, required int pageIndex}) {
    return PageEntranceAnimation(
      key: ValueKey(pageIndex),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = AppTheme.electricCyan,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWelcomePage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: EssentialWorkIcon(size: 96, symbol: _currencySymbol)),
        const SizedBox(height: 24),
        Text(
          l.onboarding_welcome_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          l.onboarding_welcome_subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.onboarding_welcome_description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        DropdownButtonFormField<String>(
          initialValue: _locale.languageCode,
          decoration: InputDecoration(
            labelText: l.onboarding_language_title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            prefixIcon: const Icon(Icons.translate_rounded),
          ),
          items: [
            DropdownMenuItem(value: 'he', child: Text(l.settings_language_he)),
            DropdownMenuItem(value: 'en', child: Text(l.settings_language_en)),
          ],
          onChanged: (val) {
            if (val != null) {
              final newLocale = Locale(val);
              setState(() => _locale = newLocale);
              context.read<SettingsProvider>().setLocale(newLocale);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _currencySymbol,
          decoration: InputDecoration(
            labelText: l.onboarding_currency_title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          items: [
            DropdownMenuItem(value: '₪', child: Text('₪ ILS')),
            DropdownMenuItem(value: '\$', child: Text('\$ USD')),
            DropdownMenuItem(value: '€', child: Text('€ EUR')),
            DropdownMenuItem(value: '£', child: Text('£ GBP')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _currencySymbol = val);
          },
        ),
      ],
    );
  }

  Widget _buildPayRulesPage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.rule_rounded,
          title: l.settings_section_overtime,
          subtitle: l.settings_overtime_enable_sub,
        ),
        _buildPayRuleCard(
          title: l.settings_section_overtime,
          subtitle: l.settings_overtime_enable_sub,
          icon: Icons.more_time_rounded,
          enabled: _onboardingOvertimeRules.enabled,
          onChanged: (enabled) => setState(() {
            _onboardingOvertimeRules = _onboardingOvertimeRules.copyWith(
              enabled: enabled,
            );
          }),
          enableLabel: l.settings_overtime_enable,
          fields: [
            _buildRuleField(
              controller: _onboardingOtThresholdController,
              label: l.settings_overtime_regular_threshold,
              icon: Icons.access_time,
              decimal: true,
            ),
            _buildRuleField(
              controller: _onboardingOtTier1LimitController,
              label: l.settings_overtime_tier1_limit,
              icon: Icons.timelapse,
              decimal: true,
            ),
            _buildRuleField(
              controller: _onboardingOtTier1MultiplierController,
              label: l.settings_overtime_tier1_rate,
              icon: Icons.percent,
            ),
            _buildRuleField(
              controller: _onboardingOtTier2MultiplierController,
              label: l.settings_overtime_tier2_rate,
              icon: Icons.percent,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        _buildPayRuleCard(
          title: l.onboarding_shabbat_title,
          subtitle: l.onboarding_shabbat_subtitle,
          icon: Icons.star_rounded,
          enabled: _onboardingShabbatRules.enabled,
          onChanged: (enabled) => setState(() {
            _onboardingShabbatRules = _onboardingShabbatRules.copyWith(
              enabled: enabled,
            );
          }),
          enableLabel: l.settings_shabbat_enable,
          fields: [
            _buildRuleField(
              controller: _onboardingShabbatMultiplierController,
              label: l.settings_shabbat_multiplier_label,
              icon: Icons.percent,
            ),
            _buildRuleField(
              controller: _onboardingHolidayMultiplierController,
              label: l.settings_holiday_multiplier_label,
              icon: Icons.percent,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        DropdownButtonFormField<MonthlyProgressMode>(
          initialValue: _monthlyProgressMode,
          decoration: InputDecoration(
            labelText: l.monthly_progress_setting_title,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            filled: true,
            prefixIcon: const Icon(Icons.show_chart_rounded),
          ),
          items: [
            DropdownMenuItem(
              value: MonthlyProgressMode.month,
              child: Text(l.monthly_progress_mode_month),
            ),
            DropdownMenuItem(
              value: MonthlyProgressMode.financialGoal,
              child: Text(l.monthly_progress_mode_financial_goal),
            ),
          ],
          onChanged: (mode) {
            if (mode != null) setState(() => _monthlyProgressMode = mode);
          },
        ),
        if (_monthlyProgressMode == MonthlyProgressMode.financialGoal) ...[
          const SizedBox(height: AppTheme.spaceSm),
          TextField(
            controller: _monthlyFinancialGoalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.monthly_progress_goal_amount,
              prefixText: '$_currencySymbol ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              filled: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPayRuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    required String enableLabel,
    required List<Widget> fields,
  }) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        children: [
          SwitchListTile(
            title: Text(enableLabel),
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.onPrimary,
            activeTrackColor: theme.colorScheme.primary,
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTheme.spaceSm,
                0,
                AppTheme.spaceSm,
                AppTheme.spaceSm,
              ),
              child: Column(
                children: [
                  for (var index = 0; index < fields.length; index++) ...[
                    if (index > 0) const SizedBox(height: AppTheme.spaceSm),
                    fields[index],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRuleField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        filled: true,
        prefixIcon: Icon(icon),
      ),
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
    );
  }

  Widget _buildBreakSettingsPage() {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.timer_outlined,
          title: l.onboarding_breaks_title,
          subtitle: l.onboarding_breaks_subtitle,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_breaks_enable,
            style: theme.textTheme.titleMedium,
          ),
          value: _breaksEnabled,
          onChanged: (val) => setState(() => _breaksEnabled = val),
          activeThumbColor: theme.colorScheme.onPrimary,
          activeTrackColor: theme.colorScheme.primary,
        ),
        if (_breaksEnabled) ...[
          const SizedBox(height: AppTheme.spaceSm),
          _buildDurationSlider(
            label: l.onboarding_breaks_paid_label,
            value: _paidMinutes,
            onChanged: (val) => setState(() => _paidMinutes = val),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _buildDurationSlider(
            label: l.onboarding_breaks_unpaid_label,
            value: _unpaidMinutes,
            onChanged: (val) => setState(() => _unpaidMinutes = val),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpensePage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.auto_fix_high_rounded,
          title: l.onboarding_auto_expenses_title,
          subtitle: l.onboarding_auto_expenses_subtitle,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_auto_expenses_enable,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _autoExpenseEnabled,
          onChanged: (val) => setState(() => _autoExpenseEnabled = val),
          activeThumbColor: AppTheme.darkBackground,
          activeTrackColor: AppTheme.electricCyan,
        ),
        if (_autoExpenseEnabled) ...[
          const SizedBox(height: 24),
          ...List.generate(
            _autoAmountControllers.length,
            (index) => _buildAutoExpenseRow(index, _currencySymbol),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _autoAmountControllers.add(TextEditingController());
              _autoDescControllers.add(TextEditingController());
            }),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(l.onboarding_auto_expenses_add_button),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpenseRow(int index, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoDescControllers[index],
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
                hintText: l.default_expenses_trips,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _autoAmountControllers[index],
              decoration: InputDecoration(labelText: symbol, hintText: '0'),
              keyboardType: TextInputType.number,
            ),
          ),
          if (_autoAmountControllers.length > 1)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.softCoral,
              ),
              onPressed: () => setState(() {
                final amountC = _autoAmountControllers.removeAt(index);
                final descC = _autoDescControllers.removeAt(index);
                amountC.dispose();
                descC.dispose();
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoIncomePage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.account_balance_wallet_rounded,
          title: l.onboarding_auto_incomes_title,
          subtitle: l.onboarding_auto_incomes_subtitle,
          iconColor: AppTheme.mintGreen,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_auto_incomes_enable,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _autoIncomeEnabled,
          onChanged: (val) => setState(() => _autoIncomeEnabled = val),
          activeThumbColor: AppTheme.darkBackground,
          activeTrackColor: AppTheme.mintGreen,
        ),
        if (_autoIncomeEnabled) ...[
          const SizedBox(height: 24),
          ...List.generate(
            _autoIncomeAmountControllers.length,
            (index) => _buildAutoIncomeRow(index, _currencySymbol),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _autoIncomeAmountControllers.add(TextEditingController());
              _autoIncomeDescControllers.add(TextEditingController());
            }),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(l.onboarding_auto_incomes_add_button),
            style: TextButton.styleFrom(foregroundColor: AppTheme.mintGreen),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoIncomeRow(int index, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoIncomeDescControllers[index],
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
                hintText: l.default_expenses_trips,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _autoIncomeAmountControllers[index],
              decoration: InputDecoration(labelText: symbol, hintText: '0'),
              keyboardType: TextInputType.number,
            ),
          ),
          if (_autoIncomeAmountControllers.length > 1)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.softCoral,
              ),
              onPressed: () => setState(() {
                final amountC = _autoIncomeAmountControllers.removeAt(index);
                final descC = _autoIncomeDescControllers.removeAt(index);
                amountC.dispose();
                descC.dispose();
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 120,
    int divisions = 24,
    String displaySuffix = '',
  }) {
    if (displaySuffix.isEmpty) {
      displaySuffix = AppLocalizations.of(context)!.common_min_suffix;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${(value * 10).round() / 10} $displaySuffix'.replaceAll(
                '.0 ',
                ' ',
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.electricCyan,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildJobTypesPage() {
    final shiftProvider = context.watch<ShiftProvider>();
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final jobTypes = shiftProvider.jobTypes;
    final l = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.work_outline_rounded,
          title: l.onboarding_job_types_title,
          subtitle: l.onboarding_job_types_subtitle,
        ),
        ...jobTypes.map((job) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                job.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${UIUtils.formatCurrency(
                    job.getRateForDate(DateTime.now()), symbol: symbol)} ${l
                    .onboarding_job_types_rate_suffix}',
                style: const TextStyle(
                  color: AppTheme.electricCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.electricCyan,
                    ),
                    onPressed: () => _editJobType(job),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.softCoral,
                    ),
                    onPressed: () async {
                      final provider = context.read<ShiftProvider>();
                      final confirmed = await UIUtils.showConfirmDialog(
                        context: context,
                        title: l.onboarding_job_types_delete_title,
                        content:
                        '${l.onboarding_job_types_delete_desc} ${job.name}?',
                        isDestructive: true,
                        confirmLabel: l.common_delete,
                        cancelLabel: l.common_cancel,
                      );
                      if (confirmed == true && context.mounted) {
                        provider.deleteJobType(job.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: TextButton.icon(
              onPressed: _addNewJobType,
              icon: const Icon(Icons.add),
              label: Text(l.onboarding_job_types_add_button),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.electricCyan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftTemplatesPage() {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final templates = settings.shiftTemplates;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: AppTheme.electricCyan,
            ),
            const SizedBox(height: 16),
            Text(
              l.shift_template_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.shift_template_subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = templates[index];
                final startStr =
                    '${t.startTime.hour.toString().padLeft(2, '0')}:${t
                    .startTime.minute
                    .toString()
                    .padLeft(2, '0')}';
                final endStr =
                    '${t.endTime.hour.toString().padLeft(2, '0')}:${t.endTime
                    .minute.toString().padLeft(2, '0')}';

                return Card(
                  elevation: 0,
                  color: isDark
                      ? AppTheme.darkSecondaryBackground
                      : AppTheme.lightSurfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    side: BorderSide(
                      color: isDark
                          ? AppTheme.darkBorder
                          : AppTheme.lightBorder,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.electricCyan.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: AppTheme.electricCyan,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      t.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '$startStr - $endStr',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              ShiftTemplateChips.showEditTemplateDialog(
                                context,
                                t,
                              ),
                        ),
                        if (templates.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.expense,
                              size: 20,
                            ),
                            onPressed: () async {
                              final confirm =
                              await UIUtils.showConfirmDialog(
                                context: context,
                                title:
                                l.shift_template_delete_confirm_title,
                                content:
                                l.shift_template_delete_confirm_content,
                                confirmLabel: l.common_delete,
                                isDestructive: true,
                              );
                              if (confirm) {
                                await settings.deleteShiftTemplate(t.id);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  ShiftTemplateChips.showEditTemplateDialog(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.shift_template_add_button),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editJobType(JobType job) {
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: job.name);
    final rate = job.getRateForDate(DateTime.now());
    final rateController = TextEditingController(
      text: rate > 0 ? rate.toString() : '',
    );
    DateTime effectiveDate = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.onboarding_job_types_edit_button),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l.settings_job_name_label,
                  hintText: l.settings_job_name_label,
                ),
              ),
              TextField(
                controller: rateController,
                decoration: InputDecoration(
                  labelText: l.settings_job_rate_label,
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
              ),
              ListTile(
                title: Text(l.common_back),
                subtitle: Text(AppConstants.formatDate(effectiveDate)),
                trailing: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.electricCyan,
                ),
                onTap: () async {
                  final picked = await AppDatePicker.showSingleDatePicker(
                    context: context,
                    initialDate: effectiveDate,
                  );
                  if (picked != null) {
                    setDialogState(() => effectiveDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rate =
                    double.tryParse(rateController.text) ?? job.hourlyRate;
                if (name.isEmpty) return;
                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: l.onboarding_job_types_edit_button,
                  content: '${l.onboarding_job_types_edit_button} $name?',
                );
                if (confirmed != true || !context.mounted) return;
                final history = List<WageEntry>.from(job.wageHistory ?? [])
                  ..removeWhere((e) => isSameDay(e.startDate, effectiveDate))
                  ..add(WageEntry(startDate: effectiveDate, hourlyRate: rate))
                  ..sort((a, b) => a.startDate.compareTo(b.startDate));
                final updated = job.copyWith(name: name, wageHistory: history)
                  ..syncCurrentRate();
                await context.read<ShiftProvider>().updateJobType(updated);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l.common_save),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewJobType() {
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.onboarding_job_types_add_button),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l.settings_job_name_label,
                hintText: l.settings_job_name_label,
              ),
            ),
            TextField(
              controller: rateController,
              decoration: InputDecoration(
                labelText: l.settings_job_rate_label,
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.common_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final rate = double.tryParse(rateController.text) ?? 0.0;
              if (name.isEmpty) return;
              final newJob = JobType(
                id: const Uuid().v4(),
                name: name,
                hourlyRate: rate,
                wageHistory: [
                  WageEntry(startDate: DateTime.now(), hourlyRate: rate),
                ],
              )..syncCurrentRate();
              context.read<ShiftProvider>().addJobType(newJob);
              Navigator.pop(context);
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              style: TextButton.styleFrom(minimumSize: const Size(80, 48)),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              label: Text(l.common_back),
            )
          else
            const SizedBox(width: 80),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricCyan,
              foregroundColor: AppTheme.darkBackground,
              minimumSize: const Size(120, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(
              _currentPage == _pageCount - 1
                  ? l.common_start
                  : l.common_continue,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
