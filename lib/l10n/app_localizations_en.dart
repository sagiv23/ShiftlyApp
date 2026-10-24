// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_start => 'Let\'s Start!';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_tagline => 'WAGE & SHIFT ENGINE';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_analytics => 'Analytics';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_expenses => 'Expenses';

  @override
  String get nav_summaries => 'Summaries';

  @override
  String get common_hours_suffix => 'hours';

  @override
  String get common_min_suffix => 'min';

  @override
  String get common_net => 'Net';

  @override
  String get common_shifts_count => 'Shifts';

  @override
  String get common_save_and_finish => 'Save & Finish';

  @override
  String get common_reset => 'Reset';

  @override
  String get common_reset_and_cancel => 'Cancel & Reset';

  @override
  String get onboarding_welcome_title => 'Welcome to Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'The app that helps you track your shifts, salary, and tips easily and accurately.';

  @override
  String get onboarding_welcome_description =>
      'Let\'s set up some basics to get started.';

  @override
  String get onboarding_language_title => 'App Language';

  @override
  String get onboarding_language_subtitle => 'Choose your preferred language.';

  @override
  String get onboarding_currency_title => 'Select Currency';

  @override
  String get onboarding_currency_subtitle =>
      'Which currency would you like to use for salary and expenses?';

  @override
  String get onboarding_breaks_title => 'Break Settings';

  @override
  String get onboarding_breaks_subtitle =>
      'How long does a break usually last?';

  @override
  String get onboarding_breaks_enable => 'Enable Breaks';

  @override
  String get onboarding_breaks_paid_label => 'Paid Break (minutes)';

  @override
  String get onboarding_breaks_unpaid_label => 'Unpaid Break (minutes)';

  @override
  String get onboarding_auto_expenses_title => 'Recurring Expenses';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'Do you have recurring expenses in every shift? (e.g. travel)';

  @override
  String get onboarding_auto_expenses_enable => 'Enable Auto Expenses';

  @override
  String get onboarding_auto_expenses_add_button => 'Add Expense';

  @override
  String get onboarding_auto_expenses_desc_label => 'Description';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'Amount must be greater than 0';

  @override
  String get onboarding_auto_incomes_title => 'Recurring Incomes';

  @override
  String get onboarding_auto_incomes_subtitle =>
      'Do you have recurring incomes in every shift? (e.g. travel reimbursement)';

  @override
  String get onboarding_auto_incomes_enable => 'Enable Auto Incomes';

  @override
  String get onboarding_auto_incomes_add_button => 'Add Income';

  @override
  String get onboarding_job_types_title => 'Shifts & Wages';

  @override
  String get onboarding_job_types_subtitle =>
      'Define your different roles and hourly rates.';

  @override
  String get onboarding_job_types_add_button => 'Add Shift Type';

  @override
  String get onboarding_job_types_edit_button => 'Edit Shift Type';

  @override
  String get onboarding_job_types_delete_title => 'Delete Job';

  @override
  String get onboarding_job_types_delete_desc => 'Delete job ';

  @override
  String get onboarding_job_types_rate_suffix => 'per hour';

  @override
  String get onboarding_job_types_same => 'Job with this name already exists';

  @override
  String get default_job_buffet => 'Buffet';

  @override
  String get default_job_steward => 'Steward';

  @override
  String get default_job_unloading => 'Unloading';

  @override
  String get default_expenses_trips => 'Travel';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_app => 'Application';

  @override
  String get settings_section_breaks => 'Break Durations (min)';

  @override
  String get settings_section_danger => 'Danger Zone';

  @override
  String get settings_field_theme => 'Theme';

  @override
  String get settings_field_language => 'App Language';

  @override
  String get settings_field_currency => 'Display Currency';

  @override
  String get settings_field_currency_sub =>
      'Currency used for salary and expenses';

  @override
  String get settings_field_breaks_enabled => 'Enable Breaks';

  @override
  String get settings_field_breaks_enabled_sub =>
      'Show or hide break settings in the app';

  @override
  String get settings_field_paid_break => 'Short Break (Paid)';

  @override
  String get settings_field_unpaid_break => 'Long Break (Unpaid)';

  @override
  String get settings_action_update_breaks => 'Update Times';

  @override
  String get settings_action_factory_reset => 'Full Factory Reset';

  @override
  String get settings_action_factory_reset_sub =>
      'Permanently delete all shifts, roles, and expenses';

  @override
  String get settings_dialog_update_breaks_title => 'Update Break Times';

  @override
  String get settings_dialog_factory_reset_title => 'Reset Data?';

  @override
  String get settings_dialog_factory_reset_content =>
      'Are you sure you want to delete all work data and reset the app? This action cannot be undone.';

  @override
  String get settings_dialog_final_confirm_title => 'Final Confirmation';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'Warning: All shift history, salary, and expenses will be permanently deleted.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'Are you sure you want to delete everything?';

  @override
  String get settings_dialog_final_confirm_button => 'Permanently Delete All';

  @override
  String get settings_dialog_error_enter_desc =>
      'Please enter a description for each expense';

  @override
  String get settings_dialog_error_enter_income_desc =>
      'Please enter a description for each income';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Day';

  @override
  String get settings_theme_dark => 'Night';

  @override
  String get settings_language_he => 'עברית';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_current_rate => 'Current Rate';

  @override
  String get settings_wage_history_title => 'Wage History';

  @override
  String get settings_job_name_label => 'Job Name';

  @override
  String get settings_job_rate_label => 'Hourly Rate (New)';

  @override
  String get home_empty_state_title => 'No shifts registered yet';

  @override
  String get home_empty_state_subtitle => 'Click \"New Shift\" to get started';

  @override
  String get home_total_card_title => 'Total Accumulated (Net less expenses)';

  @override
  String get home_total_card_hours => 'Hours';

  @override
  String get home_total_card_base => 'Base';

  @override
  String get home_total_card_tips => 'Tips';

  @override
  String get home_total_card_expenses => 'Expenses';

  @override
  String get home_active_timer_break => 'Shift on break...';

  @override
  String get home_active_timer_active => 'Active Shift:';

  @override
  String get home_active_timer_time => 'Time:';

  @override
  String get home_shift_list_net_total => 'Net Total';

  @override
  String get home_shift_list_no_shifts => 'No shifts on this day';

  @override
  String get home_shift_list_select_day => 'Select a day to show shifts';

  @override
  String get home_shift_list_shifts_on => 'Shifts on ';

  @override
  String get home_action_new_shift => 'New Shift';

  @override
  String get home_action_calendar => 'Calendar';

  @override
  String get expenses_title => 'Expenses & Incomes';

  @override
  String get expenses_tab_expenses => 'Expenses';

  @override
  String get expenses_tab_incomes => 'Special Incomes';

  @override
  String get expenses_auto_section_title => 'Recurring Shift Expenses';

  @override
  String get expenses_auto_section_subtitle =>
      'Add recurring expenses to each new shift';

  @override
  String get expenses_auto_section_enable => 'Auto Expenses';

  @override
  String get expenses_history_section_title => 'Monthly Expense Breakdown';

  @override
  String get expenses_action_add_auto => 'Add Recurring Expense';

  @override
  String get expenses_action_update_settings => 'Update Settings';

  @override
  String get expenses_action_new_expense => 'New Expense';

  @override
  String get expenses_dialog_add_title => 'Add Expense';

  @override
  String get expenses_dialog_edit_title => 'Edit Expense';

  @override
  String get expenses_dialog_delete_title => 'Delete Expense';

  @override
  String get expenses_no_history => 'No expenses recorded';

  @override
  String get expenses_delete_expense_confirm_content =>
      'Delete \"[[desc]]\" for [[amount]]?';

  @override
  String get expenses_total_label => 'Total';

  @override
  String get expenses_auto_updated_msg => 'Auto expense settings updated';

  @override
  String get expenses_deleted_msg => 'Expense deleted';

  @override
  String get expenses_link_shift_dialog_title => 'Link to Shift';

  @override
  String get expenses_link_shift_dialog_content =>
      'A shift was found on this date. Would you like to link this [[type]] to the shift or save it as standalone?';

  @override
  String get expenses_link_shift_button => 'Link to Shift';

  @override
  String get expenses_save_standalone_button => 'Save Standalone';

  @override
  String get expenses_no_shift_dialog_title => 'No Shift Found';

  @override
  String get expenses_no_shift_dialog_content =>
      'There is no shift on this date. Do you still want to create this [[type]]?';

  @override
  String get expenses_create_anyway_button => 'Create Anyway';

  @override
  String get expenses_auto_incomes_updated_msg =>
      'Auto income settings updated';

  @override
  String get expenses_auto_incomes_section_title => 'Recurring Shift Incomes';

  @override
  String get expenses_auto_incomes_section_subtitle =>
      'Add recurring incomes to each new shift';

  @override
  String get expenses_auto_incomes_section_enable => 'Auto Incomes';

  @override
  String get incomes_history_section_title => 'Monthly Income Breakdown';

  @override
  String get incomes_action_new_income => 'New Income';

  @override
  String get incomes_dialog_add_title => 'Add Special Income';

  @override
  String get incomes_dialog_edit_title => 'Edit Income';

  @override
  String get incomes_dialog_delete_title => 'Delete Income';

  @override
  String get incomes_no_history => 'No special incomes recorded';

  @override
  String get incomes_delete_income_confirm_content =>
      'Delete \"[[desc]]\" for [[amount]]?';

  @override
  String get incomes_deleted_msg => 'Income deleted';

  @override
  String get add_shift_title => 'New Shift';

  @override
  String get add_shift_edit_title => 'Edit Shift';

  @override
  String get add_shift_timer_tab => 'Timer';

  @override
  String get add_shift_manual_tab => 'Manual';

  @override
  String get add_shift_paste_tab => 'Paste';

  @override
  String get add_shift_timer_accumulated_live => 'Accumulated Live';

  @override
  String get add_shift_timer_countdown => 'Countdown: ';

  @override
  String get add_shift_timer_break_paid => 'On paid break...';

  @override
  String get add_shift_timer_break_unpaid => 'On unpaid break (timer stopped)';

  @override
  String get add_shift_timer_total_break_unpaid => 'Total Unpaid Break:';

  @override
  String get add_shift_timer_resume_work => 'Back to work';

  @override
  String get add_shift_timer_stop_shift => 'Stop Shift';

  @override
  String get add_shift_timer_start_shift => 'Start Shift';

  @override
  String get add_shift_timer_continue_work => 'Continue Work';

  @override
  String get add_shift_timer_stopped_msg =>
      'The timer stopped. Would you like to save the shift or continue working?';

  @override
  String get add_shift_timer_reset_title => 'Reset Timer';

  @override
  String get add_shift_timer_reset_desc =>
      'Are you sure you want to reset the timer? All current data will be lost.';

  @override
  String get add_shift_manual_time_section => 'Time';

  @override
  String get add_shift_manual_date_label => 'Date';

  @override
  String get add_shift_manual_start_time_label => 'Start Time';

  @override
  String get add_shift_manual_end_time_label => 'End Time';

  @override
  String get add_shift_manual_break_type_section => 'Break Type';

  @override
  String get add_shift_manual_no_break => 'None';

  @override
  String get add_shift_manual_paid_break => 'Paid';

  @override
  String get add_shift_manual_unpaid_break => 'Unpaid';

  @override
  String get add_shift_manual_work_tips_section => 'Work & Tips';

  @override
  String get add_shift_manual_job_type_label => 'Job Type';

  @override
  String get add_shift_paste_title => 'Paste Shift Text';

  @override
  String get add_shift_paste_default_job_label => 'Default Job Type';

  @override
  String get add_shift_paste_format_info =>
      'Format: DD.MM.YYYY - HH:mm - HH:mm [break] [+ tips]\nBreaks: none / 20 minutes / 45 minutes';

  @override
  String get add_shift_paste_hint =>
      'Paste shifts here...\nExample:\n24.6.2026 - 17:30 - 23:00 45 minutes + 50';

  @override
  String get add_shift_paste_parse_button => 'Parse & Save All';

  @override
  String get add_shift_paste_parse_dialog_title => 'Parse Shifts';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'Parse and save shifts from the pasted text?';

  @override
  String get add_shift_paste_error => 'Please check the format and try again';

  @override
  String get add_shift_tips_title => 'Tips';

  @override
  String get add_shift_tips_total => 'Total';

  @override
  String get add_shift_tips_hint => 'Tip amount';

  @override
  String get add_shift_tips_add_button => 'Add Tip';

  @override
  String get add_shift_expenses_title => 'Shift Expenses';

  @override
  String get add_shift_expenses_total => 'Total';

  @override
  String get add_shift_expenses_add_button => 'Add Expense';

  @override
  String get add_shift_incomes_title => 'Shift Incomes';

  @override
  String get add_shift_incomes_total => 'Total';

  @override
  String get add_shift_incomes_add_button => 'Add Income';

  @override
  String get add_shift_shift_ended_dialog_title => 'Save Shift';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'Are you sure you want to save the shift details?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'Are you sure you want to save the shift details?';

  @override
  String get add_shift_shift_edit_dialog_title => 'Update Shift';

  @override
  String get add_shift_shift_saved => 'Shift saved successfully';

  @override
  String get add_shift_overlap_title => 'Overlapping shift';

  @override
  String add_shift_overlap_content(num count, String details) {
    return 'This shift overlaps $count existing shift(s):\n\n$details\n\nSave it anyway?';
  }

  @override
  String get add_shift_overlap_confirm => 'Save anyway';

  @override
  String get add_shift_overlap_unknown_job => 'Unknown job';

  @override
  String get add_shift_pick_a_job => 'Please select a job type first';

  @override
  String get add_shift_delete_title => 'Delete Shift';

  @override
  String get add_shift_delete_desc =>
      'Are you sure you want to delete the shift from';

  @override
  String get add_shift_delete_msg => 'Shift deleted successfully';

  @override
  String get notification_timer_channel_name => 'Active Shift';

  @override
  String get notification_timer_channel_desc => 'Shows current shift timer';

  @override
  String get notification_timer_title_active => 'Active Shift';

  @override
  String get notification_timer_title_paid_break => 'Paid Break';

  @override
  String get notification_timer_title_unpaid_break => 'Unpaid Break';

  @override
  String get notification_timer_body_running => 'Timer running...';

  @override
  String get notification_timer_body_countdown => 'Countdown: [[time]]';

  @override
  String get filter_title => 'Shift Filters';

  @override
  String get filter_clear_all => 'Reset Filter';

  @override
  String get filter_apply => 'Apply Filters';

  @override
  String get filter_wage_range => 'Total Wage Range';

  @override
  String get filter_tips_range => 'Tips Range';

  @override
  String get filter_expenses_range => 'Expenses Range';

  @override
  String get filter_duration_range => 'Duration Range (Hours)';

  @override
  String get filter_date_range => 'Date Range';

  @override
  String get filter_job_type => 'Job Type';

  @override
  String get filter_select_all => 'Select All';

  @override
  String get filter_error_no_job_selected =>
      'Please select at least one job type';

  @override
  String get filter_active_filters => 'Active Filters:';

  @override
  String get filter_chip_wage => 'Wage: [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'Tips: [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'Expenses: [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'Duration: [[min]] - [[max]] h';

  @override
  String get filter_chip_date => 'Date: [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'Job: [[name]]';

  @override
  String get filter_empty_state_title => 'No matching shifts';

  @override
  String get filter_empty_state_subtitle =>
      'Try adjusting your filters to see more results';

  @override
  String get auth_login_title => 'Welcome Back';

  @override
  String get auth_register_title => 'Create New Account';

  @override
  String get auth_full_name_label => 'Full Name';

  @override
  String get auth_email_label => 'Email';

  @override
  String get auth_password_label => 'Password';

  @override
  String get auth_error_name_empty => 'Please enter name';

  @override
  String get auth_error_email_invalid => 'Invalid email';

  @override
  String get auth_error_password_length =>
      'Password must be at least 6 characters';

  @override
  String get auth_login_button => 'Login';

  @override
  String get auth_register_button => 'Register';

  @override
  String get auth_no_account_link => 'No account? Register now';

  @override
  String get auth_has_account_link => 'Already have an account? Login';

  @override
  String get auth_error_generic => 'An error occurred. Please try again.';

  @override
  String get settings_logout_title => 'Logout from system';

  @override
  String get settings_logout_dialog_title => 'Logout';

  @override
  String get settings_logout_confirm_content =>
      'Are you sure you want to logout?';

  @override
  String get settings_logout_confirm_button => 'Logout';

  @override
  String get auth_login_success => 'Login successful';

  @override
  String get auth_register_success => 'Account created successfully';

  @override
  String get auth_birth_date_label => 'Date of Birth';

  @override
  String get auth_error_underage => 'User must be at least 12 years old';

  @override
  String get auth_error_birth_date_empty => 'Please select your date of birth';

  @override
  String get auth_error_email_exists => 'This email address is already taken';

  @override
  String get auth_error_user_not_found =>
      'User not found or incorrect password';

  @override
  String get auth_error_network =>
      'Network connection error. Please check your internet connection and try again.';

  @override
  String get auth_continue_as_guest => 'Continue as Guest';

  @override
  String get auth_replace_guest_data_title => 'Replace Guest Data?';

  @override
  String get auth_replace_guest_data_message =>
      'Logging into an existing account will replace the data currently stored on this device with the data associated with your account. Your guest data may be permanently lost and cannot be recovered unless you have a backup. Make sure you understand these consequences before continuing.';

  @override
  String get auth_replace_guest_data_confirm => 'Continue';

  @override
  String get auth_replace_guest_data_cancel => 'Cancel';

  @override
  String get auth_guest_mode_title => 'Guest Mode';

  @override
  String get auth_guest_mode_subtitle =>
      'You are using Shiftly in Guest Mode. Your data is saved locally on this device. Create an account to sync across devices or log in to an existing account.';

  @override
  String get auth_guest_migration_failed =>
      'Failed to retrieve account data. Your guest data has been preserved.';

  @override
  String get auth_register_guest_transfer =>
      'Sign In or Create Shiftly Account';

  @override
  String get home_welcome_back => 'Hello, [[name]]';

  @override
  String get settings_user_name => 'Name';

  @override
  String get settings_user_email => 'Email';

  @override
  String get settings_user_password => 'Password';

  @override
  String get settings_user_edit_title => 'Edit Profile';

  @override
  String get settings_user_update_success => 'Profile updated successfully';

  @override
  String get settings_logout_success => 'Logged out successfully';

  @override
  String get settings_byos_title => 'BYOS Sync';

  @override
  String get settings_byos_connected => 'Connected to Google Drive';

  @override
  String get settings_byos_last_backup => 'Last backup: [[time]]';

  @override
  String get settings_byos_backup_now => 'Backup Now';

  @override
  String get settings_byos_auto_sync => 'Auto Sync';

  @override
  String get settings_byos_auto_sync_sub => 'Instantly backup changes to cloud';

  @override
  String get settings_byos_disconnect => 'Disconnect';

  @override
  String get settings_byos_login_shiftly => 'Login to Shiftly Account';

  @override
  String get settings_byos_login_shiftly_sub => 'Full sync in our cloud';

  @override
  String get settings_byos_method_title => 'BYOS Method (Google Drive)';

  @override
  String get settings_byos_method_sub => 'Backup to your private cloud';

  @override
  String get settings_byos_restore_dialog_title => 'BYOS Sync';

  @override
  String get settings_byos_restore_dialog_content =>
      'Would you like to restore existing data from your Google Drive?';

  @override
  String get settings_byos_restore_confirm => 'Restore';

  @override
  String get settings_byos_restore_cancel => 'Not now';

  @override
  String get settings_byos_login_hint =>
      'Login to backup data to cloud and use more devices';

  @override
  String get settings_restore_success =>
      'Restore successful: [[shifts]] shifts and [[jobs]] jobs restored.';

  @override
  String get settings_restore_no_data =>
      'No backup found on Google Drive or an error occurred.';

  @override
  String get export_title => 'Export Shifts';

  @override
  String get export_format_label => 'File Format';

  @override
  String get export_format_csv => 'CSV (Excel Compatible)';

  @override
  String get export_format_txt => 'Text File (TXT)';

  @override
  String get export_range_label => 'Export Range';

  @override
  String get export_range_all => 'All Shifts';

  @override
  String get export_range_month => 'Specific Month';

  @override
  String get export_range_custom => 'Custom Date Range';

  @override
  String get export_start_date => 'Start Date';

  @override
  String get export_end_date => 'End Date';

  @override
  String get export_select_month => 'Select Month';

  @override
  String get export_button => 'Export File';

  @override
  String get export_success_msg => 'File exported successfully and saved at:';

  @override
  String get export_empty_error =>
      'No shifts found in the selected range for export';

  @override
  String get analytics_title => 'Analytics & Insights';

  @override
  String get analytics_period_monthly => 'Monthly';

  @override
  String get analytics_period_yearly => 'Yearly';

  @override
  String get analytics_period_all_time => 'All Time';

  @override
  String get analytics_all_jobs => 'All Jobs';

  @override
  String get analytics_stat_total_net => 'Total Net';

  @override
  String get analytics_stat_total_hours => 'Total Hours';

  @override
  String get analytics_stat_avg_rate => 'Avg Effective Rate';

  @override
  String get analytics_stat_tips => 'Net Shift Expenses';

  @override
  String get analytics_chart_earnings_title => 'Earnings vs Expenses Over Time';

  @override
  String get analytics_chart_earnings_subtitle =>
      'Tap a bar to see pay and expense breakdown';

  @override
  String get analytics_chart_jobs_title => 'Breakdown by Job';

  @override
  String get analytics_chart_jobs_by_earnings => 'By Earnings';

  @override
  String get analytics_chart_jobs_by_hours => 'By Hours';

  @override
  String get analytics_no_data => 'No data for selected period';

  @override
  String get analytics_selected_breakdown => 'Selected Day Details';

  @override
  String get analytics_selected_month_breakdown => 'Selected Month Details';

  @override
  String get analytics_base_salary => 'Base Pay';

  @override
  String get analytics_chart_cumulative_title => 'Cumulative Earnings Growth';

  @override
  String get analytics_chart_cumulative_subtitle =>
      'Scroll horizontally to view pay growth over time';

  @override
  String get analytics_gross_pay => 'Gross';

  @override
  String get analytics_net_pay => 'Net';

  @override
  String get analytics_kpi_projected => 'Projected EOM Pay';

  @override
  String get analytics_kpi_retention => 'Net Retention Rate';

  @override
  String get analytics_chart_tod_title => 'Time of Day Breakdown';

  @override
  String get analytics_chart_tod_subtitle =>
      'Comparing hours across time of day segments';

  @override
  String get analytics_chart_tod_dawn => 'Dawn (04:00-06:00)';

  @override
  String get analytics_chart_tod_morning => 'Morning (06:00-12:00)';

  @override
  String get analytics_chart_tod_noon => 'Noon (12:00-16:00)';

  @override
  String get analytics_chart_tod_afternoon => 'Afternoon (16:00-18:00)';

  @override
  String get analytics_chart_tod_evening => 'Evening (18:00-22:00)';

  @override
  String get analytics_chart_tod_night => 'Night (22:00-06:00)';

  @override
  String get analytics_chart_duration_title =>
      'Shift Length & Fatigue Breakdown';

  @override
  String get analytics_chart_duration_subtitle =>
      'Distribution of shift lengths (short, standard, long)';

  @override
  String get analytics_duration_short => 'Short (<6h)';

  @override
  String get analytics_duration_standard => 'Standard (6-9h)';

  @override
  String get analytics_duration_long => 'Long (>9h)';

  @override
  String get analytics_insights_title => 'Key Smart Insights';

  @override
  String get analytics_insight_night_boost =>
      'Evening & night shifts make up [[percent]]% of your working hours.';

  @override
  String get analytics_insight_retention =>
      'You retain [[percent]]% of gross earnings after shift expenses.';

  @override
  String get analytics_insight_fatigue =>
      '[[percent]]% of your shifts were longer than 9 hours.';

  @override
  String get analytics_insight_tips_ratio =>
      'Recurring expenses account for [[percent]]% of your total earnings.';

  @override
  String analytics_shifts_format(Object count) {
    return '$count shifts';
  }

  @override
  String get analytics_no_shift_data_period => 'No shift data for this period';

  @override
  String get analytics_min_shifts_hourly =>
      'At least 2 shifts required to show hourly wage trend';

  @override
  String get analytics_min_shifts_growth =>
      'At least 2 shifts required to show cumulative growth';

  @override
  String get analytics_min_shifts_retention =>
      'At least 2 shifts required to show net retention trend';

  @override
  String get analytics_no_job_data => 'No job data';

  @override
  String analytics_hours_suffix_format(Object hours) {
    return '$hours hrs';
  }

  @override
  String analytics_utilization_format(Object pct) {
    return '$pct% utilization';
  }

  @override
  String get common_previous => 'Previous';

  @override
  String get common_next => 'Next';

  @override
  String get analytics_tips_and_extra => 'Tips & Extra';

  @override
  String analytics_rate_boost_subtitle(Object boost) {
    return '+$boost/h net extras';
  }

  @override
  String get analytics_retention_subtitle => 'Retained after shift expenses';

  @override
  String analytics_net_extras_pct_subtitle(Object percent) {
    return '$percent% of total net pay';
  }

  @override
  String get common_unknown_job => 'Unknown Job';

  @override
  String get analytics_duration_range_short => '< 6 hours';

  @override
  String get analytics_duration_range_standard => '6-9 hours';

  @override
  String get analytics_duration_range_long => '> 9 hours';

  @override
  String get profile_title => 'User Profile';

  @override
  String get profile_created_at => 'Account created: [[date]]';

  @override
  String get profile_birth_date_display =>
      'Date of birth: [[date]] (Age: [[age]])';

  @override
  String get profile_stats_title => 'Saved Data Summary';

  @override
  String get profile_shifts_count => 'Shifts Saved';

  @override
  String get profile_jobs_count => 'Roles / Job Types';

  @override
  String get profile_expenses_count => 'Expenses Saved';

  @override
  String get profile_incomes_count => 'Incomes Saved';

  @override
  String get side_menu_profile => 'User Profile';

  @override
  String get profile_old_password => 'Current Password';

  @override
  String get profile_new_password => 'New Password';

  @override
  String get profile_password_error => 'Current password is incorrect';

  @override
  String get profile_password_required => 'Please enter your current password';

  @override
  String get shift_descriptions_title => 'Shift Summaries';

  @override
  String get shift_descriptions_empty => 'No shift summaries found';

  @override
  String get shift_description_label => 'Shift Summary / Description';

  @override
  String get shift_description_hint =>
      'Enter notes or summary for this shift...';

  @override
  String get common_search_by_date => 'Search by date';

  @override
  String get common_clear_date_filter => 'Clear date filter';

  @override
  String get common_filter_date => 'Filter Date';

  @override
  String get profile_delete_account => 'Delete Account';

  @override
  String get profile_delete_account_sub =>
      'Permanently delete your Shiftly user account';

  @override
  String get profile_delete_dialog_title => 'Delete Account';

  @override
  String get profile_delete_dialog_content =>
      'Are you sure you want to delete your Shiftly account? This action cannot be undone.';

  @override
  String get profile_delete_final_title => 'Final Confirmation';

  @override
  String get profile_delete_final_content_1 =>
      'Your user account and all server data will be permanently deleted.';

  @override
  String get profile_delete_final_content_2 =>
      'This action is irreversible. Proceed with account deletion?';

  @override
  String get profile_delete_success => 'Account deleted successfully';

  @override
  String get settings_byos_delete_title => 'Delete BYOS Backup';

  @override
  String get settings_byos_delete_sub =>
      'Permanently erase backup file from Google Drive';

  @override
  String get settings_byos_delete_dialog_title => 'Delete BYOS Data';

  @override
  String get settings_byos_delete_dialog_content =>
      'Are you sure you want to delete your backup data from Google Drive?';

  @override
  String get settings_byos_delete_final_title => 'Final Warning';

  @override
  String get settings_byos_delete_final_content_1 =>
      'Your backup file in Google Drive will be completely destroyed.';

  @override
  String get settings_byos_delete_final_content_2 =>
      'Are you sure you want to permanently delete BYOS backup data?';

  @override
  String get settings_byos_delete_success =>
      'BYOS backup data deleted successfully';

  @override
  String get add_shift_wage_segments_title =>
      'Hourly Wage Percentage Segments (Optional)';

  @override
  String get add_shift_wage_segments_subtitle =>
      'Define periods with different wage percentages (e.g. 150%)';

  @override
  String get add_shift_wage_segments_add => 'Add Period';

  @override
  String get add_shift_wage_segment_start => 'Start';

  @override
  String get add_shift_wage_segment_end => 'End';

  @override
  String get add_shift_wage_segment_percentage => 'Wage %';

  @override
  String get error_segment_invalid_time =>
      'Segment end time must be after start time';

  @override
  String get error_segment_overlap => 'There is an overlap in time ranges';

  @override
  String get legal_privacy_policy => 'Privacy Policy';

  @override
  String get legal_terms_of_service => 'Terms of Service';

  @override
  String get legal_disclaimer_notice =>
      'By registering or logging in, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get legal_cookie_title => 'Cookie & Privacy Preferences';

  @override
  String get legal_cookie_description =>
      'We use local storage technologies and cookies for essential authentication, security, and app crash telemetry. You can choose to accept all or use necessary cookies only.';

  @override
  String get legal_cookie_accept_all => 'Accept All';

  @override
  String get legal_cookie_necessary_only => 'Necessary Only';

  @override
  String get legal_cookie_necessary_desc =>
      'Essential for authentication, secure token storage, and session preferences.';

  @override
  String get legal_cookie_analytics_desc =>
      'Anonymous error logs and crash performance telemetry via Firebase.';

  @override
  String get legal_cookie_customize => 'Customize';

  @override
  String get legal_cookie_save_preferences => 'Save Preferences';

  @override
  String get legal_cookie_essential => 'Essential & Security Cookies';

  @override
  String get legal_cookie_always_active => 'Always Active';

  @override
  String get legal_cookie_optional => 'Optional';

  @override
  String get common_close => 'Close';

  @override
  String get settings_section_overtime => 'Overtime Rules';

  @override
  String get settings_overtime_enable => 'Enable Overtime Calculation';

  @override
  String get settings_overtime_enable_sub =>
      'Automatically calculate tiered overtime compensation';

  @override
  String get settings_overtime_regular_threshold =>
      'Regular Hours Threshold (hours)';

  @override
  String get settings_overtime_tier1_limit =>
      'First Overtime Tier Duration (hours)';

  @override
  String get settings_overtime_tier1_rate => 'First Tier Multiplier (%)';

  @override
  String get settings_overtime_tier2_rate => 'Additional Tier Multiplier (%)';

  @override
  String get settings_overtime_update_button => 'Save Overtime Rules';

  @override
  String get settings_overtime_saved => 'Overtime rules updated successfully';

  @override
  String get overtime_notification_detected =>
      'The shift includes overtime. Salary was calculated according to overtime rates.';

  @override
  String get overtime_breakdown_title => 'Salary Breakdown';

  @override
  String get overtime_regular_hours_label => 'Regular hours';

  @override
  String get overtime_tier1_label => 'Overtime (125%)';

  @override
  String get overtime_tier2_label => 'Overtime (150%)';

  @override
  String get overtime_tier_custom_label => 'Overtime ([[rate]]%)';

  @override
  String get overtime_tag_label => 'Overtime';

  @override
  String get overtime_total_paid_time => 'Total paid time';

  @override
  String get overtime_total_earnings => 'Total shift earnings';

  @override
  String get overtime_unpaid_break => 'Unpaid break';

  @override
  String get analytics_overtime_section_title => 'Overtime Summary & Hours';

  @override
  String get analytics_regular_hours => 'Regular Hours';

  @override
  String get analytics_overtime_hours => 'Overtime Hours';

  @override
  String get analytics_overtime_earnings => 'Overtime Earnings';

  @override
  String get shabbat_tag_label => 'Shabbat';

  @override
  String get holiday_tag_label => 'Holiday';

  @override
  String get settings_shabbat_section => 'Shabbat & Holidays';

  @override
  String get settings_shabbat_enable =>
      'Automatic Shabbat & Holiday calculation';

  @override
  String get settings_shabbat_enable_sub =>
      'Automatic detection of Shabbat, holidays, and special rates';

  @override
  String get settings_shabbat_multiplier_label => 'Shabbat Rate (%)';

  @override
  String get settings_holiday_multiplier_label => 'Holiday Rate (%)';

  @override
  String get settings_candle_lighting_label =>
      'Candle lighting minutes before sunset';

  @override
  String get settings_shabbat_exit_label => 'Shabbat exit minutes after sunset';

  @override
  String get settings_shabbat_saved =>
      'Shabbat & Holiday settings saved successfully';

  @override
  String get settings_shabbat_save_button => 'Save Shabbat & Holiday settings';

  @override
  String get analytics_shabbat_holiday_summary => 'Shabbat & Holidays Summary';

  @override
  String get analytics_shabbat_hours => 'Shabbat Hours';

  @override
  String get analytics_holiday_hours => 'Holiday Hours';

  @override
  String get onboarding_shabbat_title => 'Shabbat & Jewish Holidays';

  @override
  String get onboarding_shabbat_subtitle =>
      'Automatic detection of Shabbat, holidays, and special rates';

  @override
  String add_shift_unknown_job_title(Object trailingText) {
    return 'Unrecognized shift type: \"$trailingText\"';
  }

  @override
  String get add_shift_unknown_job_desc =>
      'Found a job type that does not exist in your job types list. Choose an alternative job type or save as description:';

  @override
  String get add_shift_select_job_label => 'Select job type';

  @override
  String get add_shift_apply_all_instances =>
      'Apply automatically to all instances of this type';

  @override
  String get add_shift_skip => 'Skip';

  @override
  String get add_shift_save_as_desc => 'Save as description only';

  @override
  String get add_shift_assign => 'Assign';

  @override
  String add_shift_shabbat_breakdown(Object rate) {
    return 'Shabbat ($rate%)';
  }

  @override
  String add_shift_holiday_breakdown(Object name, Object rate) {
    return '$name ($rate%)';
  }

  @override
  String get settings_update_section => 'App Updates';

  @override
  String get settings_update_check_button => 'Check for updates from GitHub';

  @override
  String settings_update_current_version(String version) {
    return 'Current version: v$version';
  }

  @override
  String get settings_update_checking_toast =>
      'Checking for updates from GitHub Releases...';

  @override
  String get settings_update_error_toast =>
      'Unable to connect to GitHub. Please try again later.';

  @override
  String settings_update_latest_toast(String version) {
    return 'The app is up to date! (v$version)';
  }

  @override
  String get update_dialog_title => 'New Version Available!';

  @override
  String update_dialog_version_available(String version) {
    return 'Version $version is available for download';
  }

  @override
  String update_dialog_installed_version(String version) {
    return 'Installed version: $version';
  }

  @override
  String update_dialog_new_version(String version) {
    return 'New: $version';
  }

  @override
  String get update_dialog_whats_new => 'What\'s new in this version:';

  @override
  String get update_dialog_downloading => 'Downloading update file...';

  @override
  String get update_dialog_later => 'Later';

  @override
  String get update_dialog_open_browser => 'Open in Browser';

  @override
  String get update_dialog_update_now => 'Update Now';

  @override
  String get update_dialog_open_download => 'Open Download Page';

  @override
  String get update_dialog_mandatory_notice =>
      'This update is required to continue using the app.';

  @override
  String get update_service_no_changelog => 'No changelog details available.';

  @override
  String update_service_download_failed(Object statusCode) {
    return 'File download failed (Error code: $statusCode)';
  }

  @override
  String get update_service_no_installer =>
      'No app found to install APK files on device. Try opening in browser.';

  @override
  String update_service_cannot_launch_installer(String message) {
    return 'Unable to launch package installer ($message)';
  }

  @override
  String update_service_download_error(Object error) {
    return 'Error during update download: $error';
  }

  @override
  String get common_show_password => 'Show password';

  @override
  String get common_hide_password => 'Hide password';

  @override
  String get accessibility_statement => 'Accessibility Statement';

  @override
  String get settings_accessibility_sub =>
      'Accessibility info and contact details';
}
