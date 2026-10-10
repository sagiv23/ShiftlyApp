import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @common_app_name.
  ///
  /// In he, this message translates to:
  /// **'Shiftly'**
  String get common_app_name;

  /// No description provided for @common_continue.
  ///
  /// In he, this message translates to:
  /// **'המשך'**
  String get common_continue;

  /// No description provided for @common_back.
  ///
  /// In he, this message translates to:
  /// **'חזור'**
  String get common_back;

  /// No description provided for @common_start.
  ///
  /// In he, this message translates to:
  /// **'בוא נתחיל!'**
  String get common_start;

  /// No description provided for @common_cancel.
  ///
  /// In he, this message translates to:
  /// **'ביטול'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In he, this message translates to:
  /// **'שמור'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In he, this message translates to:
  /// **'מחק'**
  String get common_delete;

  /// No description provided for @common_confirm.
  ///
  /// In he, this message translates to:
  /// **'אישור'**
  String get common_confirm;

  /// No description provided for @common_error.
  ///
  /// In he, this message translates to:
  /// **'שגיאה'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In he, this message translates to:
  /// **'הצלחה'**
  String get common_success;

  /// No description provided for @common_add.
  ///
  /// In he, this message translates to:
  /// **'הוסף'**
  String get common_add;

  /// No description provided for @common_edit.
  ///
  /// In he, this message translates to:
  /// **'עריכה'**
  String get common_edit;

  /// No description provided for @common_calendar_title.
  ///
  /// In he, this message translates to:
  /// **'לוח משמרות'**
  String get common_calendar_title;

  /// No description provided for @common_tagline.
  ///
  /// In he, this message translates to:
  /// **'מעקב שעות עבודה חכם'**
  String get common_tagline;

  /// No description provided for @common_hours_suffix.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get common_hours_suffix;

  /// No description provided for @common_min_suffix.
  ///
  /// In he, this message translates to:
  /// **'דק\''**
  String get common_min_suffix;

  /// No description provided for @common_net.
  ///
  /// In he, this message translates to:
  /// **'נטו'**
  String get common_net;

  /// No description provided for @common_shifts_count.
  ///
  /// In he, this message translates to:
  /// **'משמרות'**
  String get common_shifts_count;

  /// No description provided for @common_delete_shit_short.
  ///
  /// In he, this message translates to:
  /// **'מחיקת משמרת'**
  String get common_delete_shit_short;

  /// No description provided for @common_delete_shit_expanded.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את המשמרת מיום '**
  String get common_delete_shit_expanded;

  /// No description provided for @common_delete_shift_after.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נמחקה בהצלחה'**
  String get common_delete_shift_after;

  /// No description provided for @common_save_and_finish.
  ///
  /// In he, this message translates to:
  /// **'שמור וסיים'**
  String get common_save_and_finish;

  /// No description provided for @common_reset.
  ///
  /// In he, this message translates to:
  /// **'אפס'**
  String get common_reset;

  /// No description provided for @common_reset_and_cancel.
  ///
  /// In he, this message translates to:
  /// **'ביטול ואיפוס'**
  String get common_reset_and_cancel;

  /// No description provided for @common_undo.
  ///
  /// In he, this message translates to:
  /// **'ביטול'**
  String get common_undo;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In he, this message translates to:
  /// **'ברוכים הבאים ל-Shiftly'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האפליקציה שתעזור לך לעקוב אחרי המשמרות, השכר והטיפים שלך בקלות ובדיוק.'**
  String get onboarding_welcome_subtitle;

  /// No description provided for @onboarding_welcome_description.
  ///
  /// In he, this message translates to:
  /// **'בוא נגדיר כמה דברים בסיסיים כדי להתחיל.'**
  String get onboarding_welcome_description;

  /// No description provided for @onboarding_language_title.
  ///
  /// In he, this message translates to:
  /// **'שפת אפליקציה'**
  String get onboarding_language_title;

  /// No description provided for @onboarding_language_subtitle.
  ///
  /// In he, this message translates to:
  /// **'בחר את השפה המועדפת עליך.'**
  String get onboarding_language_subtitle;

  /// No description provided for @onboarding_currency_title.
  ///
  /// In he, this message translates to:
  /// **'בחירת מטבע'**
  String get onboarding_currency_title;

  /// No description provided for @onboarding_currency_subtitle.
  ///
  /// In he, this message translates to:
  /// **'באיזה מטבע תרצה להשתמש להצגת השכר וההוצאות?'**
  String get onboarding_currency_subtitle;

  /// No description provided for @onboarding_breaks_title.
  ///
  /// In he, this message translates to:
  /// **'הגדרות הפסקה'**
  String get onboarding_breaks_title;

  /// No description provided for @onboarding_breaks_subtitle.
  ///
  /// In he, this message translates to:
  /// **'כמה זמן נמשכת הפסקה בדרך כלל?'**
  String get onboarding_breaks_subtitle;

  /// No description provided for @onboarding_breaks_enable.
  ///
  /// In he, this message translates to:
  /// **'אפשר הפסקות'**
  String get onboarding_breaks_enable;

  /// No description provided for @onboarding_breaks_paid_label.
  ///
  /// In he, this message translates to:
  /// **'הפסקה בתשלום (דקות)'**
  String get onboarding_breaks_paid_label;

  /// No description provided for @onboarding_breaks_unpaid_label.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ללא תשלום (דקות)'**
  String get onboarding_breaks_unpaid_label;

  /// No description provided for @onboarding_reminders_title.
  ///
  /// In he, this message translates to:
  /// **'תזכורות למשמרת'**
  String get onboarding_reminders_title;

  /// No description provided for @onboarding_reminders_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האם תרצה לקבל תזכורת לפני שהמשמרת מתחילה?'**
  String get onboarding_reminders_subtitle;

  /// No description provided for @onboarding_reminders_enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל תזכורות'**
  String get onboarding_reminders_enable;

  /// No description provided for @onboarding_reminders_time_label.
  ///
  /// In he, this message translates to:
  /// **'כמה זמן לפני? (שעות)'**
  String get onboarding_reminders_time_label;

  /// No description provided for @onboarding_reminders_hours.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get onboarding_reminders_hours;

  /// No description provided for @onboarding_auto_expenses_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות קבועות'**
  String get onboarding_auto_expenses_title;

  /// No description provided for @onboarding_auto_expenses_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האם יש לך הוצאות קבועות בכל משמרת? (למשל נסיעות)'**
  String get onboarding_auto_expenses_subtitle;

  /// No description provided for @onboarding_auto_expenses_enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל הוצאות אוטומטיות'**
  String get onboarding_auto_expenses_enable;

  /// No description provided for @onboarding_auto_expenses_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה'**
  String get onboarding_auto_expenses_add_button;

  /// No description provided for @onboarding_auto_expenses_desc_label.
  ///
  /// In he, this message translates to:
  /// **'תיאור'**
  String get onboarding_auto_expenses_desc_label;

  /// No description provided for @onboarding_auto_expenses_amount_label.
  ///
  /// In he, this message translates to:
  /// **'₪'**
  String get onboarding_auto_expenses_amount_label;

  /// No description provided for @onboarding_auto_expenses_invalid_amount.
  ///
  /// In he, this message translates to:
  /// **'סכום חייב להיות גדול מ-0'**
  String get onboarding_auto_expenses_invalid_amount;

  /// No description provided for @onboarding_auto_incomes_title.
  ///
  /// In he, this message translates to:
  /// **'הכנסות קבועות'**
  String get onboarding_auto_incomes_title;

  /// No description provided for @onboarding_auto_incomes_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האם יש לך הכנסות קבועות בכל משמרת? (למשל החזר נסיעות מעסיק)'**
  String get onboarding_auto_incomes_subtitle;

  /// No description provided for @onboarding_auto_incomes_enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל הכנסות אוטומטיות'**
  String get onboarding_auto_incomes_enable;

  /// No description provided for @onboarding_auto_incomes_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הכנסה קבועה'**
  String get onboarding_auto_incomes_add_button;

  /// No description provided for @onboarding_job_types_title.
  ///
  /// In he, this message translates to:
  /// **'סוגי משמרות ושכר'**
  String get onboarding_job_types_title;

  /// No description provided for @onboarding_job_types_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הגדר את התפקידים השונים שלך ואת השכר לשעה.'**
  String get onboarding_job_types_subtitle;

  /// No description provided for @onboarding_job_types_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוספת סוג עבודה'**
  String get onboarding_job_types_add_button;

  /// No description provided for @onboarding_job_types_edit_button.
  ///
  /// In he, this message translates to:
  /// **'עריכת סוג עבודה'**
  String get onboarding_job_types_edit_button;

  /// No description provided for @onboarding_job_types_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת תפקיד'**
  String get onboarding_job_types_delete_title;

  /// No description provided for @onboarding_job_types_delete_desc.
  ///
  /// In he, this message translates to:
  /// **'האם למחוק את התפקיד '**
  String get onboarding_job_types_delete_desc;

  /// No description provided for @onboarding_job_types_rate_suffix.
  ///
  /// In he, this message translates to:
  /// **'לשעה'**
  String get onboarding_job_types_rate_suffix;

  /// No description provided for @onboarding_job_types_same.
  ///
  /// In he, this message translates to:
  /// **'תפקיד בשם זה כבר קיים'**
  String get onboarding_job_types_same;

  /// No description provided for @default_job_buffet.
  ///
  /// In he, this message translates to:
  /// **'מזנון'**
  String get default_job_buffet;

  /// No description provided for @default_job_steward.
  ///
  /// In he, this message translates to:
  /// **'סדרן'**
  String get default_job_steward;

  /// No description provided for @default_job_unloading.
  ///
  /// In he, this message translates to:
  /// **'פריקה'**
  String get default_job_unloading;

  /// No description provided for @default_expenses_trips.
  ///
  /// In he, this message translates to:
  /// **'נסיעות'**
  String get default_expenses_trips;

  /// No description provided for @settings_title.
  ///
  /// In he, this message translates to:
  /// **'הגדרות'**
  String get settings_title;

  /// No description provided for @settings_section_app.
  ///
  /// In he, this message translates to:
  /// **'אפליקציה'**
  String get settings_section_app;

  /// No description provided for @settings_section_reminders.
  ///
  /// In he, this message translates to:
  /// **'תזכורות משמרת'**
  String get settings_section_reminders;

  /// No description provided for @settings_section_breaks.
  ///
  /// In he, this message translates to:
  /// **'זמני הפסקות (דקות)'**
  String get settings_section_breaks;

  /// No description provided for @settings_section_danger.
  ///
  /// In he, this message translates to:
  /// **'אזור מסוכן'**
  String get settings_section_danger;

  /// No description provided for @settings_field_notifications.
  ///
  /// In he, this message translates to:
  /// **'התראות'**
  String get settings_field_notifications;

  /// No description provided for @settings_field_notifications_sub.
  ///
  /// In he, this message translates to:
  /// **'אפשר שליחת התראות מהאפליקציה'**
  String get settings_field_notifications_sub;

  /// No description provided for @settings_field_theme.
  ///
  /// In he, this message translates to:
  /// **'ערכת נושא'**
  String get settings_field_theme;

  /// No description provided for @settings_field_language.
  ///
  /// In he, this message translates to:
  /// **'שפת אפליקציה'**
  String get settings_field_language;

  /// No description provided for @settings_field_currency.
  ///
  /// In he, this message translates to:
  /// **'מטבע תצוגה'**
  String get settings_field_currency;

  /// No description provided for @settings_field_currency_sub.
  ///
  /// In he, this message translates to:
  /// **'המטבע שיוצג עבור שכר והוצאות'**
  String get settings_field_currency_sub;

  /// No description provided for @settings_field_reminder_time.
  ///
  /// In he, this message translates to:
  /// **'זמן תזכורת (שעות)'**
  String get settings_field_reminder_time;

  /// No description provided for @settings_field_breaks_enabled.
  ///
  /// In he, this message translates to:
  /// **'אפשר הפסקות'**
  String get settings_field_breaks_enabled;

  /// No description provided for @settings_field_breaks_enabled_sub.
  ///
  /// In he, this message translates to:
  /// **'הצג או הסתר הגדרות הפסקה באפליקציה'**
  String get settings_field_breaks_enabled_sub;

  /// No description provided for @settings_field_paid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה קצרה (בתשלום)'**
  String get settings_field_paid_break;

  /// No description provided for @settings_field_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ארוכה (ללא תשלום)'**
  String get settings_field_unpaid_break;

  /// No description provided for @settings_action_update_breaks.
  ///
  /// In he, this message translates to:
  /// **'עדכן זמנים'**
  String get settings_action_update_breaks;

  /// No description provided for @settings_action_factory_reset.
  ///
  /// In he, this message translates to:
  /// **'איפוס נתונים מלא'**
  String get settings_action_factory_reset;

  /// No description provided for @settings_action_factory_reset_sub.
  ///
  /// In he, this message translates to:
  /// **'מחיקת כל המשמרות, התפקידים וההוצאות לצמיתות'**
  String get settings_action_factory_reset_sub;

  /// No description provided for @settings_dialog_update_breaks_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון זמני הפסקה'**
  String get settings_dialog_update_breaks_title;

  /// No description provided for @settings_dialog_factory_reset_title.
  ///
  /// In he, this message translates to:
  /// **'איפוס נתונים?'**
  String get settings_dialog_factory_reset_title;

  /// No description provided for @settings_dialog_factory_reset_content.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את כל נתוני העבודה ולאפס את האפליקציה? פעולה זו אינה ניתנת לביטול.'**
  String get settings_dialog_factory_reset_content;

  /// No description provided for @settings_dialog_final_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'אישור סופי ומוחלט'**
  String get settings_dialog_final_confirm_title;

  /// No description provided for @settings_dialog_final_confirm_content_1.
  ///
  /// In he, this message translates to:
  /// **'שימו לב: כל היסטוריית המשמרות, השכר וההוצאות תימחק לעד.'**
  String get settings_dialog_final_confirm_content_1;

  /// No description provided for @settings_dialog_final_confirm_content_2.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק הכל?'**
  String get settings_dialog_final_confirm_content_2;

  /// No description provided for @settings_dialog_final_confirm_button.
  ///
  /// In he, this message translates to:
  /// **'מחק הכל לצמיתות'**
  String get settings_dialog_final_confirm_button;

  /// No description provided for @settings_dialog_error_enter_desc.
  ///
  /// In he, this message translates to:
  /// **'נא להזין תיאור לכל הוצאה קבועה'**
  String get settings_dialog_error_enter_desc;

  /// No description provided for @settings_dialog_error_enter_income_desc.
  ///
  /// In he, this message translates to:
  /// **'נא להזין תיאור לכל הכנסה קבועה'**
  String get settings_dialog_error_enter_income_desc;

  /// No description provided for @settings_theme_system.
  ///
  /// In he, this message translates to:
  /// **'מערכת'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In he, this message translates to:
  /// **'יום'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In he, this message translates to:
  /// **'לילה'**
  String get settings_theme_dark;

  /// No description provided for @settings_language_he.
  ///
  /// In he, this message translates to:
  /// **'עברית'**
  String get settings_language_he;

  /// No description provided for @settings_language_en.
  ///
  /// In he, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_current_rate.
  ///
  /// In he, this message translates to:
  /// **'תעריף נוכחי'**
  String get settings_current_rate;

  /// No description provided for @settings_wage_history_title.
  ///
  /// In he, this message translates to:
  /// **'היסטוריית שכר'**
  String get settings_wage_history_title;

  /// No description provided for @settings_job_name_label.
  ///
  /// In he, this message translates to:
  /// **'שם התפקיד'**
  String get settings_job_name_label;

  /// No description provided for @settings_job_rate_label.
  ///
  /// In he, this message translates to:
  /// **'תעריף שעתי (חדש)'**
  String get settings_job_rate_label;

  /// No description provided for @settings_job_start_date_label.
  ///
  /// In he, this message translates to:
  /// **'תאריך תחילה'**
  String get settings_job_start_date_label;

  /// No description provided for @settings_job_error_name_empty.
  ///
  /// In he, this message translates to:
  /// **'נא להזין שם לתפקיד'**
  String get settings_job_error_name_empty;

  /// No description provided for @settings_job_error_exists.
  ///
  /// In he, this message translates to:
  /// **'תפקיד בשם זה כבר קיים'**
  String get settings_job_error_exists;

  /// No description provided for @settings_job_error_negative_rate.
  ///
  /// In he, this message translates to:
  /// **'השכר לא יכול להיות שלילי'**
  String get settings_job_error_negative_rate;

  /// No description provided for @settings_job_add_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'הוספת תפקיד'**
  String get settings_job_add_confirm_title;

  /// No description provided for @settings_job_edit_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון תפקיד'**
  String get settings_job_edit_confirm_title;

  /// No description provided for @settings_job_save_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם לשמור את התפקיד \"[[name]]\" עם שכר של [[rate]] החל מיום [[date]]?'**
  String get settings_job_save_confirm_content;

  /// No description provided for @settings_job_delete_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת תפקיד'**
  String get settings_job_delete_confirm_title;

  /// No description provided for @settings_job_delete_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את התפקיד \"[[name]]\"?'**
  String get settings_job_delete_confirm_content;

  /// No description provided for @settings_job_deleted_msg.
  ///
  /// In he, this message translates to:
  /// **'תפקיד \"[[name]]\" נמחק'**
  String get settings_job_deleted_msg;

  /// No description provided for @settings_dialog_update_breaks_content.
  ///
  /// In he, this message translates to:
  /// **'האם לעדכן את זמני ברירת המחדל ל-[[paid]] דק\' בתשלום ו-[[unpaid]] דק\' ללא תשלום?'**
  String get settings_dialog_update_breaks_content;

  /// No description provided for @settings_breaks_updated_msg.
  ///
  /// In he, this message translates to:
  /// **'זמני ההפסקות עודכנו'**
  String get settings_breaks_updated_msg;

  /// No description provided for @settings_jobs_empty.
  ///
  /// In he, this message translates to:
  /// **'לא נמצאו תפקידים.'**
  String get settings_jobs_empty;

  /// No description provided for @settings_reset_success_msg.
  ///
  /// In he, this message translates to:
  /// **'האפליקציה אותחלה בהצלחה'**
  String get settings_reset_success_msg;

  /// No description provided for @home_empty_state_title.
  ///
  /// In he, this message translates to:
  /// **'עדיין לא נרשמו משמרות'**
  String get home_empty_state_title;

  /// No description provided for @home_empty_state_subtitle.
  ///
  /// In he, this message translates to:
  /// **'לחץ על \"משמרת חדשה\" כדי להתחיל'**
  String get home_empty_state_subtitle;

  /// No description provided for @home_total_card_title.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ הצטבר (נטו פחות הוצאות)'**
  String get home_total_card_title;

  /// No description provided for @home_total_card_hours.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get home_total_card_hours;

  /// No description provided for @home_total_card_base.
  ///
  /// In he, this message translates to:
  /// **'בסיס'**
  String get home_total_card_base;

  /// No description provided for @home_total_card_tips.
  ///
  /// In he, this message translates to:
  /// **'טיפים'**
  String get home_total_card_tips;

  /// No description provided for @home_total_card_expenses.
  ///
  /// In he, this message translates to:
  /// **'הוצאות'**
  String get home_total_card_expenses;

  /// No description provided for @home_active_timer_break.
  ///
  /// In he, this message translates to:
  /// **'משמרת בהפסקה...'**
  String get home_active_timer_break;

  /// No description provided for @home_active_timer_active.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה:'**
  String get home_active_timer_active;

  /// No description provided for @home_active_timer_time.
  ///
  /// In he, this message translates to:
  /// **'זמן:'**
  String get home_active_timer_time;

  /// No description provided for @home_shift_list_net_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ נטו'**
  String get home_shift_list_net_total;

  /// No description provided for @home_shift_list_no_shifts.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות ביום זה'**
  String get home_shift_list_no_shifts;

  /// No description provided for @home_shift_list_select_day.
  ///
  /// In he, this message translates to:
  /// **'בחר יום להצגת משמרות'**
  String get home_shift_list_select_day;

  /// No description provided for @home_shift_list_shifts_on.
  ///
  /// In he, this message translates to:
  /// **'משמרות ב-'**
  String get home_shift_list_shifts_on;

  /// No description provided for @home_action_new_shift.
  ///
  /// In he, this message translates to:
  /// **'משמרת חדשה'**
  String get home_action_new_shift;

  /// No description provided for @home_action_calendar.
  ///
  /// In he, this message translates to:
  /// **'לוח משמרות'**
  String get home_action_calendar;

  /// No description provided for @expenses_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות והכנסות'**
  String get expenses_title;

  /// No description provided for @expenses_tab_expenses.
  ///
  /// In he, this message translates to:
  /// **'הוצאות'**
  String get expenses_tab_expenses;

  /// No description provided for @expenses_tab_incomes.
  ///
  /// In he, this message translates to:
  /// **'הכנסות מיוחדות'**
  String get expenses_tab_incomes;

  /// No description provided for @expenses_auto_section_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות קבועות למשמרת'**
  String get expenses_auto_section_title;

  /// No description provided for @expenses_auto_section_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאות קבועות לכל משמרת חדשה'**
  String get expenses_auto_section_subtitle;

  /// No description provided for @expenses_auto_section_enable.
  ///
  /// In he, this message translates to:
  /// **'הוצאות אוטומטיות'**
  String get expenses_auto_section_enable;

  /// No description provided for @expenses_history_section_title.
  ///
  /// In he, this message translates to:
  /// **'פירוט הוצאות חודשי'**
  String get expenses_history_section_title;

  /// No description provided for @expenses_action_add_auto.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה קבועה'**
  String get expenses_action_add_auto;

  /// No description provided for @expenses_action_update_settings.
  ///
  /// In he, this message translates to:
  /// **'עדכן הגדרות'**
  String get expenses_action_update_settings;

  /// No description provided for @expenses_action_new_expense.
  ///
  /// In he, this message translates to:
  /// **'הוצאה חדשה'**
  String get expenses_action_new_expense;

  /// No description provided for @expenses_dialog_add_title.
  ///
  /// In he, this message translates to:
  /// **'הוספת הוצאה'**
  String get expenses_dialog_add_title;

  /// No description provided for @expenses_dialog_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת הוצאה'**
  String get expenses_dialog_edit_title;

  /// No description provided for @expenses_dialog_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת הוצאה'**
  String get expenses_dialog_delete_title;

  /// No description provided for @expenses_no_history.
  ///
  /// In he, this message translates to:
  /// **'אין הוצאות רשומות'**
  String get expenses_no_history;

  /// No description provided for @expenses_save_expense_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם לשמור את ההוצאה \"[[desc]]\" בסך [[amount]]?'**
  String get expenses_save_expense_confirm_content;

  /// No description provided for @expenses_delete_expense_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם למחוק את ההוצאה \"[[desc]]\" בסך [[amount]]?'**
  String get expenses_delete_expense_confirm_content;

  /// No description provided for @expenses_total_label.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get expenses_total_label;

  /// No description provided for @expenses_auto_updated_msg.
  ///
  /// In he, this message translates to:
  /// **'הגדרות הוצאות אוטומטיות עודכנו'**
  String get expenses_auto_updated_msg;

  /// No description provided for @expenses_deleted_msg.
  ///
  /// In he, this message translates to:
  /// **'הוצאה נמחקה'**
  String get expenses_deleted_msg;

  /// No description provided for @expenses_link_shift_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'שיוך למשמרת'**
  String get expenses_link_shift_dialog_title;

  /// No description provided for @expenses_link_shift_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'נמצאה משמרת בתאריך זה. האם תרצה לשייך את ה[[type]] למשמרת או לשמור כעצמאי?'**
  String get expenses_link_shift_dialog_content;

  /// No description provided for @expenses_link_shift_button.
  ///
  /// In he, this message translates to:
  /// **'שייך למשמרת'**
  String get expenses_link_shift_button;

  /// No description provided for @expenses_save_standalone_button.
  ///
  /// In he, this message translates to:
  /// **'שמור כעצמאי'**
  String get expenses_save_standalone_button;

  /// No description provided for @expenses_no_shift_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'אין משמרת בתאריך'**
  String get expenses_no_shift_dialog_title;

  /// No description provided for @expenses_no_shift_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'אין משמרת בתאריך זה. האם בכל זאת ליצור את ה[[type]]?'**
  String get expenses_no_shift_dialog_content;

  /// No description provided for @expenses_create_anyway_button.
  ///
  /// In he, this message translates to:
  /// **'צור בכל זאת'**
  String get expenses_create_anyway_button;

  /// No description provided for @expenses_auto_incomes_updated_msg.
  ///
  /// In he, this message translates to:
  /// **'הגדרות הכנסות אוטומטיות עודכנו'**
  String get expenses_auto_incomes_updated_msg;

  /// No description provided for @expenses_auto_incomes_section_title.
  ///
  /// In he, this message translates to:
  /// **'הכנסות קבועות למשמרת'**
  String get expenses_auto_incomes_section_title;

  /// No description provided for @expenses_auto_incomes_section_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הוסף הכנסות קבועות לכל משמרת חדשה'**
  String get expenses_auto_incomes_section_subtitle;

  /// No description provided for @expenses_auto_incomes_section_enable.
  ///
  /// In he, this message translates to:
  /// **'הכנסות אוטומטיות'**
  String get expenses_auto_incomes_section_enable;

  /// No description provided for @incomes_history_section_title.
  ///
  /// In he, this message translates to:
  /// **'פירוט הכנסות חודשי'**
  String get incomes_history_section_title;

  /// No description provided for @incomes_action_new_income.
  ///
  /// In he, this message translates to:
  /// **'הכנסה חדשה'**
  String get incomes_action_new_income;

  /// No description provided for @incomes_dialog_add_title.
  ///
  /// In he, this message translates to:
  /// **'הוספת הכנסה מיוחדת'**
  String get incomes_dialog_add_title;

  /// No description provided for @incomes_dialog_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת הכנסה'**
  String get incomes_dialog_edit_title;

  /// No description provided for @incomes_dialog_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת הכנסה'**
  String get incomes_dialog_delete_title;

  /// No description provided for @incomes_no_history.
  ///
  /// In he, this message translates to:
  /// **'אין הכנסות מיוחדות רשומות'**
  String get incomes_no_history;

  /// No description provided for @incomes_save_income_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם לשמור את ההכנסה \"[[desc]]\" בסך [[amount]]?'**
  String get incomes_save_income_confirm_content;

  /// No description provided for @incomes_delete_income_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם למחוק את ההכנסה \"[[desc]]\" בסך [[amount]]?'**
  String get incomes_delete_income_confirm_content;

  /// No description provided for @incomes_deleted_msg.
  ///
  /// In he, this message translates to:
  /// **'הכנסה נמחקה'**
  String get incomes_deleted_msg;

  /// No description provided for @incomes_info_card_title.
  ///
  /// In he, this message translates to:
  /// **'מהן הכנסות מיוחדות?'**
  String get incomes_info_card_title;

  /// No description provided for @incomes_info_card_desc.
  ///
  /// In he, this message translates to:
  /// **'הכנסות חד-פעמיות או תשלומים מיוחדים מהמעסיק (כגון החזרי נסיעות, בונוסים או מענקים) שמתווספים לחישוב הנטו החודשי.'**
  String get incomes_info_card_desc;

  /// No description provided for @add_shift_title.
  ///
  /// In he, this message translates to:
  /// **'רישום משמרת'**
  String get add_shift_title;

  /// No description provided for @add_shift_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת משמרת'**
  String get add_shift_edit_title;

  /// No description provided for @add_shift_timer_tab.
  ///
  /// In he, this message translates to:
  /// **'טיימר'**
  String get add_shift_timer_tab;

  /// No description provided for @add_shift_manual_tab.
  ///
  /// In he, this message translates to:
  /// **'ידני'**
  String get add_shift_manual_tab;

  /// No description provided for @add_shift_paste_tab.
  ///
  /// In he, this message translates to:
  /// **'הדבקה'**
  String get add_shift_paste_tab;

  /// No description provided for @add_shift_timer_accumulated_live.
  ///
  /// In he, this message translates to:
  /// **'נצבר בשידור חי'**
  String get add_shift_timer_accumulated_live;

  /// No description provided for @add_shift_timer_countdown.
  ///
  /// In he, this message translates to:
  /// **'ספירה לאחור: '**
  String get add_shift_timer_countdown;

  /// No description provided for @add_shift_timer_break_paid.
  ///
  /// In he, this message translates to:
  /// **'בהפסקה בתשלום...'**
  String get add_shift_timer_break_paid;

  /// No description provided for @add_shift_timer_break_unpaid.
  ///
  /// In he, this message translates to:
  /// **'בהפסקה ללא תשלום (השעון עצר)'**
  String get add_shift_timer_break_unpaid;

  /// No description provided for @add_shift_timer_total_break_unpaid.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ הפסקה (לא בתשלום):'**
  String get add_shift_timer_total_break_unpaid;

  /// No description provided for @add_shift_timer_resume_work.
  ///
  /// In he, this message translates to:
  /// **'חזור לעבודה'**
  String get add_shift_timer_resume_work;

  /// No description provided for @add_shift_timer_stop_shift.
  ///
  /// In he, this message translates to:
  /// **'סיים משמרת'**
  String get add_shift_timer_stop_shift;

  /// No description provided for @add_shift_timer_start_shift.
  ///
  /// In he, this message translates to:
  /// **'התחל משמרת'**
  String get add_shift_timer_start_shift;

  /// No description provided for @add_shift_timer_continue_work.
  ///
  /// In he, this message translates to:
  /// **'המשך עבודה'**
  String get add_shift_timer_continue_work;

  /// No description provided for @add_shift_timer_stopped_msg.
  ///
  /// In he, this message translates to:
  /// **'הטיימר נעצר. האם ברצונך לשמור את המשמרת או להמשיך בעבודה?'**
  String get add_shift_timer_stopped_msg;

  /// No description provided for @add_shift_timer_reset_title.
  ///
  /// In he, this message translates to:
  /// **'איפוס טיימר'**
  String get add_shift_timer_reset_title;

  /// No description provided for @add_shift_timer_reset_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לאפס את הטיימר? כל המידע הנוכחי יימחק.'**
  String get add_shift_timer_reset_desc;

  /// No description provided for @add_shift_timer_resume_shift.
  ///
  /// In he, this message translates to:
  /// **'המשך משמרת'**
  String get add_shift_timer_resume_shift;

  /// No description provided for @add_shift_manual_time_section.
  ///
  /// In he, this message translates to:
  /// **'זמן'**
  String get add_shift_manual_time_section;

  /// No description provided for @add_shift_manual_date_label.
  ///
  /// In he, this message translates to:
  /// **'תאריך'**
  String get add_shift_manual_date_label;

  /// No description provided for @add_shift_manual_start_time_label.
  ///
  /// In he, this message translates to:
  /// **'שעת התחלה'**
  String get add_shift_manual_start_time_label;

  /// No description provided for @add_shift_manual_end_time_label.
  ///
  /// In he, this message translates to:
  /// **'שעת סיום'**
  String get add_shift_manual_end_time_label;

  /// No description provided for @add_shift_manual_break_type_section.
  ///
  /// In he, this message translates to:
  /// **'סוג הפסקה'**
  String get add_shift_manual_break_type_section;

  /// No description provided for @add_shift_manual_no_break.
  ///
  /// In he, this message translates to:
  /// **'ללא'**
  String get add_shift_manual_no_break;

  /// No description provided for @add_shift_manual_paid_break.
  ///
  /// In he, this message translates to:
  /// **'בתשלום'**
  String get add_shift_manual_paid_break;

  /// No description provided for @add_shift_manual_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'ללא תשלום'**
  String get add_shift_manual_unpaid_break;

  /// No description provided for @add_shift_manual_work_tips_section.
  ///
  /// In he, this message translates to:
  /// **'עבודה וטיפים'**
  String get add_shift_manual_work_tips_section;

  /// No description provided for @add_shift_manual_job_type_label.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה'**
  String get add_shift_manual_job_type_label;

  /// No description provided for @add_shift_paste_title.
  ///
  /// In he, this message translates to:
  /// **'הדבקה חופשית'**
  String get add_shift_paste_title;

  /// No description provided for @add_shift_paste_default_job_label.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה ברירת מחדל'**
  String get add_shift_paste_default_job_label;

  /// No description provided for @add_shift_paste_format_info.
  ///
  /// In he, this message translates to:
  /// **'פורמט: DD.MM.YYYY - HH:mm - HH:mm [הפסקה] [+ tips]\nהפסקות: ללא / 20 דקות / 45 דקות'**
  String get add_shift_paste_format_info;

  /// No description provided for @add_shift_paste_hint.
  ///
  /// In he, this message translates to:
  /// **'הדבק משמרות כאן...\nלדוגמה:\n24.6.2026 - 17:30 - 23:00 45 דקות + 50'**
  String get add_shift_paste_hint;

  /// No description provided for @add_shift_paste_parse_button.
  ///
  /// In he, this message translates to:
  /// **'פענח ושמור הכל'**
  String get add_shift_paste_parse_button;

  /// No description provided for @add_shift_paste_parse_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'פענוח משמרות'**
  String get add_shift_paste_parse_dialog_title;

  /// No description provided for @add_shift_paste_parse_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם לפענח ולשמור משמרות מהטקסט שהודבק?'**
  String get add_shift_paste_parse_dialog_desc;

  /// No description provided for @add_shift_paste_error.
  ///
  /// In he, this message translates to:
  /// **'בדוק שוב שהפורמט שהזנת תקין'**
  String get add_shift_paste_error;

  /// No description provided for @add_shift_tips_title.
  ///
  /// In he, this message translates to:
  /// **'טיפים'**
  String get add_shift_tips_title;

  /// No description provided for @add_shift_tips_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get add_shift_tips_total;

  /// No description provided for @add_shift_tips_hint.
  ///
  /// In he, this message translates to:
  /// **'סכום טיפ'**
  String get add_shift_tips_hint;

  /// No description provided for @add_shift_tips_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף טיפ'**
  String get add_shift_tips_add_button;

  /// No description provided for @add_shift_expenses_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות למשמרת'**
  String get add_shift_expenses_title;

  /// No description provided for @add_shift_expenses_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get add_shift_expenses_total;

  /// No description provided for @add_shift_expenses_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה'**
  String get add_shift_expenses_add_button;

  /// No description provided for @add_shift_incomes_title.
  ///
  /// In he, this message translates to:
  /// **'הכנסות למשמרת'**
  String get add_shift_incomes_title;

  /// No description provided for @add_shift_incomes_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get add_shift_incomes_total;

  /// No description provided for @add_shift_incomes_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הכנסה'**
  String get add_shift_incomes_add_button;

  /// No description provided for @add_shift_shift_ended_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'שמירת משמרת'**
  String get add_shift_shift_ended_dialog_title;

  /// No description provided for @add_shift_shift_ended_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?'**
  String get add_shift_shift_ended_dialog_desc;

  /// No description provided for @add_shift_shift_ended_edit_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?'**
  String get add_shift_shift_ended_edit_dialog_desc;

  /// No description provided for @add_shift_shift_edit_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון משמרת'**
  String get add_shift_shift_edit_dialog_title;

  /// No description provided for @add_shift_shift_saved.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נשמרה בהצלחה'**
  String get add_shift_shift_saved;

  /// No description provided for @add_shift_overlap_title.
  ///
  /// In he, this message translates to:
  /// **'חפיפה בין משמרות'**
  String get add_shift_overlap_title;

  /// No description provided for @add_shift_overlap_content.
  ///
  /// In he, this message translates to:
  /// **'נמצאו {count} משמרות חופפות:\n\n{details}\n\nלשמור בכל זאת?'**
  String add_shift_overlap_content(num count, String details);

  /// No description provided for @add_shift_overlap_confirm.
  ///
  /// In he, this message translates to:
  /// **'שמור בכל זאת'**
  String get add_shift_overlap_confirm;

  /// No description provided for @add_shift_overlap_unknown_job.
  ///
  /// In he, this message translates to:
  /// **'עבודה לא ידועה'**
  String get add_shift_overlap_unknown_job;

  /// No description provided for @add_shift_pick_a_job.
  ///
  /// In he, this message translates to:
  /// **'בחר סוג עבודה קודם'**
  String get add_shift_pick_a_job;

  /// No description provided for @add_shift_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת משמרת'**
  String get add_shift_delete_title;

  /// No description provided for @add_shift_delete_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את המשמרת מיום'**
  String get add_shift_delete_desc;

  /// No description provided for @add_shift_delete_msg.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נמחקה בהצלחה: '**
  String get add_shift_delete_msg;

  /// No description provided for @notification_reminder_title.
  ///
  /// In he, this message translates to:
  /// **'תזכורת למשמרת'**
  String get notification_reminder_title;

  /// No description provided for @notification_reminder_body.
  ///
  /// In he, this message translates to:
  /// **'המשמרת שלך ([[name]]) מתחילה בעוד [[time]]!'**
  String get notification_reminder_body;

  /// No description provided for @notification_channel_reminders_name.
  ///
  /// In he, this message translates to:
  /// **'תזכורות משמרת'**
  String get notification_channel_reminders_name;

  /// No description provided for @notification_channel_reminders_desc.
  ///
  /// In he, this message translates to:
  /// **'תזכורת לפני תחילת משמרת'**
  String get notification_channel_reminders_desc;

  /// No description provided for @notification_timer_channel_name.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה'**
  String get notification_timer_channel_name;

  /// No description provided for @notification_timer_channel_desc.
  ///
  /// In he, this message translates to:
  /// **'מציג את זמן המשמרת הנוכחית'**
  String get notification_timer_channel_desc;

  /// No description provided for @notification_timer_title_active.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה'**
  String get notification_timer_title_active;

  /// No description provided for @notification_timer_title_paid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה בתשלום'**
  String get notification_timer_title_paid_break;

  /// No description provided for @notification_timer_title_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ללא תשלום'**
  String get notification_timer_title_unpaid_break;

  /// No description provided for @notification_timer_body_running.
  ///
  /// In he, this message translates to:
  /// **'הטיימר רץ...'**
  String get notification_timer_body_running;

  /// No description provided for @notification_timer_body_countdown.
  ///
  /// In he, this message translates to:
  /// **'ספירה לאחור: [[time]]'**
  String get notification_timer_body_countdown;

  /// No description provided for @filter_title.
  ///
  /// In he, this message translates to:
  /// **'סינון משמרות'**
  String get filter_title;

  /// No description provided for @filter_clear_all.
  ///
  /// In he, this message translates to:
  /// **'איפוס סינון'**
  String get filter_clear_all;

  /// No description provided for @filter_apply.
  ///
  /// In he, this message translates to:
  /// **'החל מסננים'**
  String get filter_apply;

  /// No description provided for @filter_wage_range.
  ///
  /// In he, this message translates to:
  /// **'טווח שכר כולל'**
  String get filter_wage_range;

  /// No description provided for @filter_tips_range.
  ///
  /// In he, this message translates to:
  /// **'טווח טיפים'**
  String get filter_tips_range;

  /// No description provided for @filter_expenses_range.
  ///
  /// In he, this message translates to:
  /// **'טווח הוצאות'**
  String get filter_expenses_range;

  /// No description provided for @filter_duration_range.
  ///
  /// In he, this message translates to:
  /// **'טווח זמן (שעות)'**
  String get filter_duration_range;

  /// No description provided for @filter_date_range.
  ///
  /// In he, this message translates to:
  /// **'טווח תאריכים'**
  String get filter_date_range;

  /// No description provided for @filter_job_type.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה'**
  String get filter_job_type;

  /// No description provided for @filter_select_all.
  ///
  /// In he, this message translates to:
  /// **'בחר הכל'**
  String get filter_select_all;

  /// No description provided for @filter_error_no_job_selected.
  ///
  /// In he, this message translates to:
  /// **'נא לבחור לפחות סוג עבודה אחד'**
  String get filter_error_no_job_selected;

  /// No description provided for @filter_min.
  ///
  /// In he, this message translates to:
  /// **'מינימום'**
  String get filter_min;

  /// No description provided for @filter_max.
  ///
  /// In he, this message translates to:
  /// **'מקסימום'**
  String get filter_max;

  /// No description provided for @filter_active_filters.
  ///
  /// In he, this message translates to:
  /// **'מסננים פעילים:'**
  String get filter_active_filters;

  /// No description provided for @filter_no_results.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות התואמות למסננים אלו'**
  String get filter_no_results;

  /// No description provided for @filter_chip_wage.
  ///
  /// In he, this message translates to:
  /// **'שכר: [[min]] - [[max]]'**
  String get filter_chip_wage;

  /// No description provided for @filter_chip_tips.
  ///
  /// In he, this message translates to:
  /// **'טיפים: [[min]] - [[max]]'**
  String get filter_chip_tips;

  /// No description provided for @filter_chip_expenses.
  ///
  /// In he, this message translates to:
  /// **'הוצאות: [[min]] - [[max]]'**
  String get filter_chip_expenses;

  /// No description provided for @filter_chip_duration.
  ///
  /// In he, this message translates to:
  /// **'זמן: [[min]] - [[max]] שעות'**
  String get filter_chip_duration;

  /// No description provided for @filter_chip_date.
  ///
  /// In he, this message translates to:
  /// **'תאריך: [[start]] - [[end]]'**
  String get filter_chip_date;

  /// No description provided for @filter_chip_job.
  ///
  /// In he, this message translates to:
  /// **'עבודה: [[name]]'**
  String get filter_chip_job;

  /// No description provided for @filter_empty_state_title.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות תואמות'**
  String get filter_empty_state_title;

  /// No description provided for @filter_empty_state_subtitle.
  ///
  /// In he, this message translates to:
  /// **'נסה לשנות את המסננים כדי לראות תוצאות'**
  String get filter_empty_state_subtitle;

  /// No description provided for @auth_login_title.
  ///
  /// In he, this message translates to:
  /// **'ברוכים השבים'**
  String get auth_login_title;

  /// No description provided for @auth_register_title.
  ///
  /// In he, this message translates to:
  /// **'יצירת חשבון חדש'**
  String get auth_register_title;

  /// No description provided for @auth_full_name_label.
  ///
  /// In he, this message translates to:
  /// **'שם מלא'**
  String get auth_full_name_label;

  /// No description provided for @auth_email_label.
  ///
  /// In he, this message translates to:
  /// **'אימייל'**
  String get auth_email_label;

  /// No description provided for @auth_password_label.
  ///
  /// In he, this message translates to:
  /// **'סיסמה'**
  String get auth_password_label;

  /// No description provided for @auth_error_name_empty.
  ///
  /// In he, this message translates to:
  /// **'נא להזין שם'**
  String get auth_error_name_empty;

  /// No description provided for @auth_error_email_invalid.
  ///
  /// In he, this message translates to:
  /// **'אימייל לא תקין'**
  String get auth_error_email_invalid;

  /// No description provided for @auth_error_password_length.
  ///
  /// In he, this message translates to:
  /// **'סיסמה חייבת להיות לפחות 6 תווים'**
  String get auth_error_password_length;

  /// No description provided for @auth_login_button.
  ///
  /// In he, this message translates to:
  /// **'התחברות'**
  String get auth_login_button;

  /// No description provided for @auth_register_button.
  ///
  /// In he, this message translates to:
  /// **'הרשמה'**
  String get auth_register_button;

  /// No description provided for @auth_no_account_link.
  ///
  /// In he, this message translates to:
  /// **'אין לך חשבון? הירשם עכשיו'**
  String get auth_no_account_link;

  /// No description provided for @auth_has_account_link.
  ///
  /// In he, this message translates to:
  /// **'כבר יש לך חשבון? התחבר'**
  String get auth_has_account_link;

  /// No description provided for @auth_error_generic.
  ///
  /// In he, this message translates to:
  /// **'שגיאה בביצוע הפעולה. נא לנסות שוב.'**
  String get auth_error_generic;

  /// No description provided for @settings_section_account.
  ///
  /// In he, this message translates to:
  /// **'חשבון'**
  String get settings_section_account;

  /// No description provided for @settings_logout_title.
  ///
  /// In he, this message translates to:
  /// **'התנתקות מהמערכת'**
  String get settings_logout_title;

  /// No description provided for @settings_logout_subtitle.
  ///
  /// In he, this message translates to:
  /// **'התנתקות מהחשבון הנוכחי'**
  String get settings_logout_subtitle;

  /// No description provided for @settings_logout_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'התנתקות'**
  String get settings_logout_dialog_title;

  /// No description provided for @settings_logout_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך להתנתק?'**
  String get settings_logout_confirm_content;

  /// No description provided for @settings_logout_confirm_button.
  ///
  /// In he, this message translates to:
  /// **'התנתק'**
  String get settings_logout_confirm_button;

  /// No description provided for @auth_login_success.
  ///
  /// In he, this message translates to:
  /// **'התחברת בהצלחה'**
  String get auth_login_success;

  /// No description provided for @auth_register_success.
  ///
  /// In he, this message translates to:
  /// **'החשבון נוצר בהצלחה'**
  String get auth_register_success;

  /// No description provided for @auth_birth_date_label.
  ///
  /// In he, this message translates to:
  /// **'תאריך לידה'**
  String get auth_birth_date_label;

  /// No description provided for @auth_error_underage.
  ///
  /// In he, this message translates to:
  /// **'על המשתמש להיות מעל גיל 12'**
  String get auth_error_underage;

  /// No description provided for @auth_error_birth_date_empty.
  ///
  /// In he, this message translates to:
  /// **'נא לבחור תאריך לידה'**
  String get auth_error_birth_date_empty;

  /// No description provided for @auth_error_email_exists.
  ///
  /// In he, this message translates to:
  /// **'כתובת אימייל זו כבר תפוסה'**
  String get auth_error_email_exists;

  /// No description provided for @auth_error_user_not_found.
  ///
  /// In he, this message translates to:
  /// **'לא נמצא משתמש קיים או שהסיסמה שגויה'**
  String get auth_error_user_not_found;

  /// No description provided for @home_welcome_back.
  ///
  /// In he, this message translates to:
  /// **'שלום, [[name]]'**
  String get home_welcome_back;

  /// No description provided for @settings_user_details_title.
  ///
  /// In he, this message translates to:
  /// **'פרטי משתמש'**
  String get settings_user_details_title;

  /// No description provided for @settings_user_name.
  ///
  /// In he, this message translates to:
  /// **'שם'**
  String get settings_user_name;

  /// No description provided for @settings_user_email.
  ///
  /// In he, this message translates to:
  /// **'אימייל'**
  String get settings_user_email;

  /// No description provided for @settings_user_password.
  ///
  /// In he, this message translates to:
  /// **'סיסמה'**
  String get settings_user_password;

  /// No description provided for @settings_user_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת פרופיל'**
  String get settings_user_edit_title;

  /// No description provided for @settings_user_update_button.
  ///
  /// In he, this message translates to:
  /// **'עדכן פרטים'**
  String get settings_user_update_button;

  /// No description provided for @settings_user_update_success.
  ///
  /// In he, this message translates to:
  /// **'הפרטים עודכנו בהצלחה'**
  String get settings_user_update_success;

  /// No description provided for @settings_logout_success.
  ///
  /// In he, this message translates to:
  /// **'התנתקת בהצלחה'**
  String get settings_logout_success;

  /// No description provided for @settings_byos_title.
  ///
  /// In he, this message translates to:
  /// **'סנכרון BYOS'**
  String get settings_byos_title;

  /// No description provided for @settings_byos_connected.
  ///
  /// In he, this message translates to:
  /// **'מחובר ל-Google Drive'**
  String get settings_byos_connected;

  /// No description provided for @settings_byos_last_backup.
  ///
  /// In he, this message translates to:
  /// **'גיבוי אחרון: [[time]]'**
  String get settings_byos_last_backup;

  /// No description provided for @settings_byos_backup_now.
  ///
  /// In he, this message translates to:
  /// **'גיבוי עכשיו'**
  String get settings_byos_backup_now;

  /// No description provided for @settings_byos_auto_sync.
  ///
  /// In he, this message translates to:
  /// **'סנכרון אוטומטי'**
  String get settings_byos_auto_sync;

  /// No description provided for @settings_byos_auto_sync_sub.
  ///
  /// In he, this message translates to:
  /// **'גיבוי שינויים באופן מיידי לענן'**
  String get settings_byos_auto_sync_sub;

  /// No description provided for @settings_byos_disconnect.
  ///
  /// In he, this message translates to:
  /// **'נתק'**
  String get settings_byos_disconnect;

  /// No description provided for @settings_byos_upgrade_title.
  ///
  /// In he, this message translates to:
  /// **'צור חשבון Shiftly'**
  String get settings_byos_upgrade_title;

  /// No description provided for @settings_byos_upgrade_subtitle.
  ///
  /// In he, this message translates to:
  /// **'העבר את נתוני ה-BYOS לענן שלנו לסנכרון מהיר יותר'**
  String get settings_byos_upgrade_subtitle;

  /// No description provided for @settings_byos_sync_backup_section.
  ///
  /// In he, this message translates to:
  /// **'סנכרון וגיבוי'**
  String get settings_byos_sync_backup_section;

  /// No description provided for @settings_byos_login_shiftly.
  ///
  /// In he, this message translates to:
  /// **'התחבר לחשבון Shiftly'**
  String get settings_byos_login_shiftly;

  /// No description provided for @settings_byos_login_shiftly_sub.
  ///
  /// In he, this message translates to:
  /// **'סנכרון מלא בענן שלנו'**
  String get settings_byos_login_shiftly_sub;

  /// No description provided for @settings_byos_method_title.
  ///
  /// In he, this message translates to:
  /// **'שיטת BYOS (Google Drive)'**
  String get settings_byos_method_title;

  /// No description provided for @settings_byos_method_sub.
  ///
  /// In he, this message translates to:
  /// **'גיבוי לענן הפרטי שלך'**
  String get settings_byos_method_sub;

  /// No description provided for @settings_byos_restore_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'סנכרון BYOS'**
  String get settings_byos_restore_dialog_title;

  /// No description provided for @settings_byos_restore_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'האם תרצה לשחזר נתונים קיימים מה-Google Drive שלך?'**
  String get settings_byos_restore_dialog_content;

  /// No description provided for @settings_byos_restore_confirm.
  ///
  /// In he, this message translates to:
  /// **'שחזר'**
  String get settings_byos_restore_confirm;

  /// No description provided for @settings_byos_restore_cancel.
  ///
  /// In he, this message translates to:
  /// **'לא כרגע'**
  String get settings_byos_restore_cancel;

  /// No description provided for @settings_byos_login_hint.
  ///
  /// In he, this message translates to:
  /// **'התחבר כדי לגבות את הנתונים לענן ולהשתמש במכשירים נוספים'**
  String get settings_byos_login_hint;

  /// No description provided for @settings_restore_success.
  ///
  /// In he, this message translates to:
  /// **'השחזור הושלם: [[shifts]] משמרות ו-[[jobs]] תפקידים שוחזרו.'**
  String get settings_restore_success;

  /// No description provided for @settings_restore_no_data.
  ///
  /// In he, this message translates to:
  /// **'לא נמצא גיבוי ב-Google Drive או שאירעה שגיאה.'**
  String get settings_restore_no_data;

  /// No description provided for @auth_sync_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'סנכרון נתונים'**
  String get auth_sync_dialog_title;

  /// No description provided for @auth_sync_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'נמצאו נתונים קיימים גם במכשיר וגם בענן. באילו נתונים תרצה להשתמש?\n\n• שמירת נתוני המכשיר תעלה אותם לענן.\n• שימוש בנתוני ענן ימחק את המידע הקיים במכשיר.'**
  String get auth_sync_dialog_content;

  /// No description provided for @auth_sync_dialog_cloud.
  ///
  /// In he, this message translates to:
  /// **'נתוני ענן'**
  String get auth_sync_dialog_cloud;

  /// No description provided for @auth_sync_dialog_local.
  ///
  /// In he, this message translates to:
  /// **'נתוני מכשיר'**
  String get auth_sync_dialog_local;

  /// No description provided for @export_title.
  ///
  /// In he, this message translates to:
  /// **'ייצוא משמרות'**
  String get export_title;

  /// No description provided for @export_format_label.
  ///
  /// In he, this message translates to:
  /// **'פורמט קובץ'**
  String get export_format_label;

  /// No description provided for @export_format_csv.
  ///
  /// In he, this message translates to:
  /// **'קובץ CSV (מתאים לאקסל)'**
  String get export_format_csv;

  /// No description provided for @export_format_txt.
  ///
  /// In he, this message translates to:
  /// **'קובץ טקסט (TXT)'**
  String get export_format_txt;

  /// No description provided for @export_range_label.
  ///
  /// In he, this message translates to:
  /// **'טווח ייצוא'**
  String get export_range_label;

  /// No description provided for @export_range_all.
  ///
  /// In he, this message translates to:
  /// **'כל המשמרות'**
  String get export_range_all;

  /// No description provided for @export_range_month.
  ///
  /// In he, this message translates to:
  /// **'חודש מסוים'**
  String get export_range_month;

  /// No description provided for @export_range_custom.
  ///
  /// In he, this message translates to:
  /// **'טווח תאריכים'**
  String get export_range_custom;

  /// No description provided for @export_start_date.
  ///
  /// In he, this message translates to:
  /// **'מתאריך'**
  String get export_start_date;

  /// No description provided for @export_end_date.
  ///
  /// In he, this message translates to:
  /// **'עד תאריך'**
  String get export_end_date;

  /// No description provided for @export_select_month.
  ///
  /// In he, this message translates to:
  /// **'בחר חודש'**
  String get export_select_month;

  /// No description provided for @export_button.
  ///
  /// In he, this message translates to:
  /// **'ייצא קובץ'**
  String get export_button;

  /// No description provided for @export_success_msg.
  ///
  /// In he, this message translates to:
  /// **'הקובץ נוצר בהצלחה ונשמר ב:'**
  String get export_success_msg;

  /// No description provided for @export_copy_button.
  ///
  /// In he, this message translates to:
  /// **'העתק תוכן ללוח'**
  String get export_copy_button;

  /// No description provided for @export_copied_msg.
  ///
  /// In he, this message translates to:
  /// **'הנתונים הועתקו ללוח בהצלחה'**
  String get export_copied_msg;

  /// No description provided for @export_empty_error.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות בטווח הנבחר לייצוא'**
  String get export_empty_error;

  /// No description provided for @analytics_title.
  ///
  /// In he, this message translates to:
  /// **'אנליטיקה ותובנות'**
  String get analytics_title;

  /// No description provided for @analytics_period_monthly.
  ///
  /// In he, this message translates to:
  /// **'חודשי'**
  String get analytics_period_monthly;

  /// No description provided for @analytics_period_yearly.
  ///
  /// In he, this message translates to:
  /// **'שנתי'**
  String get analytics_period_yearly;

  /// No description provided for @analytics_period_all_time.
  ///
  /// In he, this message translates to:
  /// **'כל הזמנים'**
  String get analytics_period_all_time;

  /// No description provided for @analytics_all_jobs.
  ///
  /// In he, this message translates to:
  /// **'כל התפקידים'**
  String get analytics_all_jobs;

  /// No description provided for @analytics_stat_total_net.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ נטו'**
  String get analytics_stat_total_net;

  /// No description provided for @analytics_stat_total_hours.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ שעות'**
  String get analytics_stat_total_hours;

  /// No description provided for @analytics_stat_avg_rate.
  ///
  /// In he, this message translates to:
  /// **'שכר שעתי אפקטיבי'**
  String get analytics_stat_avg_rate;

  /// No description provided for @analytics_stat_tips.
  ///
  /// In he, this message translates to:
  /// **'הוצאות משמרת נטו'**
  String get analytics_stat_tips;

  /// No description provided for @analytics_chart_earnings_title.
  ///
  /// In he, this message translates to:
  /// **'הכנסות מול הוצאות לפי זמן'**
  String get analytics_chart_earnings_title;

  /// No description provided for @analytics_chart_earnings_subtitle.
  ///
  /// In he, this message translates to:
  /// **'לחץ על עמודה לצפייה בפירוט שכר והוצאות'**
  String get analytics_chart_earnings_subtitle;

  /// No description provided for @analytics_chart_jobs_title.
  ///
  /// In he, this message translates to:
  /// **'פילוח לפי תפקיד'**
  String get analytics_chart_jobs_title;

  /// No description provided for @analytics_chart_jobs_by_earnings.
  ///
  /// In he, this message translates to:
  /// **'לפי שכר (₪)'**
  String get analytics_chart_jobs_by_earnings;

  /// No description provided for @analytics_chart_jobs_by_hours.
  ///
  /// In he, this message translates to:
  /// **'לפי שעות'**
  String get analytics_chart_jobs_by_hours;

  /// No description provided for @analytics_no_data.
  ///
  /// In he, this message translates to:
  /// **'אין נתונים לתקופה הנבחרת'**
  String get analytics_no_data;

  /// No description provided for @analytics_selected_breakdown.
  ///
  /// In he, this message translates to:
  /// **'פירוט יום נבחר'**
  String get analytics_selected_breakdown;

  /// No description provided for @analytics_selected_month_breakdown.
  ///
  /// In he, this message translates to:
  /// **'פירוט חודש נבחר'**
  String get analytics_selected_month_breakdown;

  /// No description provided for @analytics_base_salary.
  ///
  /// In he, this message translates to:
  /// **'שכר בסיס'**
  String get analytics_base_salary;

  /// No description provided for @analytics_chart_cumulative_title.
  ///
  /// In he, this message translates to:
  /// **'צמיחת הכנסה מצטברת'**
  String get analytics_chart_cumulative_title;

  /// No description provided for @analytics_chart_cumulative_subtitle.
  ///
  /// In he, this message translates to:
  /// **'גרירה ימינה ושמאלה לצפייה בצמיחת השכר לאורך הזמן'**
  String get analytics_chart_cumulative_subtitle;

  /// No description provided for @analytics_gross_pay.
  ///
  /// In he, this message translates to:
  /// **'ברוטו'**
  String get analytics_gross_pay;

  /// No description provided for @analytics_net_pay.
  ///
  /// In he, this message translates to:
  /// **'נטו'**
  String get analytics_net_pay;

  /// No description provided for @analytics_kpi_projected.
  ///
  /// In he, this message translates to:
  /// **'תחזית לסוף החודש'**
  String get analytics_kpi_projected;

  /// No description provided for @analytics_kpi_retention.
  ///
  /// In he, this message translates to:
  /// **'שיעור שמירת הכנסה'**
  String get analytics_kpi_retention;

  /// No description provided for @analytics_kpi_tip_yield.
  ///
  /// In he, this message translates to:
  /// **'ממוצע שעות ליום'**
  String get analytics_kpi_tip_yield;

  /// No description provided for @analytics_kpi_boost.
  ///
  /// In he, this message translates to:
  /// **'תוספת לשעת עבודה'**
  String get analytics_kpi_boost;

  /// No description provided for @analytics_chart_pace_title.
  ///
  /// In he, this message translates to:
  /// **'קצב הכנסה ותחזית חודשית'**
  String get analytics_chart_pace_title;

  /// No description provided for @analytics_chart_pace_subtitle.
  ///
  /// In he, this message translates to:
  /// **'השוואה בין קצב ההכנסה בפועל לתחזית לסוף החודש'**
  String get analytics_chart_pace_subtitle;

  /// No description provided for @analytics_chart_tod_title.
  ///
  /// In he, this message translates to:
  /// **'פילוח לפי שעות היממה'**
  String get analytics_chart_tod_title;

  /// No description provided for @analytics_chart_tod_subtitle.
  ///
  /// In he, this message translates to:
  /// **'השוואת שעות עבודה לפי פלחי היממה'**
  String get analytics_chart_tod_subtitle;

  /// No description provided for @analytics_chart_tod_dawn.
  ///
  /// In he, this message translates to:
  /// **'לפנות בוקר (04:00-06:00)'**
  String get analytics_chart_tod_dawn;

  /// No description provided for @analytics_chart_tod_morning.
  ///
  /// In he, this message translates to:
  /// **'בוקר (06:00-12:00)'**
  String get analytics_chart_tod_morning;

  /// No description provided for @analytics_chart_tod_noon.
  ///
  /// In he, this message translates to:
  /// **'צהריים (12:00-16:00)'**
  String get analytics_chart_tod_noon;

  /// No description provided for @analytics_chart_tod_afternoon.
  ///
  /// In he, this message translates to:
  /// **'אחר הצהריים (16:00-18:00)'**
  String get analytics_chart_tod_afternoon;

  /// No description provided for @analytics_chart_tod_evening.
  ///
  /// In he, this message translates to:
  /// **'ערב (18:00-22:00)'**
  String get analytics_chart_tod_evening;

  /// No description provided for @analytics_chart_tod_night.
  ///
  /// In he, this message translates to:
  /// **'לילה (22:00-06:00)'**
  String get analytics_chart_tod_night;

  /// No description provided for @analytics_chart_duration_title.
  ///
  /// In he, this message translates to:
  /// **'התפלגות אורך משמרות ועומס'**
  String get analytics_chart_duration_title;

  /// No description provided for @analytics_chart_duration_subtitle.
  ///
  /// In he, this message translates to:
  /// **'חלוקה לפי אורך המשמרות (קצרות, רגילות, ארוכות)'**
  String get analytics_chart_duration_subtitle;

  /// No description provided for @analytics_duration_short.
  ///
  /// In he, this message translates to:
  /// **'קצרות (<6 שעות)'**
  String get analytics_duration_short;

  /// No description provided for @analytics_duration_standard.
  ///
  /// In he, this message translates to:
  /// **'רגילות (6-9 שעות)'**
  String get analytics_duration_standard;

  /// No description provided for @analytics_duration_long.
  ///
  /// In he, this message translates to:
  /// **'ארוכות (>9 שעות)'**
  String get analytics_duration_long;

  /// No description provided for @analytics_insights_title.
  ///
  /// In he, this message translates to:
  /// **'תובנות ומגמות מרכזיות'**
  String get analytics_insights_title;

  /// No description provided for @analytics_insight_night_boost.
  ///
  /// In he, this message translates to:
  /// **'משמרות ערב ולילה מהוות [[percent]]% מסך שעות העבודה שלך.'**
  String get analytics_insight_night_boost;

  /// No description provided for @analytics_insight_retention.
  ///
  /// In he, this message translates to:
  /// **'הנך שומר על [[percent]]% מסך השכר בברוטו לאחר ניכוי הוצאות נסיעה.'**
  String get analytics_insight_retention;

  /// No description provided for @analytics_insight_fatigue.
  ///
  /// In he, this message translates to:
  /// **'[[percent]]% מהמשמרות שלך היו משמרות ארוכות (מעל 9 שעות).'**
  String get analytics_insight_fatigue;

  /// No description provided for @analytics_insight_tips_ratio.
  ///
  /// In he, this message translates to:
  /// **'ההוצאות הקבועות מהוות [[percent]]% מסך ההכנסות שלך.'**
  String get analytics_insight_tips_ratio;

  /// No description provided for @analytics_shifts_format.
  ///
  /// In he, this message translates to:
  /// **'{count} משמרות'**
  String analytics_shifts_format(Object count);

  /// No description provided for @analytics_hours_format.
  ///
  /// In he, this message translates to:
  /// **'{hours} שעות'**
  String analytics_hours_format(Object hours);

  /// No description provided for @analytics_no_shift_data_period.
  ///
  /// In he, this message translates to:
  /// **'אין נתוני משמרות לתקופה זו'**
  String get analytics_no_shift_data_period;

  /// No description provided for @analytics_min_shifts_hourly.
  ///
  /// In he, this message translates to:
  /// **'דרושות לפחות 2 משמרות להצגת מגמת שכר שעתי'**
  String get analytics_min_shifts_hourly;

  /// No description provided for @analytics_min_shifts_growth.
  ///
  /// In he, this message translates to:
  /// **'דרושות לפחות 2 משמרות להצגת צמיחה מצטברת'**
  String get analytics_min_shifts_growth;

  /// No description provided for @analytics_min_shifts_retention.
  ///
  /// In he, this message translates to:
  /// **'דרושות לפחות 2 משמרות להצגת מגמת שמירת שכר'**
  String get analytics_min_shifts_retention;

  /// No description provided for @analytics_no_job_data.
  ///
  /// In he, this message translates to:
  /// **'אין נתוני תפקיד'**
  String get analytics_no_job_data;

  /// No description provided for @analytics_hours_suffix_format.
  ///
  /// In he, this message translates to:
  /// **'{hours} שעות'**
  String analytics_hours_suffix_format(Object hours);

  /// No description provided for @analytics_utilization_format.
  ///
  /// In he, this message translates to:
  /// **'{pct}% מסך הניצולת'**
  String analytics_utilization_format(Object pct);

  /// No description provided for @common_previous.
  ///
  /// In he, this message translates to:
  /// **'קודם'**
  String get common_previous;

  /// No description provided for @common_next.
  ///
  /// In he, this message translates to:
  /// **'הבא'**
  String get common_next;

  /// No description provided for @analytics_tips_and_extra.
  ///
  /// In he, this message translates to:
  /// **'טיפים+תוספות'**
  String get analytics_tips_and_extra;

  /// No description provided for @analytics_rate_boost_subtitle.
  ///
  /// In he, this message translates to:
  /// **'+{boost}/ש\' תוספות נטו'**
  String analytics_rate_boost_subtitle(Object boost);

  /// No description provided for @analytics_retention_subtitle.
  ///
  /// In he, this message translates to:
  /// **'נשאר בכיס לאחר הוצאות'**
  String get analytics_retention_subtitle;

  /// No description provided for @analytics_net_extras_pct_subtitle.
  ///
  /// In he, this message translates to:
  /// **'{percent}% מסך השכר נטו'**
  String analytics_net_extras_pct_subtitle(Object percent);

  /// No description provided for @common_unknown_job.
  ///
  /// In he, this message translates to:
  /// **'תפקיד לא ידוע'**
  String get common_unknown_job;

  /// No description provided for @analytics_duration_range_short.
  ///
  /// In he, this message translates to:
  /// **'< 6 שעות'**
  String get analytics_duration_range_short;

  /// No description provided for @analytics_duration_range_standard.
  ///
  /// In he, this message translates to:
  /// **'6–9 שעות'**
  String get analytics_duration_range_standard;

  /// No description provided for @analytics_duration_range_long.
  ///
  /// In he, this message translates to:
  /// **'> 9 שעות'**
  String get analytics_duration_range_long;

  /// No description provided for @profile_title.
  ///
  /// In he, this message translates to:
  /// **'פרופיל משתמש'**
  String get profile_title;

  /// No description provided for @profile_created_at.
  ///
  /// In he, this message translates to:
  /// **'חשבון נוצר בתאריך: [[date]]'**
  String get profile_created_at;

  /// No description provided for @profile_birth_date_display.
  ///
  /// In he, this message translates to:
  /// **'תאריך לידה: [[date]] (גיל: [[age]])'**
  String get profile_birth_date_display;

  /// No description provided for @profile_stats_title.
  ///
  /// In he, this message translates to:
  /// **'סיכום נתונים שנשמרו'**
  String get profile_stats_title;

  /// No description provided for @profile_shifts_count.
  ///
  /// In he, this message translates to:
  /// **'משמרות שנשמרו'**
  String get profile_shifts_count;

  /// No description provided for @profile_jobs_count.
  ///
  /// In he, this message translates to:
  /// **'תפקידים מוגדרים'**
  String get profile_jobs_count;

  /// No description provided for @profile_expenses_count.
  ///
  /// In he, this message translates to:
  /// **'הוצאות שנשמרו'**
  String get profile_expenses_count;

  /// No description provided for @profile_incomes_count.
  ///
  /// In he, this message translates to:
  /// **'הכנסות שנשמרו'**
  String get profile_incomes_count;

  /// No description provided for @side_menu_profile.
  ///
  /// In he, this message translates to:
  /// **'פרופיל משתמש'**
  String get side_menu_profile;

  /// No description provided for @profile_old_password.
  ///
  /// In he, this message translates to:
  /// **'סיסמה נוכחית'**
  String get profile_old_password;

  /// No description provided for @profile_new_password.
  ///
  /// In he, this message translates to:
  /// **'סיסמה חדשה'**
  String get profile_new_password;

  /// No description provided for @profile_password_error.
  ///
  /// In he, this message translates to:
  /// **'הסיסמה הנוכחית שגויה'**
  String get profile_password_error;

  /// No description provided for @profile_password_required.
  ///
  /// In he, this message translates to:
  /// **'נא להזין סיסמה נוכחית'**
  String get profile_password_required;

  /// No description provided for @shift_descriptions_title.
  ///
  /// In he, this message translates to:
  /// **'סיכומי משמרות'**
  String get shift_descriptions_title;

  /// No description provided for @shift_descriptions_empty.
  ///
  /// In he, this message translates to:
  /// **'אין סיכומי משמרות להצגה'**
  String get shift_descriptions_empty;

  /// No description provided for @shift_description_label.
  ///
  /// In he, this message translates to:
  /// **'תיאור / סיכום משמרת'**
  String get shift_description_label;

  /// No description provided for @shift_description_hint.
  ///
  /// In he, this message translates to:
  /// **'הכנס הערות או סיכום למשמרת זו...'**
  String get shift_description_hint;

  /// No description provided for @common_search_by_date.
  ///
  /// In he, this message translates to:
  /// **'חיפוש לפי תאריך'**
  String get common_search_by_date;

  /// No description provided for @common_clear_date_filter.
  ///
  /// In he, this message translates to:
  /// **'נקה סינון תאריך'**
  String get common_clear_date_filter;

  /// No description provided for @common_filter_date.
  ///
  /// In he, this message translates to:
  /// **'סינון לפי תאריך'**
  String get common_filter_date;

  /// No description provided for @profile_delete_account.
  ///
  /// In he, this message translates to:
  /// **'מחיקת חשבון משתמש'**
  String get profile_delete_account;

  /// No description provided for @profile_delete_account_sub.
  ///
  /// In he, this message translates to:
  /// **'מחיקה לצמיתות של חשבון ה-Shiftly שלך'**
  String get profile_delete_account_sub;

  /// No description provided for @profile_delete_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת חשבון'**
  String get profile_delete_dialog_title;

  /// No description provided for @profile_delete_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'האם תרצה למחוק את חשבון המשתמש שלך? פעולה זו אינה ניתנת לביטול.'**
  String get profile_delete_dialog_content;

  /// No description provided for @profile_delete_final_title.
  ///
  /// In he, this message translates to:
  /// **'אישור סופי למחיקה'**
  String get profile_delete_final_title;

  /// No description provided for @profile_delete_final_content_1.
  ///
  /// In he, this message translates to:
  /// **'חשבון המשתמש וכל נתוני השרת יימחקו לצמיתות.'**
  String get profile_delete_final_content_1;

  /// No description provided for @profile_delete_final_content_2.
  ///
  /// In he, this message translates to:
  /// **'פעולה זו בלתי הפיכה. האם למחוק את החשבון?'**
  String get profile_delete_final_content_2;

  /// No description provided for @profile_delete_success.
  ///
  /// In he, this message translates to:
  /// **'החשבון נמחק בהצלחה'**
  String get profile_delete_success;

  /// No description provided for @settings_byos_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת גיבוי BYOS'**
  String get settings_byos_delete_title;

  /// No description provided for @settings_byos_delete_sub.
  ///
  /// In he, this message translates to:
  /// **'מחיקת קובץ הגיבוי מ-Google Drive לצמיתות'**
  String get settings_byos_delete_sub;

  /// No description provided for @settings_byos_delete_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת נתוני BYOS'**
  String get settings_byos_delete_dialog_title;

  /// No description provided for @settings_byos_delete_dialog_content.
  ///
  /// In he, this message translates to:
  /// **'האם תרצה למחוק את נתוני הגיבוי מ-Google Drive?'**
  String get settings_byos_delete_dialog_content;

  /// No description provided for @settings_byos_delete_final_title.
  ///
  /// In he, this message translates to:
  /// **'אזהרה סופית'**
  String get settings_byos_delete_final_title;

  /// No description provided for @settings_byos_delete_final_content_1.
  ///
  /// In he, this message translates to:
  /// **'קובץ הגיבוי שלך ב-Google Drive יימחק כליל.'**
  String get settings_byos_delete_final_content_1;

  /// No description provided for @settings_byos_delete_final_content_2.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את הגיבוי לצמיתות?'**
  String get settings_byos_delete_final_content_2;

  /// No description provided for @settings_byos_delete_success.
  ///
  /// In he, this message translates to:
  /// **'נתוני הגיבוי של BYOS נמחקו בהצלחה'**
  String get settings_byos_delete_success;

  /// No description provided for @add_shift_wage_segments_title.
  ///
  /// In he, this message translates to:
  /// **'אחוזי שכר לפי שעות (אופציונלי)'**
  String get add_shift_wage_segments_title;

  /// No description provided for @add_shift_wage_segments_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הגדר תקופות עם אחוזי שכר שונים (למשל 150%)'**
  String get add_shift_wage_segments_subtitle;

  /// No description provided for @add_shift_wage_segments_add.
  ///
  /// In he, this message translates to:
  /// **'הוסף תקופה'**
  String get add_shift_wage_segments_add;

  /// No description provided for @add_shift_wage_segment_start.
  ///
  /// In he, this message translates to:
  /// **'התחלה'**
  String get add_shift_wage_segment_start;

  /// No description provided for @add_shift_wage_segment_end.
  ///
  /// In he, this message translates to:
  /// **'סיום'**
  String get add_shift_wage_segment_end;

  /// No description provided for @add_shift_wage_segment_percentage.
  ///
  /// In he, this message translates to:
  /// **'שכר %'**
  String get add_shift_wage_segment_percentage;

  /// No description provided for @error_segment_invalid_time.
  ///
  /// In he, this message translates to:
  /// **'שעת הסיום בטווח השכר חייבת להיות אחרי שעת ההתחלה'**
  String get error_segment_invalid_time;

  /// No description provided for @error_segment_overlap.
  ///
  /// In he, this message translates to:
  /// **'קיימת חפיפה בטווחי השעות'**
  String get error_segment_overlap;

  /// No description provided for @legal_privacy_policy.
  ///
  /// In he, this message translates to:
  /// **'מדיניות פרטיות'**
  String get legal_privacy_policy;

  /// No description provided for @legal_terms_of_service.
  ///
  /// In he, this message translates to:
  /// **'תנאי שימוש'**
  String get legal_terms_of_service;

  /// No description provided for @legal_disclaimer_notice.
  ///
  /// In he, this message translates to:
  /// **'בהרשמה או התחברות, הנך מסכים לתנאי השימוש ומדיניות הפרטיות שלנו.'**
  String get legal_disclaimer_notice;

  /// No description provided for @legal_payroll_disclaimer.
  ///
  /// In he, this message translates to:
  /// **'החישובים הינם הערכות מתמטיות למעקב אישי בלבד ואינם מהווים ייעוץ מס, שכר או ייעוץ משפטי רשמי.'**
  String get legal_payroll_disclaimer;

  /// No description provided for @legal_cookie_title.
  ///
  /// In he, this message translates to:
  /// **'הגדרות עוגיות ופרטיות'**
  String get legal_cookie_title;

  /// No description provided for @legal_cookie_description.
  ///
  /// In he, this message translates to:
  /// **'אנו משתמשים בטכנולוגיות אחסון מקומיות (עוגיות) לאבטחה, התחברות ודיווחי שגיאות. באפשרותך לאשר את הכל או להשתמש בעוגיות נחוצות בלבד.'**
  String get legal_cookie_description;

  /// No description provided for @legal_cookie_accept_all.
  ///
  /// In he, this message translates to:
  /// **'אישור הכל'**
  String get legal_cookie_accept_all;

  /// No description provided for @legal_cookie_necessary_only.
  ///
  /// In he, this message translates to:
  /// **'נחוצים בלבד'**
  String get legal_cookie_necessary_only;

  /// No description provided for @legal_cookie_necessary_desc.
  ///
  /// In he, this message translates to:
  /// **'חיוני להתחברות, אחסון מאובטח והגדרות אפליקציה.'**
  String get legal_cookie_necessary_desc;

  /// No description provided for @legal_cookie_analytics_desc.
  ///
  /// In he, this message translates to:
  /// **'יומני שגיאות ודיווחי קריסות אנונימיים דרך Firebase.'**
  String get legal_cookie_analytics_desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
