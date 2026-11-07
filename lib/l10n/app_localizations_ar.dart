// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_start => 'لنبدأ!';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_error => 'خطأ';

  @override
  String get common_success => 'نجاح';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_tagline => 'محرك الرواتب والورديات';

  @override
  String get nav_calendar => 'التقويم';

  @override
  String get nav_analytics => 'التحليلات';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_expenses => 'المصروفات';

  @override
  String get nav_summaries => 'الملخصات';

  @override
  String get common_hours_suffix => 'ساعات';

  @override
  String get common_min_suffix => 'دقيقة';

  @override
  String get common_net => 'صافي';

  @override
  String get common_shifts_count => 'الورديات';

  @override
  String get common_save_and_finish => 'حفظ وإنهاء';

  @override
  String get common_reset => 'إعادة تعيين';

  @override
  String get common_reset_and_cancel => 'إلغاء وإعادة تعيين';

  @override
  String get onboarding_welcome_title => 'مرحباً بك في Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'التطبيق الذي يساعدك على تتبع وردياتك وراتبك والإكراميات بسهولة ودقة.';

  @override
  String get onboarding_welcome_description =>
      'دعنا نضبط بعض الإعدادات الأساسية للبدء.';

  @override
  String onboarding_step_progress(Object current, Object total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboarding_skip_setup => 'تخطي الإعداد';

  @override
  String get onboarding_language_title => 'لغة التطبيق';

  @override
  String get onboarding_language_subtitle => 'اختر لغتك المفضلة.';

  @override
  String get onboarding_currency_title => 'اختر العملة';

  @override
  String get onboarding_currency_subtitle =>
      'ما هي العملة التي تفضل استخدامها للراتب والمصروفات؟';

  @override
  String get monthly_progress_setting_title => 'معنى خط التقدم';

  @override
  String get monthly_progress_mode_month => 'الوقت المنقضي في الشهر';

  @override
  String get monthly_progress_mode_financial_goal => 'التقدم نحو هدف مالي';

  @override
  String get monthly_progress_goal_amount => 'مبلغ الهدف الشهري';

  @override
  String get monthly_progress_invalid_goal => 'أدخل هدفاً مالياً أكبر من الصفر';

  @override
  String get monthly_progress_month_elapsed => 'تقدم الشهر';

  @override
  String get monthly_progress_financial_goal => 'تقدم الهدف';

  @override
  String get onboarding_breaks_title => 'إعدادات الاستراحات';

  @override
  String get onboarding_breaks_subtitle => 'كم تستغرق الاستراحة عادة؟';

  @override
  String get onboarding_breaks_enable => 'تفعيل الاستراحات';

  @override
  String get onboarding_breaks_paid_label => 'استراحة مدفوعة (دقائق)';

  @override
  String get onboarding_breaks_unpaid_label => 'استراحة غير مدفوعة (دقائق)';

  @override
  String get onboarding_auto_expenses_title => 'المصروفات المتكررة';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'هل لديك مصروفات متكررة في كل وردية؟ (مثل المواصلات)';

  @override
  String get onboarding_auto_expenses_enable => 'تفعيل المصروفات التلقائية';

  @override
  String get onboarding_auto_expenses_add_button => 'إضافة مصروف';

  @override
  String get onboarding_auto_expenses_desc_label => 'الوصف';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'يجب أن يكون المبلغ أكبر من 0';

  @override
  String get onboarding_auto_incomes_title => 'الإيرادات المتكررة';

  @override
  String get onboarding_auto_incomes_subtitle =>
      'هل لديك إيرادات متكررة في كل وردية؟ (مثل بدل المواصلات)';

  @override
  String get onboarding_auto_incomes_enable => 'تفعيل الإيرادات التلقائية';

  @override
  String get onboarding_auto_incomes_add_button => 'إضافة إيراد';

  @override
  String get onboarding_job_types_title => 'الورديات والأجور';

  @override
  String get onboarding_job_types_subtitle =>
      'حدد أدوارك المختلفة ومعدلات الأجور بالساعة.';

  @override
  String get onboarding_job_types_add_button => 'إضافة نوع وردية';

  @override
  String get onboarding_job_types_edit_button => 'تعديل نوع الوردية';

  @override
  String get onboarding_job_types_delete_title => 'حذف الوظيفة';

  @override
  String get onboarding_job_types_delete_desc => 'حذف الوظيفة ';

  @override
  String get onboarding_job_types_rate_suffix => 'في الساعة';

  @override
  String get onboarding_job_types_same => 'توجد وظيفة بهذا الاسم بالفعل';

  @override
  String get default_job_buffet => 'بوفيه';

  @override
  String get default_job_steward => 'ستيوارد';

  @override
  String get default_job_unloading => 'تفريغ بضائع';

  @override
  String get default_expenses_trips => 'مواصلات';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_section_app => 'التطبيق';

  @override
  String get settings_section_work_pay => 'العمل والأجر';

  @override
  String get settings_section_breaks => 'مدد الاستراحات (دقائق)';

  @override
  String get settings_section_danger => 'منطقة الخطر';

  @override
  String get settings_field_theme => 'المظهر';

  @override
  String get settings_field_language => 'لغة التطبيق';

  @override
  String get settings_field_currency => 'عملة العرض';

  @override
  String get settings_field_currency_sub =>
      'العملة المستخدمة للراتب والمصروفات';

  @override
  String get settings_field_breaks_enabled => 'تفعيل الاستراحات';

  @override
  String get settings_field_breaks_enabled_sub =>
      'إظهار أو إخفاء إعدادات الاستراحة في التطبيق';

  @override
  String get settings_field_paid_break => 'استراحة قصيرة (مدفوعة)';

  @override
  String get settings_field_unpaid_break => 'استراحة طويلة (غير مدفوعة)';

  @override
  String get settings_action_update_breaks => 'تحديث الأوقات';

  @override
  String get settings_action_factory_reset => 'إعادة ضبط المصنع بالكامل';

  @override
  String get settings_action_factory_reset_sub =>
      'حذف جميع الورديات والأدوار والمصروفات نهائياً';

  @override
  String get settings_dialog_update_breaks_title => 'تحديث أوقات الاستراحة';

  @override
  String get settings_dialog_factory_reset_title => 'إعادة ضبط البيانات؟';

  @override
  String get settings_dialog_factory_reset_content =>
      'هل أنت متأكد من رغبتك في حذف جميع بيانات العمل وإعادة ضبط التطبيق؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settings_dialog_final_confirm_title => 'التأكيد النهائي';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'تحذير: سيتم حذف سجل الورديات والراتب والمصروفات نهائياً.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'هل أنت متأكد من رغبتك في حذف كل شيء؟';

  @override
  String get settings_dialog_final_confirm_button => 'حذف الكل نهائياً';

  @override
  String get settings_dialog_error_enter_desc => 'الرجاء إدخال وصف لكل مصروف';

  @override
  String get settings_dialog_error_enter_income_desc =>
      'الرجاء إدخال وصف لكل إيراد';

  @override
  String get settings_theme_system => 'النظام';

  @override
  String get settings_theme_light => 'نهاري';

  @override
  String get settings_theme_dark => 'ليلي';

  @override
  String get settings_language_he => 'עברית';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_fr => 'Français';

  @override
  String get settings_language_es => 'Español';

  @override
  String get settings_language_ru => 'Русский';

  @override
  String get settings_language_ar => 'العربية';

  @override
  String get settings_current_rate => 'المعدل الحالي';

  @override
  String get settings_wage_history_title => 'سجل الأجور';

  @override
  String get settings_job_name_label => 'اسم الوظيفة';

  @override
  String get settings_job_rate_label => 'الأجر بالساعة (جديد)';

  @override
  String get home_empty_state_title => 'لم يتم تسجيل أي ورديات بعد';

  @override
  String get home_empty_state_subtitle => 'انقر على \"وردية جديدة\" للبدء';

  @override
  String get home_total_card_title =>
      'المجموع المتراكم (الصافي ناقص المصروفات)';

  @override
  String get home_total_card_hours => 'الساعات';

  @override
  String get home_total_card_base => 'الأساسي';

  @override
  String get home_total_card_tips => 'الإكراميات';

  @override
  String get home_total_card_expenses => 'المصروفات';

  @override
  String get home_active_timer_break => 'الوردية في استراحة...';

  @override
  String get home_active_timer_active => 'الوردية النشطة:';

  @override
  String get home_active_timer_time => 'الوقت:';

  @override
  String get home_shift_list_net_total => 'المجموع الصافي';

  @override
  String get home_shift_list_no_shifts => 'لا توجد ورديات في هذا اليوم';

  @override
  String get home_shift_list_no_shifts_month => 'لا توجد ورديات في هذا الشهر';

  @override
  String get shift_history_empty_title => 'لم يتم العثور على ورديات';

  @override
  String get shift_history_empty_subtitle => 'لا يتوفر سجل ورديات';

  @override
  String get home_shift_list_select_day => 'اختر يوماً لعرض الورديات';

  @override
  String get home_shift_list_shifts_on => 'ورديات يوم';

  @override
  String get home_action_new_shift => 'وردية جديدة';

  @override
  String get home_action_calendar => 'التقويم';

  @override
  String get calendar_legend_today => 'اليوم';

  @override
  String get calendar_legend_selected => 'المحدد';

  @override
  String get calendar_legend_shift => 'وردية';

  @override
  String get calendar_legend_holiday => 'عطلة / سبت';

  @override
  String get calendar_legend_holiday_shift => 'وردية عطلة';

  @override
  String get expenses_title => 'المصروفات والإيرادات';

  @override
  String get expenses_tab_expenses => 'المصروفات';

  @override
  String get expenses_tab_incomes => 'إيرادات خاصة';

  @override
  String get expenses_auto_section_title => 'مصروفات الوردية المتكررة';

  @override
  String get expenses_auto_section_subtitle =>
      'إضافة مصروفات متكررة لكل وردية جديدة';

  @override
  String get expenses_auto_section_enable => 'مصروفات تلقائية';

  @override
  String get expenses_history_section_title => 'تفصيل المصروفات الشهرية';

  @override
  String get expenses_action_add_auto => 'إضافة مصروف متكرر';

  @override
  String get expenses_action_update_settings => 'تحديث الإعدادات';

  @override
  String get expenses_action_new_expense => 'مصروف جديد';

  @override
  String get expenses_dialog_add_title => 'إضافة مصروف';

  @override
  String get expenses_dialog_edit_title => 'تعديل المصروف';

  @override
  String get expenses_dialog_delete_title => 'حذف المصروف';

  @override
  String get expenses_no_history => 'لم يتم تسجيل مصروفات';

  @override
  String get expenses_delete_expense_confirm_content =>
      'حذف \"[[desc]]\" بقيمة [[amount]]؟';

  @override
  String get expenses_total_label => 'المجموع';

  @override
  String get expenses_auto_updated_msg =>
      'تم تحديث إعدادات المصروفات التلقائية';

  @override
  String get expenses_deleted_msg => 'تم حذف المصروف';

  @override
  String get expenses_link_shift_dialog_title => 'الربط بوردية';

  @override
  String get expenses_link_shift_dialog_content =>
      'تم العثور على وردية في هذا التاريخ. هل تريد ربط هذا الـ [[type]] بالوردية أو حفظه بشكل مستقل؟';

  @override
  String get expenses_link_shift_button => 'الربط بوردية';

  @override
  String get expenses_save_standalone_button => 'حفظ بشكل مستقل';

  @override
  String get expenses_no_shift_dialog_title => 'لم يتم العثور على وردية';

  @override
  String get expenses_no_shift_dialog_content =>
      'لا توجد وردية في هذا التاريخ. هل ما زلت تريد إنشاء هذا الـ [[type]]؟';

  @override
  String get expenses_create_anyway_button => 'إنشاء على أي حال';

  @override
  String get expenses_auto_incomes_updated_msg =>
      'تم تحديث إعدادات الإيرادات التلقائية';

  @override
  String get expenses_auto_incomes_section_title => 'إيرادات الوردية المتكررة';

  @override
  String get expenses_auto_incomes_section_subtitle =>
      'إضافة إيرادات متكررة لكل وردية جديدة';

  @override
  String get expenses_auto_incomes_section_enable => 'إيرادات تلقائية';

  @override
  String get incomes_history_section_title => 'تفصيل الإيرادات الشهرية';

  @override
  String get incomes_action_new_income => 'إيراد جديد';

  @override
  String get incomes_dialog_add_title => 'إضافة إيراد خاص';

  @override
  String get incomes_dialog_edit_title => 'تعديل الإيراد';

  @override
  String get incomes_dialog_delete_title => 'حذف الإيراد';

  @override
  String get incomes_no_history => 'لم يتم تسجيل إيرادات خاصة';

  @override
  String get incomes_delete_income_confirm_content =>
      'حذف \"[[desc]]\" بقيمة [[amount]]؟';

  @override
  String get incomes_deleted_msg => 'تم حذف الإيراد';

  @override
  String get add_shift_title => 'وردية جديدة';

  @override
  String get add_shift_edit_title => 'تعديل الوردية';

  @override
  String get add_shift_timer_tab => 'المؤقت';

  @override
  String get add_shift_manual_tab => 'يدوي';

  @override
  String get add_shift_paste_tab => 'لصق';

  @override
  String get add_shift_timer_accumulated_live => 'متراكم مباشر';

  @override
  String get add_shift_timer_countdown => 'العد التنازلي: ';

  @override
  String get add_shift_timer_break_paid => 'في استراحة مدفوعة...';

  @override
  String get add_shift_timer_break_unpaid =>
      'في استراحة غير مدفوعة (توقف المؤقت)';

  @override
  String get add_shift_timer_total_break_unpaid =>
      'إجمالي الاستراحات غير المدفوعة:';

  @override
  String get add_shift_timer_resume_work => 'العودة للعمل';

  @override
  String get add_shift_timer_stop_shift => 'إيقاف الوردية';

  @override
  String get add_shift_timer_start_shift => 'بدء الوردية';

  @override
  String get add_shift_timer_continue_work => 'مواصلة العمل';

  @override
  String get add_shift_timer_stopped_msg =>
      'توقف المؤقت. هل تريد حفظ الوردية أو مواصلة العمل؟';

  @override
  String get add_shift_timer_reset_title => 'إعادة ضبط المؤقت';

  @override
  String get add_shift_timer_reset_desc =>
      'هل أنت متأكد من رغبتك في إعادة ضبط المؤقت؟ ستفقد جميع البيانات الحالية.';

  @override
  String get add_shift_manual_time_section => 'الوقت';

  @override
  String get add_shift_manual_date_label => 'التاريخ';

  @override
  String get add_shift_manual_start_time_label => 'وقت البدء';

  @override
  String get add_shift_manual_end_time_label => 'وقت الانتهاء';

  @override
  String get add_shift_manual_break_type_section => 'نوع الاستراحة';

  @override
  String get add_shift_manual_no_break => 'بلا';

  @override
  String get add_shift_manual_paid_break => 'مدفوعة';

  @override
  String get add_shift_manual_unpaid_break => 'غير مدفوعة';

  @override
  String get add_shift_manual_work_tips_section => 'العمل والإكراميات';

  @override
  String get add_shift_manual_job_type_label => 'نوع الوظيفة';

  @override
  String get add_shift_paste_title => 'لصق نص الوردية';

  @override
  String get add_shift_paste_default_job_label => 'نوع الوظيفة الافتراضي';

  @override
  String get add_shift_paste_format_info =>
      'النسق: DD.MM (أو DD.MM.YYYY) - HH:mm - HH:mm [استراحة] [+ إكرامية]\n(إذا تم حذف السنة، يتم استنتاج السنة الحالية)';

  @override
  String get add_shift_paste_hint =>
      'الصق الورديات هنا...\nمثال:\n24.6.2026 - 17:30 - 23:00 45 دقيقة + 50';

  @override
  String get add_shift_paste_parse_button => 'تحليل وحفظ الكل';

  @override
  String get add_shift_paste_parse_dialog_title => 'تحليل الورديات';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'تحليل وحفظ الورديات من النص الملصق؟';

  @override
  String get add_shift_paste_error =>
      'الرجاء التحقق من النسق والمحاولة مرة أخرى';

  @override
  String get add_shift_tips_title => 'الإكراميات';

  @override
  String get add_shift_tips_total => 'المجموع';

  @override
  String get add_shift_tips_hint => 'مبلغ الإكرامية';

  @override
  String get add_shift_tips_add_button => 'إضافة إكرامية';

  @override
  String get add_shift_expenses_title => 'مصروفات الوردية';

  @override
  String get add_shift_expenses_total => 'المجموع';

  @override
  String get add_shift_expenses_add_button => 'إضافة مصروف';

  @override
  String get add_shift_incomes_title => 'إيرادات الوردية';

  @override
  String get add_shift_incomes_total => 'المجموع';

  @override
  String get add_shift_incomes_add_button => 'إضافة إيراد';

  @override
  String get add_shift_shift_ended_dialog_title => 'حفظ الوردية';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'هل أنت متأكد من رغبتك في حفظ تفاصيل الوردية؟';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'هل أنت متأكد من رغبتك في حفظ تفاصيل الوردية؟';

  @override
  String get add_shift_shift_edit_dialog_title => 'تحديث الوردية';

  @override
  String get add_shift_shift_saved => 'تم حفظ الوردية بنجاح';

  @override
  String get add_shift_preview_title => 'معاينة';

  @override
  String add_shift_segments_count(int count) {
    return '$count فترات';
  }

  @override
  String get add_shift_overlap_title => 'وردية متداخلة';

  @override
  String add_shift_overlap_content(num count, String details) {
    return 'هذه الوردية تتداخل مع $count وردية/ورديات موجودة:\n\n$details\n\nحفظ على أي حال؟';
  }

  @override
  String get add_shift_overlap_confirm => 'حفظ على أي حال';

  @override
  String get add_shift_overlap_unknown_job => 'وظيفة غير معروفة';

  @override
  String get add_shift_pick_a_job => 'الرجاء اختيار نوع الوظيفة أولاً';

  @override
  String get add_shift_delete_title => 'حذف الوردية';

  @override
  String get add_shift_delete_desc => 'هل أنت متأكد من رغبتك في حذف الوردية من';

  @override
  String get add_shift_delete_msg => 'تم حذف الوردية بنجاح';

  @override
  String get notification_timer_channel_name => 'وردية نشطة';

  @override
  String get notification_timer_channel_desc => 'يعرض مؤقت الوردية الحالي';

  @override
  String get notification_timer_title_active => 'وردية نشطة';

  @override
  String get notification_timer_title_paid_break => 'استراحة مدفوعة';

  @override
  String get notification_timer_title_unpaid_break => 'استراحة غير مدفوعة';

  @override
  String get notification_timer_body_running => 'المؤقت يعمل...';

  @override
  String get notification_timer_body_countdown => 'العد التنازلي: [[time]]';

  @override
  String get filter_title => 'فلترة الورديات';

  @override
  String get filter_clear_all => 'إعادة تعيين الفلتر';

  @override
  String get filter_apply => 'تطبيق الفلاتر';

  @override
  String get filter_wage_range => 'نطاق الأجر الإجمالي';

  @override
  String get filter_tips_range => 'نطاق الإكراميات';

  @override
  String get filter_expenses_range => 'نطاق المصروفات';

  @override
  String get filter_duration_range => 'نطاق المدة (ساعات)';

  @override
  String get filter_date_range => 'نطاق التاريخ';

  @override
  String get filter_job_type => 'نوع الوظيفة';

  @override
  String get filter_select_all => 'تحديد الكل';

  @override
  String get filter_error_no_job_selected =>
      'الرجاء اختيار نوع وظيفة واحد على الأقل';

  @override
  String get filter_active_filters => 'الفلاتر النشطة:';

  @override
  String get filter_chip_wage => 'الأجر: [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'الإكراميات: [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'المصروفات: [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'المدة: [[min]] - [[max]] س';

  @override
  String get filter_chip_date => 'التاريخ: [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'الوظيفة: [[name]]';

  @override
  String get filter_empty_state_title => 'لا توجد ورديات مطابقة';

  @override
  String get filter_empty_state_subtitle =>
      'جرب تعديل الفلاتر لرؤية المزيد من النتائج';

  @override
  String get auth_login_title => 'مرحباً بعودتك';

  @override
  String get auth_register_title => 'إنشاء حساب جديد';

  @override
  String get auth_full_name_label => 'الاسم الكامل';

  @override
  String get auth_email_label => 'البريد الإلكتروني';

  @override
  String get auth_password_label => 'كلمة المرور';

  @override
  String get auth_error_name_empty => 'الرجاء إدخال الاسم';

  @override
  String get auth_error_email_invalid => 'بريد إلكتروني غير صالح';

  @override
  String get auth_error_password_length =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get auth_login_button => 'تسجيل الدخول';

  @override
  String get auth_register_button => 'تسجيل';

  @override
  String get auth_no_account_link => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get auth_has_account_link => 'لديك حساب بالفعل؟ سجل دخولك';

  @override
  String get auth_error_generic => 'حدث خطأ. الرجاء المحاولة مرة أخرى.';

  @override
  String get settings_logout_title => 'تسجيل الخروج من النظام';

  @override
  String get settings_logout_dialog_title => 'تسجيل الخروج';

  @override
  String get settings_logout_confirm_content =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get settings_logout_confirm_button => 'تسجيل الخروج';

  @override
  String get auth_login_success => 'تم تسجيل الدخول بنجاح';

  @override
  String get auth_register_success => 'تم إنشاء الحساب بنجاح';

  @override
  String get auth_birth_date_label => 'تاريخ الميلاد';

  @override
  String get auth_error_underage =>
      'يجب أن يكون عمر المستخدم 12 عاماً على الأقل';

  @override
  String get auth_error_birth_date_empty => 'الرجاء اختيار تاريخ ميلادك';

  @override
  String get auth_error_email_exists => 'عنوان البريد الإلكتروني مستخدم بالفعل';

  @override
  String get auth_error_user_not_found =>
      'المستخدم غير موجود أو كلمة المرور غير صحيحة';

  @override
  String get auth_error_network =>
      'خطأ في اتصال الشبكة. الرجاء التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get auth_continue_as_guest => 'المتابعة كضيف';

  @override
  String get auth_replace_guest_data_title => 'استبدال بيانات الضيف؟';

  @override
  String get auth_replace_guest_data_message =>
      'سيؤدي تسجيل الدخول إلى حساب موجود إلى استبدال البيانات المخزنة حالياً على هذا الجهاز بالبيانات المرتبطة بحسابك. قد تفقد بيانات ضيفك نهائياً ولا يمكن استردادها ما لم يكن لديك نسخة احتياطية. تأكد من فهم هذه النتائج قبل المتابعة.';

  @override
  String get auth_replace_guest_data_confirm => 'متابعة';

  @override
  String get auth_replace_guest_data_cancel => 'إلغاء';

  @override
  String get auth_guest_mode_title => 'وضع الضيف';

  @override
  String get auth_guest_mode_subtitle =>
      'أنت تستخدم Shiftly في وضع الضيف. يتم حفظ بياناتك محلياً على هذا الجهاز. أنشئ حساباً للمزامنة عبر الأجهزة أو سجل الدخول إلى حساب موجود.';

  @override
  String get auth_guest_migration_failed =>
      'فشل استرجاع بيانات الحساب. تم الحفاظ على بيانات ضيفك.';

  @override
  String get auth_register_guest_transfer =>
      'تسجيل الدخول أو إنشاء حساب Shiftly';

  @override
  String get auth_user_deleted_local_data_preserved =>
      'حسابك لم يعد موجوداً في قاعدة البيانات. تم تسجيل خروجك، ولكن بياناتك المحلية لا تزال مخزنة على هذا الجهاز.';

  @override
  String get home_welcome_back => 'أهلاً، [[name]]';

  @override
  String get settings_user_name => 'الاسم';

  @override
  String get settings_user_email => 'البريد الإلكتروني';

  @override
  String get settings_user_password => 'كلمة المرور';

  @override
  String get settings_user_edit_title => 'تعديل الملف الشخصي';

  @override
  String get settings_user_update_success => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get settings_logout_success => 'تم تسجيل الخروج بنجاح';

  @override
  String get settings_byos_title => 'مزامنة BYOS';

  @override
  String get settings_byos_connected => 'متصل بـ Google Drive';

  @override
  String get settings_byos_last_backup => 'آخر نسخ احتياطي: [[time]]';

  @override
  String get settings_byos_backup_now => 'نسخ احتياطي الآن';

  @override
  String get settings_byos_auto_sync => 'مزامنة تلقائية';

  @override
  String get settings_byos_auto_sync_sub =>
      'نسخ التغييرات احتياطياً فوراً إلى السحابة';

  @override
  String get settings_byos_disconnect => 'قطع الاتصال';

  @override
  String get settings_byos_login_shiftly => 'تسجيل الدخول إلى حساب Shiftly';

  @override
  String get settings_byos_login_shiftly_sub => 'مزامنة كاملة في سحابتنا';

  @override
  String get settings_byos_method_title => 'طريقة BYOS (Google Drive)';

  @override
  String get settings_byos_method_sub => 'نسخ احتياطي إلى سحابتك الخاصة';

  @override
  String get settings_byos_restore_dialog_title => 'مزامنة BYOS';

  @override
  String get settings_byos_restore_dialog_content =>
      'هل تريد استعادة البيانات الموجودة من Google Drive الخاص بك؟';

  @override
  String get settings_byos_restore_confirm => 'استعادة';

  @override
  String get settings_byos_restore_cancel => 'ليس الآن';

  @override
  String get settings_byos_login_hint =>
      'سجل الدخول لنسخ البيانات احتياطياً إلى السحابة واستخدام أجهزة متعددة';

  @override
  String get settings_restore_success =>
      'تمت الاستعادة بنجاح: تم استعادة [[shifts]] وردية و [[jobs]] وظيفة.';

  @override
  String get settings_restore_no_data =>
      'لم يتم العثور على نسخة احتياطية في Google Drive أو حدث خطأ.';

  @override
  String get export_title => 'تصدير الورديات';

  @override
  String get export_format_label => 'نسق الملف';

  @override
  String get export_format_csv => 'CSV (متوافق مع Excel)';

  @override
  String get export_format_txt => 'ملف نصي (TXT)';

  @override
  String get export_format_json => 'نسخة احتياطية JSON (.json)';

  @override
  String get export_range_label => 'نطاق التصدير';

  @override
  String get export_range_all => 'جميع الورديات';

  @override
  String get export_range_month => 'شهر محدد';

  @override
  String get export_range_custom => 'نطاق تاريخ مخصص';

  @override
  String get export_start_date => 'تاريخ البدء';

  @override
  String get export_end_date => 'تاريخ الانتهاء';

  @override
  String get export_select_month => 'اختر الشهر';

  @override
  String get export_button => 'تصدير الملف';

  @override
  String get export_success_msg => 'تم تصدير الملف بنجاح وحفظه في:';

  @override
  String get export_empty_error =>
      'لم يتم العثور على ورديات في النطاق المحدد للتصدير';

  @override
  String get analytics_title => 'التحليلات والرؤى';

  @override
  String get analytics_hero_greeting => 'لقطة مالية';

  @override
  String get analytics_hero_subtitle =>
      'أدائك المالي وأنماط عملك في لمحة سريعة';

  @override
  String get analytics_section_overview => 'نظرة عامة';

  @override
  String get analytics_section_earnings => 'الأرباح';

  @override
  String get analytics_section_work_patterns => 'أنماط العمل';

  @override
  String get analytics_section_pay_breakdown => 'تفصيل الأجر';

  @override
  String get analytics_period_monthly => 'شهري';

  @override
  String get analytics_period_yearly => 'سنوي';

  @override
  String get analytics_period_all_time => 'كل الوقت';

  @override
  String get analytics_all_jobs => 'جميع الوظائف';

  @override
  String get analytics_stat_total_net => 'المجموع الصافي';

  @override
  String get analytics_stat_total_hours => 'إجمالي الساعات';

  @override
  String get analytics_stat_avg_rate => 'متوسط الأجر الفعلي';

  @override
  String get analytics_stat_tips => 'مصروفات الوردية الصافية';

  @override
  String get analytics_chart_earnings_title =>
      'الأرباح مقابل المصروفات بمرور الوقت';

  @override
  String get analytics_chart_earnings_subtitle =>
      'انقر على عمود لعرض تفصيل الأجر والمصروفات';

  @override
  String get analytics_chart_jobs_title => 'التفصيل حسب الوظيفة';

  @override
  String get analytics_chart_jobs_by_earnings => 'حسب الأرباح';

  @override
  String get analytics_chart_jobs_by_hours => 'حسب الساعات';

  @override
  String get analytics_no_data => 'لا توجد بيانات للفترة المختارة';

  @override
  String get analytics_selected_breakdown => 'تفاصيل اليوم المحدد';

  @override
  String get analytics_selected_month_breakdown => 'تفاصيل الشهر المحدد';

  @override
  String get analytics_base_salary => 'الراتب الأساسي';

  @override
  String get analytics_chart_cumulative_title => 'نمو الأرباح التراكمي';

  @override
  String get analytics_chart_cumulative_subtitle =>
      'قم بالتمرير أفقيياً لعرض نمو الأجر بمرور الوقت';

  @override
  String get analytics_gross_pay => 'الإجمالي';

  @override
  String get analytics_net_pay => 'الصافي';

  @override
  String get analytics_kpi_projected => 'الراتب المتوقع بنهاية الشهر';

  @override
  String get analytics_kpi_retention => 'معدل الاحتفاظ بالصافي';

  @override
  String get analytics_chart_tod_title => 'التفصيل حسب وقت اليوم';

  @override
  String get analytics_chart_tod_subtitle => 'مقارنة الساعات عبر فترات اليوم';

  @override
  String get analytics_chart_tod_dawn => 'الفجر';

  @override
  String get analytics_chart_tod_morning => 'الصباح';

  @override
  String get analytics_chart_tod_noon => 'الظهيرة';

  @override
  String get analytics_chart_tod_afternoon => 'بعد الظهر';

  @override
  String get analytics_chart_tod_evening => 'المساء';

  @override
  String get analytics_chart_tod_night => 'الليل';

  @override
  String get analytics_chart_duration_title => 'تفصيل مدة الورديات والإرهاق';

  @override
  String get analytics_chart_duration_subtitle =>
      'توزيع مدد الورديات (قصيرة، قياسية، طويلة)';

  @override
  String get analytics_duration_short => 'قصيرة';

  @override
  String get analytics_duration_standard => 'قياسية';

  @override
  String get analytics_duration_long => 'طويلة';

  @override
  String get analytics_insights_title => 'رؤى ذكية رئيسية';

  @override
  String get analytics_insight_night_boost =>
      'تشكل ورديات المساء والليل [[percent]]% من ساعات عملك.';

  @override
  String get analytics_insight_retention =>
      'تحتفظ بـ [[percent]]% من إجمالي الأرباح بعد مصروفات الورديات.';

  @override
  String get analytics_insight_fatigue =>
      '[[percent]]% من وردياتك استمرت لأكثر من 9 ساعات.';

  @override
  String get analytics_insight_tips_ratio =>
      'تشكل المصروفات المتكررة [[percent]]% من إجمالي أرباحك.';

  @override
  String analytics_shifts_format(Object count) {
    return '$count ورديات';
  }

  @override
  String get analytics_no_shift_data_period =>
      'لا توجد بيانات ورديات لهذه الفترة';

  @override
  String get analytics_min_shifts_hourly =>
      'مطلوب ورديتان على الأقل لعرض اتجاه الأجر بالساعة';

  @override
  String get analytics_min_shifts_growth =>
      'مطلوب ورديتان على الأقل لعرض النمو التراكمي';

  @override
  String get analytics_min_shifts_retention =>
      'مطلوب ورديتان على الأقل لعرض اتجاه الاحتفاظ بالصافي';

  @override
  String get analytics_no_job_data => 'لا توجد بيانات وظائف';

  @override
  String analytics_hours_suffix_format(Object hours) {
    return '$hours س';
  }

  @override
  String analytics_utilization_format(Object pct) {
    return '$pct% نسبة الاستخدام';
  }

  @override
  String get common_previous => 'السابق';

  @override
  String get common_next => 'التالي';

  @override
  String get analytics_tips_and_extra => 'الإكراميات والإضافات';

  @override
  String analytics_rate_boost_subtitle(Object boost) {
    return '+$boost/س إضافات صافية';
  }

  @override
  String get analytics_retention_subtitle => 'المتبقي بعد مصروفات الوردية';

  @override
  String analytics_net_extras_pct_subtitle(Object percent) {
    return '$percent% من إجمالي الأجر الصافي';
  }

  @override
  String get common_unknown_job => 'وظيفة غير معروفة';

  @override
  String get analytics_duration_range_short => '< 6 ساعات';

  @override
  String get analytics_duration_range_standard => '6-9 ساعات';

  @override
  String get analytics_duration_range_long => '> 9 ساعات';

  @override
  String get profile_title => 'الملف الشخصي للمستخدم';

  @override
  String get profile_created_at => 'تم إنشاء الحساب: [[date]]';

  @override
  String get profile_birth_date_display =>
      'تاريخ الميلاد: [[date]] (العمر: [[age]])';

  @override
  String get profile_stats_title => 'ملخص البيانات المحفوظة';

  @override
  String get profile_shifts_count => 'الورديات المحفوظة';

  @override
  String get profile_jobs_count => 'الأدوار / أنواع الوظائف';

  @override
  String get profile_expenses_count => 'المصروفات المحفوظة';

  @override
  String get profile_incomes_count => 'الإيرادات المحفوظة';

  @override
  String get side_menu_profile => 'الملف الشخصي للمستخدم';

  @override
  String get profile_old_password => 'كلمة المرور الحالية';

  @override
  String get profile_new_password => 'كلمة المرور الجديدة';

  @override
  String get profile_password_error => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get profile_password_required => 'الرجاء إدخال كلمة المرور الحالية';

  @override
  String get shift_descriptions_title => 'ملخصات الورديات';

  @override
  String get shift_descriptions_empty => 'لم يتم العثور على ملخصات ورديات';

  @override
  String get shift_description_label => 'ملخص / وصف الوردية';

  @override
  String get shift_description_hint => 'أدخل ملاحظات أو ملخصاً لهذه الوردية...';

  @override
  String get shift_descriptions_delete_title => 'حذف الوصف';

  @override
  String get shift_descriptions_delete_content =>
      'هل أنت متأكد من رغبتك في حذف الوصف لهذه الوردية؟';

  @override
  String get shift_descriptions_deleted_msg => 'تم حذف الوصف بنجاح';

  @override
  String get shift_descriptions_edit_title => 'تعديل الوصف';

  @override
  String get shift_descriptions_updated_msg => 'تم تحديث الوصف بنجاح';

  @override
  String get common_search_by_date => 'البحث حسب التاريخ';

  @override
  String get common_clear_date_filter => 'مسح فلاتر التاريخ';

  @override
  String get common_filter_date => 'تاريخ التصفية';

  @override
  String get profile_delete_account => 'حذف الحساب';

  @override
  String get profile_delete_account_sub =>
      'حذف حساب المستخدم الخاص بك في Shiftly نهائياً';

  @override
  String get profile_delete_dialog_title => 'حذف الحساب';

  @override
  String get profile_delete_dialog_content =>
      'هل أنت متأكد من رغبتك في حذف حسابك في Shiftly؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get profile_delete_final_title => 'التأكيد النهائي';

  @override
  String get profile_delete_final_content_1 =>
      'سيتم حذف حساب المستخدم الخاص بك وجميع بيانات الخادم نهائياً.';

  @override
  String get profile_delete_final_content_2 =>
      'هذا الإجراء لا رجعة فيه. هل تريد المتابعة في حذف الحساب؟';

  @override
  String get profile_delete_success => 'تم حذف الحساب بنجاح';

  @override
  String get settings_byos_delete_title => 'حذف نسخة BYOS الاحتياطية';

  @override
  String get settings_byos_delete_sub =>
      'محو ملف النسخ الاحتياطي نهائياً من Google Drive';

  @override
  String get settings_byos_delete_dialog_title => 'حذف بيانات BYOS';

  @override
  String get settings_byos_delete_dialog_content =>
      'هل أنت متأكد من رغبتك في حذف بيانات النسخ الاحتياطي من Google Drive؟';

  @override
  String get settings_byos_delete_final_title => 'تحذير نهائي';

  @override
  String get settings_byos_delete_final_content_1 =>
      'سيتم تدمير ملف النسخ الاحتياطي في Google Drive بالكامل.';

  @override
  String get settings_byos_delete_final_content_2 =>
      'هل أنت متأكد من رغبتك في حذف بيانات النسخ الاحتياطي BYOS نهائياً؟';

  @override
  String get settings_byos_delete_success =>
      'تم حذف بيانات النسخ الاحتياطي BYOS بنجاح';

  @override
  String get add_shift_wage_segments_title =>
      'فترات نسبة الأجر بالساعة (اختياري)';

  @override
  String get add_shift_wage_segments_subtitle =>
      'تحديد فترات بنسب أجور مختلفة (مثل 150%)';

  @override
  String get add_shift_wage_segments_add => 'إضافة فترة';

  @override
  String get add_shift_wage_segment_start => 'البدء';

  @override
  String get add_shift_wage_segment_end => 'الانتهاء';

  @override
  String get add_shift_wage_segment_percentage => 'نسبة الأجر %';

  @override
  String get error_segment_invalid_time =>
      'يجب أن يكون وقت انتهاء الفترة بعد وقت البدء';

  @override
  String get error_segment_overlap => 'يوجد تداخل في النطاقات الزمنية';

  @override
  String get legal_privacy_policy => 'سياسة الخصوصية';

  @override
  String get legal_terms_of_service => 'شروط الخدمة';

  @override
  String get legal_disclaimer_notice =>
      'من خلال التسجيل أو تسجيل الدخول، فإنك توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا.';

  @override
  String get legal_cookie_title => 'تفضيلات ملفات تعريف الارتباط والخصوصية';

  @override
  String get legal_cookie_description =>
      'نحن نستخدم تقنيات التخزين المحلي وملفات تعريف الارتباط للمصادقة الأساسية، والأمان، وتتبع أعطال التطبيق. يمكنك اختيار قبول الكل أو استخدام ملفات تعريف الارتباط الضرورية فقط.';

  @override
  String get legal_cookie_accept_all => 'قبول الكل';

  @override
  String get legal_cookie_necessary_only => 'الضرورية فقط';

  @override
  String get legal_cookie_necessary_desc =>
      'ضرورية للمصادقة، والتخزين الآمن للرموز، وتفضيلات الجلسة.';

  @override
  String get legal_cookie_analytics_desc =>
      'سجلات الأخطاء مجهولة المصدر وتتبع أداء الأعطال عبر Firebase.';

  @override
  String get legal_cookie_customize => 'تخصيص';

  @override
  String get legal_cookie_save_preferences => 'حفظ التفضيلات';

  @override
  String get legal_cookie_essential => 'ملفات تعريف الارتباط الأساسية والأمنية';

  @override
  String get legal_cookie_always_active => 'نشطة دائماً';

  @override
  String get legal_cookie_optional => 'اختيارية';

  @override
  String get common_close => 'إغلاق';

  @override
  String get settings_section_overtime => 'قواعد العمل الإضافي';

  @override
  String get settings_overtime_enable => 'تفعيل حساب العمل الإضافي';

  @override
  String get settings_overtime_enable_sub =>
      'حساب تعويض العمل الإضافي المتدرج تلقائياً';

  @override
  String get settings_overtime_regular_threshold =>
      'حد الساعات العادية (ساعات)';

  @override
  String get settings_overtime_tier1_limit =>
      'مدة شريحة العمل الإضافي الأولى (ساعات)';

  @override
  String get settings_overtime_tier1_rate => 'مضاعف الشريحة الأولى (%)';

  @override
  String get settings_overtime_tier2_rate => 'مضاعف الشريحة الإضافية (%)';

  @override
  String get settings_overtime_update_button => 'حفظ قواعد العمل الإضافي';

  @override
  String get settings_overtime_saved => 'تم تحديث قواعد العمل الإضافي بنجاح';

  @override
  String get overtime_notification_detected =>
      'تتضمن الوردية عملاً إضافياً. تم حساب الراتب وفقاً لمعدلات العمل الإضافي.';

  @override
  String get overtime_breakdown_title => 'تفصيل الراتب';

  @override
  String get overtime_regular_hours_label => 'الساعات العادية';

  @override
  String get overtime_tier1_label => 'عمل إضافي (125%)';

  @override
  String get overtime_tier2_label => 'عمل إضافي (150%)';

  @override
  String get overtime_tier_custom_label => 'عمل إضافي ([[rate]]%)';

  @override
  String get overtime_tag_label => 'عمل إضافي';

  @override
  String get overtime_total_paid_time => 'إجمالي الوقت المدفوع';

  @override
  String get overtime_total_earnings => 'إجمالي أرباح الوردية';

  @override
  String get overtime_unpaid_break => 'استراحة غير مدفوعة';

  @override
  String get analytics_overtime_section_title => 'ملخص وساعات العمل الإضافي';

  @override
  String get analytics_regular_hours => 'الساعات العادية';

  @override
  String get analytics_overtime_hours => 'ساعات العمل الإضافي';

  @override
  String get analytics_overtime_earnings => 'أرباح العمل الإضافي';

  @override
  String get shabbat_tag_label => 'السبت';

  @override
  String get holiday_tag_label => 'عطلة رسمية';

  @override
  String get settings_shabbat_section => 'السبت والعطلات';

  @override
  String get settings_shabbat_enable => 'الحساب التلقائي للسبت والعطلات';

  @override
  String get settings_shabbat_enable_sub =>
      'الكشف التلقائي عن السبت، والعطلات، والأسعار الخاصة';

  @override
  String get settings_shabbat_multiplier_label => 'معدل السبت (%)';

  @override
  String get settings_holiday_multiplier_label => 'معدل العطلة (%)';

  @override
  String get settings_candle_lighting_label =>
      'دقائق إضاءة الشموع قبل غروب الشمس';

  @override
  String get settings_shabbat_exit_label => 'دقائق خروج السبت بعد غروب الشمس';

  @override
  String get settings_shabbat_saved => 'تم حفظ إعدادات السبت والعطلات بنجاح';

  @override
  String get settings_shabbat_save_button => 'حفظ إعدادات السبت والعطلات';

  @override
  String get analytics_shabbat_holiday_summary => 'ملخص السبت والعطلات';

  @override
  String get analytics_shabbat_hours => 'ساعات السبت';

  @override
  String get analytics_holiday_hours => 'ساعات العطلات';

  @override
  String get onboarding_shabbat_title => 'السبت والأعياد اليهودية';

  @override
  String get onboarding_shabbat_subtitle =>
      'الكشف التلقائي عن السبت، والأعياد، والأسعار الخاصة';

  @override
  String add_shift_unknown_job_title(Object trailingText) {
    return 'نوع وردية غير معروف: \"$trailingText\"';
  }

  @override
  String get add_shift_unknown_job_desc =>
      'تم العثور على نوع وظيفة غير موجود في قائمة الوظائف الخاصة بك. اختر نوع وظيفة بديل أو احفظه كوصـف:';

  @override
  String get add_shift_select_job_label => 'اختر نوع الوظيفة';

  @override
  String get add_shift_apply_all_instances =>
      'التطبيق تلقائياً على جميع الحالات من هذا النوع';

  @override
  String get add_shift_skip => 'تخطي';

  @override
  String get add_shift_save_as_desc => 'الحفظ كوَصْفٍ فقط';

  @override
  String get add_shift_assign => 'تعيين';

  @override
  String add_shift_shabbat_breakdown(Object rate) {
    return 'السبت ($rate%)';
  }

  @override
  String add_shift_holiday_breakdown(Object name, Object rate) {
    return '$name ($rate%)';
  }

  @override
  String get settings_update_section => 'تحديثات التطبيق';

  @override
  String get settings_update_check_button => 'التحقق من وجود تحديثات من GitHub';

  @override
  String settings_update_current_version(String version) {
    return 'الإصدار الحالي: v$version';
  }

  @override
  String get settings_update_checking_toast =>
      'جاري التحقق من التحديثات من إصدارات GitHub...';

  @override
  String get settings_update_error_toast =>
      'تعذر الاتصال بـ GitHub. الرجاء المحاولة لاحقاً.';

  @override
  String settings_update_latest_toast(String version) {
    return 'التطبيق محدث لأحدث إصدار! (v$version)';
  }

  @override
  String get update_dialog_title => 'إصدار جديد متاح!';

  @override
  String update_dialog_version_available(String version) {
    return 'الإصدار $version متاح للتنزيل';
  }

  @override
  String update_dialog_installed_version(String version) {
    return 'الإصدار المثبت: $version';
  }

  @override
  String update_dialog_new_version(String version) {
    return 'الجديد: $version';
  }

  @override
  String get update_dialog_whats_new => 'ما الجديد في هذا الإصدار:';

  @override
  String get update_dialog_downloading => 'جاري تنزيل ملف التحديث...';

  @override
  String get update_dialog_later => 'لاحقاً';

  @override
  String get update_dialog_open_browser => 'فتح في المتصفح';

  @override
  String get update_dialog_update_now => 'تحديث الآن';

  @override
  String get update_dialog_open_download => 'فتح صفحة التنزيل';

  @override
  String get update_dialog_mandatory_notice =>
      'هذا التحديث مطلوب لمتابعة استخدام التطبيق.';

  @override
  String get update_service_no_changelog =>
      'لا توجد تفاصيل لسجل التغييرات متاحة.';

  @override
  String update_service_download_failed(Object statusCode) {
    return 'فشل تنزيل الملف (رمز الخطأ: $statusCode)';
  }

  @override
  String get update_service_no_installer =>
      'لم يتم العثور على تطبيق لتثبيت ملفات APK على الجهاز. جرب الفتح في المتصفح.';

  @override
  String update_service_cannot_launch_installer(String message) {
    return 'تعذر تشغيل مثبت الحزم ($message)';
  }

  @override
  String update_service_download_error(Object error) {
    return 'حدث خطأ أثناء تنزيل التحديث: $error';
  }

  @override
  String get common_show_password => 'إظهار كلمة المرور';

  @override
  String get common_hide_password => 'إخفاء كلمة المرور';

  @override
  String get accessibility_statement => 'بيان إمكانية الوصول';

  @override
  String get settings_accessibility_sub =>
      'معلومات إمكانية الوصول وتفاصيل الاتصال';

  @override
  String get all_shifts_title => 'جميع الورديات';

  @override
  String get export_format_excel => 'ملف Excel (.xlsx)';

  @override
  String get export_format_pdf => 'مستند PDF (.pdf)';

  @override
  String get export_include_analytics => 'تضمين التحليلات والملخصات';

  @override
  String get export_include_analytics_sub =>
      'إضافة الرسوم البيانية ونظرة عامة على الإحصائيات إلى التقرير';

  @override
  String get import_title => 'استيراد الورديات';

  @override
  String get import_button => 'استيراد ملف (.xlsx, .csv, .json)';

  @override
  String get import_paste_or_pick => 'اختر ملفاً أو الصق المحتوى';

  @override
  String get import_preview_title => 'معاينة الاستيراد';

  @override
  String import_found_shifts(int count) {
    return 'تم العثور على $count وردية صالحة للاستيراد';
  }

  @override
  String import_confirm_button(int count) {
    return 'استيراد $count ورديات';
  }

  @override
  String import_success_msg(int count) {
    return 'تم استيراد $count وردية بنجاح!';
  }

  @override
  String get import_error_msg => 'فشل استيراد الورديات أو تنسيق غير مدعوم';

  @override
  String get pdf_report_title => 'Shiftly - تقرير العمل والراتب';

  @override
  String get pdf_detailed_log => 'سجل الورديات المفصل';

  @override
  String get pdf_analytics_summary => 'التحليلات والملخص';

  @override
  String get pdf_total_net_pay => 'إجمالي الأجر الصافي';

  @override
  String get pdf_total_hours => 'إجمالي الساعات الصافية';

  @override
  String get pdf_avg_rate => 'متوسط الأجر الفعلي';

  @override
  String get pdf_shifts_count => 'عدد الورديات';

  @override
  String get pdf_total_base => 'الراتب الأساسي';

  @override
  String get pdf_total_tips => 'الإكراميات';

  @override
  String get pdf_total_expenses => 'المصروفات';

  @override
  String get pdf_total_incomes => 'الإيرادات';

  @override
  String get pdf_col_date => 'التاريخ';

  @override
  String get pdf_col_job => 'الوظيفة';

  @override
  String get pdf_col_time => 'الساعات';

  @override
  String get pdf_col_start_time => 'وقت البدء';

  @override
  String get pdf_col_end_time => 'وقت الانتهاء';

  @override
  String get pdf_col_tags => 'العلامات';

  @override
  String get pdf_col_net_hours => 'س. صافية';

  @override
  String get pdf_col_hourly_rate => 'الأجر';

  @override
  String get pdf_col_base => 'الأساسي';

  @override
  String get pdf_col_overtime => 'عمل إضافي';

  @override
  String get pdf_col_shabbat => 'السبت';

  @override
  String get pdf_col_tips => 'الإكراميات';

  @override
  String get pdf_col_extras => 'إضافات';

  @override
  String get pdf_col_net_pay => 'المجموع الصافي';

  @override
  String get pdf_col_notes => 'ملاحظات';

  @override
  String get excel_sheet_shifts => 'تفاصيل الورديات';

  @override
  String get excel_sheet_analytics => 'ملخص التحليلات';

  @override
  String report_generated_label(String date) {
    return 'تم الإنشاء: $date';
  }

  @override
  String report_total_shifts_label(int count) {
    return 'إجمالي الورديات: $count';
  }

  @override
  String get report_category_label => 'الفئة';

  @override
  String get report_rate_multiplier_label => 'مضاعف الأجر';

  @override
  String get report_hours_label => 'الساعات';

  @override
  String get report_earnings_label => 'الأرباح';

  @override
  String get report_regular_hours => 'الساعات العادية (100%)';

  @override
  String get report_overtime_125 => 'عمل إضافي شريحة 1 (125%)';

  @override
  String get report_overtime_150 => 'عمل إضافي شريحة 2 (150%)';

  @override
  String get report_shabbat_hours => 'ساعات السبت';

  @override
  String get report_holiday_hours => 'ساعات العطلات';

  @override
  String get report_disabled_status => '(معطل في الإعدادات)';

  @override
  String get report_job_distribution => 'توزيع نوع الوظيفة';

  @override
  String get report_job_name => 'اسم الوظيفة';

  @override
  String get report_pct_net_pay => '% من الأجر الصافي';

  @override
  String get report_totals_row => 'المجاميع';

  @override
  String get report_tag_overtime => 'عمل إضافي';

  @override
  String get report_tag_shabbat => 'السبت';

  @override
  String get report_tag_holiday => 'عطلة';

  @override
  String report_page_number(Object current, Object total) {
    return 'الصفحة $current من $total';
  }

  @override
  String pdf_col_hourly_rate_symbol(String symbol) {
    return 'الأجر بالساعة ($symbol)';
  }

  @override
  String pdf_col_base_symbol(String symbol) {
    return 'الراتب الأساسي ($symbol)';
  }

  @override
  String report_overtime_125_symbol(String symbol) {
    return 'عمل إضافي 125% ($symbol)';
  }

  @override
  String report_overtime_150_symbol(String symbol) {
    return 'عمل إضافي 150% ($symbol)';
  }

  @override
  String pdf_col_shabbat_symbol(String symbol) {
    return 'السبت/العطلة ($symbol)';
  }

  @override
  String pdf_col_tips_symbol(String symbol) {
    return 'الإكراميات ($symbol)';
  }

  @override
  String pdf_total_incomes_symbol(String symbol) {
    return 'الإيرادات التلقائية ($symbol)';
  }

  @override
  String pdf_total_expenses_symbol(String symbol) {
    return 'المصروفات التلقائية ($symbol)';
  }

  @override
  String pdf_col_net_pay_symbol(String symbol) {
    return 'إجمالي الأجر الصافي ($symbol)';
  }

  @override
  String get shift_template_title => 'قوالب الورديات';

  @override
  String get shift_template_subtitle =>
      'قوالب سريعة لجعل إضافة الورديات سريعة وسهلة.';

  @override
  String get shift_template_morning => 'وردية الصباح';

  @override
  String get shift_template_evening => 'وردية المساء';

  @override
  String get shift_template_night => 'وردية الليل';

  @override
  String get shift_template_add_button => 'إضافة قالب';

  @override
  String get shift_template_save_current => 'حفظ كقالب';

  @override
  String get shift_template_applied_snack => 'تم تطبيق القالب';

  @override
  String get shift_template_saved_snack => 'تم حفظ القالب بنجاح';

  @override
  String get shift_template_deleted_snack => 'تم حذف القالب';

  @override
  String get shift_template_delete_confirm_title => 'حذف القالب';

  @override
  String get shift_template_delete_confirm_content =>
      'هل أنت متأكد من رغبتك في حذف هذا القالب؟';

  @override
  String get shift_template_name_label => 'اسم القالب';

  @override
  String get shift_template_select_prompt => 'قوالب الورديات السريعة';

  @override
  String get shift_template_manage => 'إدارة القوالب';

  @override
  String get shift_template_empty => 'لم يتم حفظ أي قوالب ورديات بعد';

  @override
  String get shift_template_edit_title => 'تعديل القالب';

  @override
  String get shift_template_new_title => 'قالب وردية جديد';

  @override
  String get expenses_type_income => 'دخل';

  @override
  String get expenses_type_expense => 'مصروف';
}
