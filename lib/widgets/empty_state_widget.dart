import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.history_rounded,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.electricCyan.withValues(
                    alpha: isDark ? 0.14 : 0.1,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.electricCyan.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(
                        alpha: isDark ? 0.15 : 0.05,
                      ),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(icon, size: 56, color: AppTheme.electricCyan),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.secondaryText
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppTheme.spaceMd),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
