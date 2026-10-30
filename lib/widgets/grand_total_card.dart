import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ui_utils.dart';

class GrandTotalCard extends StatelessWidget {
  final double totalHours;
  final double totalBase;
  final double totalTips;
  final double totalExpenses;
  final double totalIncomes;
  final int totalShifts;

  const GrandTotalCard({
    super.key,
    required this.totalHours,
    required this.totalBase,
    required this.totalTips,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.totalShifts,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalBase + totalTips + totalIncomes - totalExpenses;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppTheme.spaceMd,
        top: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border.all(
          color: isDark ? AppTheme.highlightBorder : AppTheme.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricCyan.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.neonViolet.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          children: [
            // Dark glass background gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppTheme.darkCard,
                            AppTheme.darkSecondaryBackground,
                            const Color(0xFF070B18),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF8FAFC),
                            AppTheme.lightSurfaceElevated,
                          ],
                  ),
                ),
              ),
            ),
            // Background cyan glow accent
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.electricCyan.withValues(
                    alpha: isDark ? 0.12 : 0.08,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(
                        alpha: isDark ? 0.12 : 0.08,
                      ),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            // Background violet glow accent
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.neonViolet.withValues(
                    alpha: isDark ? 0.15 : 0.06,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonViolet.withValues(
                        alpha: isDark ? 0.15 : 0.06,
                      ),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.electricCyan.withValues(
                            alpha: isDark ? 0.15 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.electricCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 14,
                              color: AppTheme.electricCyan,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l.home_total_card_title,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.primaryText
                                    : AppTheme.brightCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Animated Net Salary Counter
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: net),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, animNet, child) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          UIUtils.formatCurrency(animNet, symbol: symbol),
                          style: AppTheme.monoNumber.copyWith(
                            color: animNet < 0
                                ? AppTheme.softCoral
                                : (isDark
                                      ? AppTheme.primaryText
                                      : const Color(0xFF0F172A)),
                            fontSize: 40,
                            height: 1.1,
                            shadows: [
                              if (isDark)
                                BoxShadow(
                                  color: AppTheme.electricCyan.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Summary Breakdown Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: AppTheme.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSecondaryBackground.withValues(
                              alpha: 0.7,
                            )
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _HeaderInfoItem(
                                  label: l.common_shifts_count,
                                  value: totalShifts.toString(),
                                  isDark: isDark,
                                ),
                              ),
                              _VerticalDivider(isDark: isDark),
                              Expanded(
                                child: _HeaderInfoItem(
                                  label: l.home_total_card_hours,
                                  value: totalHours.toStringAsFixed(2),
                                  isDark: isDark,
                                ),
                              ),
                              _VerticalDivider(isDark: isDark),
                              Expanded(
                                child: _HeaderInfoItem(
                                  label: l.home_total_card_base,
                                  value: UIUtils.formatCurrency(
                                    totalBase,
                                    symbol: symbol,
                                  ),
                                  amount: totalBase,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (totalTips > 0 ||
                            totalIncomes > 0 ||
                            totalExpenses > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (totalTips > 0) ...[
                                  Expanded(
                                    child: _HeaderInfoItem(
                                      label: l.home_total_card_tips,
                                      value: UIUtils.formatCurrency(
                                        totalTips,
                                        symbol: symbol,
                                      ),
                                      amount: totalTips,
                                      accentColor: AppTheme.mintGreen,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                                if (totalTips > 0 &&
                                    (totalIncomes > 0 || totalExpenses > 0))
                                  _VerticalDivider(isDark: isDark),
                                if (totalIncomes > 0) ...[
                                  Expanded(
                                    child: _HeaderInfoItem(
                                      label: l.expenses_tab_incomes,
                                      value: UIUtils.formatCurrency(
                                        totalIncomes,
                                        symbol: symbol,
                                      ),
                                      amount: totalIncomes,
                                      accentColor: AppTheme.mintGreen,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                                if (totalIncomes > 0 && totalExpenses > 0)
                                  _VerticalDivider(isDark: isDark),
                                if (totalExpenses > 0) ...[
                                  Expanded(
                                    child: _HeaderInfoItem(
                                      label: l.home_total_card_expenses,
                                      value: UIUtils.formatCurrency(
                                        totalExpenses,
                                        symbol: symbol,
                                      ),
                                      amount: -totalExpenses,
                                      accentColor: AppTheme.softCoral,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final double? amount;
  final Color? accentColor;
  final bool isDark;

  const _HeaderInfoItem({
    required this.label,
    required this.value,
    this.amount,
    this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color valColor;
    if ((amount ?? 0) < 0) {
      valColor = AppTheme.softCoral;
    } else if (accentColor != null) {
      valColor = accentColor!;
    } else {
      valColor = isDark ? AppTheme.primaryText : const Color(0xFF0F172A);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.secondaryText : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;

  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
    );
  }
}
