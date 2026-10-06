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
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0EA5E9),
                  const Color(0xFF0369A1),
                  const Color(0xFF1E293B),
                ]
              : [
                  const Color(0xFF38BDF8),
                  const Color(0xFF0EA5E9),
                  const Color(0xFF0284C7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          children: [
            // Soft glass overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                children: [
                  Text(
                    l.home_total_card_title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    UIUtils.formatCurrency(net, symbol: symbol),
                    style: AppTheme.monoNumber.copyWith(
                      color: net < 0 ? const Color(0xFFFECACA) : Colors.white,
                      fontSize: 42,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: AppTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
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
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _HeaderInfoItem(
                                  label: l.home_total_card_hours,
                                  value: totalHours.toStringAsFixed(2),
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _HeaderInfoItem(
                                  label: l.home_total_card_base,
                                  value: UIUtils.formatCurrency(
                                    totalBase,
                                    symbol: symbol,
                                  ),
                                  amount: totalBase,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (totalTips > 0 ||
                            totalIncomes > 0 ||
                            totalExpenses > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 8),
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
                                    ),
                                  ),
                                ],
                                if (totalTips > 0 &&
                                    (totalIncomes > 0 || totalExpenses > 0))
                                  const _VerticalDivider(),
                                if (totalIncomes > 0) ...[
                                  Expanded(
                                    child: _HeaderInfoItem(
                                      label: l.expenses_tab_incomes,
                                      value: UIUtils.formatCurrency(
                                        totalIncomes,
                                        symbol: symbol,
                                      ),
                                      amount: totalIncomes,
                                    ),
                                  ),
                                ],
                                if (totalIncomes > 0 && totalExpenses > 0)
                                  const _VerticalDivider(),
                                if (totalExpenses > 0) ...[
                                  Expanded(
                                    child: _HeaderInfoItem(
                                      label: l.home_total_card_expenses,
                                      value: UIUtils.formatCurrency(
                                        totalExpenses,
                                        symbol: symbol,
                                      ),
                                      amount: -totalExpenses,
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

  const _HeaderInfoItem({
    required this.label,
    required this.value,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: (amount ?? 0) < 0 ? const Color(0xFFFECACA) : Colors.white,
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
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
