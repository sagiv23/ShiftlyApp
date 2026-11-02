import 'package:flutter/material.dart';
import 'package:shiftly/theme/app_theme.dart';

class AddShiftFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const AddShiftFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      decoration: AppTheme.sectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryDark),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class AddShiftCollapsibleFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? summary;
  final bool initiallyExpanded;
  final Widget child;

  const AddShiftCollapsibleFormSection({
    super.key,
    required this.title,
    required this.icon,
    this.summary,
    this.initiallyExpanded = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasSummary = summary != null && summary!.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: AppTheme.sectionDecoration(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          maintainState: true,
          leading: Icon(icon, size: 18, color: AppTheme.primaryDark),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: hasSummary
              ? Text(
                  summary!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark.withValues(alpha: 0.85),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                )
              : null,
          childrenPadding: const EdgeInsets.fromLTRB(
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            AppTheme.spaceSm,
          ),
          children: [child],
        ),
      ),
    );
  }
}

class AddShiftPickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const AddShiftPickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryDark, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
