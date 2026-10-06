import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/app_date_picker.dart';

/// Reusable input field that displays a formatted date and opens a unified date picker on tap.
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? label;
  final String? hint;
  final IconData icon;
  final bool isBirthDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label,
    this.hint,
    this.icon = Icons.calendar_today_rounded,
    this.isBirthDate = false,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked;
    if (isBirthDate) {
      picked = await AppDatePicker.showBirthDatePicker(
        context: context,
        initialDate: selectedDate,
      );
    } else {
      picked = await AppDatePicker.showSingleDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final displayLabel = label ?? l.add_shift_manual_date_label;
    final formattedText = selectedDate != null
        ? AppConstants.formatDate(selectedDate)
        : (hint ?? displayLabel);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: displayLabel,
          suffixIcon: Icon(icon, size: 20),
        ),
        child: Text(
          formattedText,
          style: selectedDate == null
              ? TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                )
              : null,
        ),
      ),
    );
  }
}
