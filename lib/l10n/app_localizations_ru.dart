// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_back => 'Назад';

  @override
  String get common_start => 'Начать!';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_confirm => 'Подтвердить';

  @override
  String get common_error => 'Ошибка';

  @override
  String get common_success => 'Успешно';

  @override
  String get common_edit => 'Изменить';

  @override
  String get common_tagline => 'СИСТЕМА УЧЕТА СМЕН И ЗАРПЛАТЫ';

  @override
  String get nav_calendar => 'Календарь';

  @override
  String get nav_analytics => 'Аналитика';

  @override
  String get nav_home => 'Главная';

  @override
  String get nav_expenses => 'Расходы';

  @override
  String get nav_summaries => 'Сводки';

  @override
  String get common_hours_suffix => 'ч.';

  @override
  String get common_min_suffix => 'мин.';

  @override
  String get common_net => 'Чистыми';

  @override
  String get common_shifts_count => 'Смены';

  @override
  String get common_save_and_finish => 'Сохранить и завершить';

  @override
  String get common_reset => 'Сбросить';

  @override
  String get common_reset_and_cancel => 'Отмена и сброс';

  @override
  String get onboarding_welcome_title => 'Добро пожаловать в Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'Приложение, которое помогает легко и точно отслеживать смены, зарплату и чаевые.';

  @override
  String get onboarding_welcome_description =>
      'Давайте настроим основные параметры для начала работы.';

  @override
  String onboarding_step_progress(Object current, Object total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboarding_skip_setup => 'Пропустить настройку';

  @override
  String get onboarding_language_title => 'Язык приложения';

  @override
  String get onboarding_language_subtitle => 'Выберите предпочитаемый язык.';

  @override
  String get onboarding_currency_title => 'Выберите валюту';

  @override
  String get onboarding_currency_subtitle =>
      'Какую валюту вы хотите использовать для зарплаты и расходов?';

  @override
  String get monthly_progress_setting_title => 'Значение линии прогресса';

  @override
  String get monthly_progress_mode_month => 'Прошедшее время месяца';

  @override
  String get monthly_progress_mode_financial_goal =>
      'Прогресс достижения финансовой цели';

  @override
  String get monthly_progress_goal_amount => 'Сумма ежемесячной цели';

  @override
  String get monthly_progress_invalid_goal =>
      'Введите финансовую цель больше нуля';

  @override
  String get monthly_progress_month_elapsed => 'Прогресс месяца';

  @override
  String get monthly_progress_financial_goal => 'Прогресс цели';

  @override
  String get onboarding_breaks_title => 'Настройки перерывов';

  @override
  String get onboarding_breaks_subtitle => 'Сколько обычно длится перерыв?';

  @override
  String get onboarding_breaks_enable => 'Включить перерывы';

  @override
  String get onboarding_breaks_paid_label => 'Оплачиваемый перерыв (минуты)';

  @override
  String get onboarding_breaks_unpaid_label =>
      'Неоплачиваемый перерыв (минуты)';

  @override
  String get onboarding_auto_expenses_title => 'Повторяющиеся расходы';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'Есть ли у вас повторяющиеся расходы в каждой смене? (например, проезд)';

  @override
  String get onboarding_auto_expenses_enable => 'Включить авторасходы';

  @override
  String get onboarding_auto_expenses_add_button => 'Добавить расход';

  @override
  String get onboarding_auto_expenses_desc_label => 'Описание';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'Сумма должна быть больше 0';

  @override
  String get onboarding_auto_incomes_title => 'Повторяющиеся доходы';

  @override
  String get onboarding_auto_incomes_subtitle =>
      'Есть ли у вас повторяющиеся доходы в каждой смене? (например, компенсация проезда)';

  @override
  String get onboarding_auto_incomes_enable => 'Включить автодоходы';

  @override
  String get onboarding_auto_incomes_add_button => 'Добавить доход';

  @override
  String get onboarding_job_types_title => 'Смены и ставки';

  @override
  String get onboarding_job_types_subtitle =>
      'Укажите ваши роли и почасовые ставки.';

  @override
  String get onboarding_job_types_add_button => 'Добавить тип смены';

  @override
  String get onboarding_job_types_edit_button => 'Изменить тип смены';

  @override
  String get onboarding_job_types_delete_title => 'Удалить должность';

  @override
  String get onboarding_job_types_delete_desc => 'Удалить должность ';

  @override
  String get onboarding_job_types_rate_suffix => 'в час';

  @override
  String get onboarding_job_types_same =>
      'Должность с таким названием уже существует';

  @override
  String get default_job_buffet => 'Буфет';

  @override
  String get default_job_steward => 'Стюарт';

  @override
  String get default_job_unloading => 'Разгрузка';

  @override
  String get default_expenses_trips => 'Проезд';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_section_app => 'Приложение';

  @override
  String get settings_section_work_pay => 'Работа и оплата';

  @override
  String get settings_section_breaks => 'Длительность перерывов (мин.)';

  @override
  String get settings_section_danger => 'Опасная зона';

  @override
  String get settings_field_theme => 'Тема';

  @override
  String get settings_field_language => 'Язык приложения';

  @override
  String get settings_field_currency => 'Валюта отображения';

  @override
  String get settings_field_currency_sub =>
      'Валюта, используемая для зарплаты и расходов';

  @override
  String get settings_field_breaks_enabled => 'Включить перерывы';

  @override
  String get settings_field_breaks_enabled_sub =>
      'Показывать или скрывать настройки перерывов в приложении';

  @override
  String get settings_field_paid_break => 'Короткий перерыв (Оплачиваемый)';

  @override
  String get settings_field_unpaid_break => 'Длинный перерыв (Неоплачиваемый)';

  @override
  String get settings_action_update_breaks => 'Обновить время';

  @override
  String get settings_action_factory_reset => 'Полный сброс настроек';

  @override
  String get settings_action_factory_reset_sub =>
      'Безвозвратно удалить все смены, роли и расходы';

  @override
  String get settings_dialog_update_breaks_title => 'Обновить время перерывов';

  @override
  String get settings_dialog_factory_reset_title => 'Сбросить данные?';

  @override
  String get settings_dialog_factory_reset_content =>
      'Вы уверены, что хотите удалить все рабочие данные и сбросить приложение? Это действие необратимо.';

  @override
  String get settings_dialog_final_confirm_title =>
      'Окончательное подтверждение';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'Внимание: вся история смен, зарплата и расходы будут безвозвратно удалены.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'Вы действительно хотите всё удалить?';

  @override
  String get settings_dialog_final_confirm_button => 'Безвозвратно удалить всё';

  @override
  String get settings_dialog_error_enter_desc =>
      'Пожалуйста, введите описание для каждого расхода';

  @override
  String get settings_dialog_error_enter_income_desc =>
      'Пожалуйста, введите описание для каждого дохода';

  @override
  String get settings_theme_system => 'Системная';

  @override
  String get settings_theme_light => 'Светлая';

  @override
  String get settings_theme_dark => 'Темная';

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
  String get settings_current_rate => 'Текущая ставка';

  @override
  String get settings_wage_history_title => 'История ставок';

  @override
  String get settings_job_name_label => 'Название должности';

  @override
  String get settings_job_rate_label => 'Почасовая ставка (Новая)';

  @override
  String get home_empty_state_title => 'Смены еще не зарегистрированы';

  @override
  String get home_empty_state_subtitle => 'Нажмите «Новая смена», чтобы начать';

  @override
  String get home_total_card_title =>
      'Всего накоплено (Чистыми за вычетом расходов)';

  @override
  String get home_total_card_hours => 'Часы';

  @override
  String get home_total_card_base => 'База';

  @override
  String get home_total_card_tips => 'Чаевые';

  @override
  String get home_total_card_expenses => 'Расходы';

  @override
  String get home_active_timer_break => 'Смена на перерыве...';

  @override
  String get home_active_timer_active => 'Активная смена:';

  @override
  String get home_active_timer_time => 'Время:';

  @override
  String get home_shift_list_net_total => 'Итого чистыми';

  @override
  String get home_shift_list_no_shifts => 'В этот день смен нет';

  @override
  String get home_shift_list_no_shifts_month => 'В этом месяце смен нет';

  @override
  String get shift_history_empty_title => 'Смены не найдены';

  @override
  String get shift_history_empty_subtitle => 'История смен недоступна';

  @override
  String get home_shift_list_select_day => 'Выберите день для просмотра смен';

  @override
  String get home_shift_list_shifts_on => 'Смены за';

  @override
  String get home_action_new_shift => 'Новая смена';

  @override
  String get home_action_calendar => 'Календарь';

  @override
  String get calendar_legend_today => 'Сегодня';

  @override
  String get calendar_legend_selected => 'Выбрано';

  @override
  String get calendar_legend_shift => 'Смена';

  @override
  String get calendar_legend_holiday => 'Праздник / Шаббат';

  @override
  String get calendar_legend_holiday_shift => 'Праздничная смена';

  @override
  String get expenses_title => 'Расходы и доходы';

  @override
  String get expenses_tab_expenses => 'Расходы';

  @override
  String get expenses_tab_incomes => 'Особые доходы';

  @override
  String get expenses_auto_section_title => 'Повторяющиеся расходы смены';

  @override
  String get expenses_auto_section_subtitle =>
      'Добавлять повторяющиеся расходы к каждой новой смене';

  @override
  String get expenses_auto_section_enable => 'Авторасходы';

  @override
  String get expenses_history_section_title => 'Ежемесячная разбивка расходов';

  @override
  String get expenses_action_add_auto => 'Добавить повторяющийся расход';

  @override
  String get expenses_action_update_settings => 'Обновить настройки';

  @override
  String get expenses_action_new_expense => 'Новый расход';

  @override
  String get expenses_dialog_add_title => 'Добавить расход';

  @override
  String get expenses_dialog_edit_title => 'Изменить расход';

  @override
  String get expenses_dialog_delete_title => 'Удалить расход';

  @override
  String get expenses_no_history => 'Расходы не записаны';

  @override
  String get expenses_delete_expense_confirm_content =>
      'Удалить «[[desc]]» на сумму [[amount]]?';

  @override
  String get expenses_total_label => 'Итого';

  @override
  String get expenses_auto_updated_msg => 'Настройки авторасходов обновлены';

  @override
  String get expenses_deleted_msg => 'Расход удален';

  @override
  String get expenses_link_shift_dialog_title => 'Связать со сменой';

  @override
  String get expenses_link_shift_dialog_content =>
      'На эту дату найдена смена. Хотите связать этот [[type]] со сменой или сохранить как отдельный?';

  @override
  String get expenses_link_shift_button => 'Связать со сменой';

  @override
  String get expenses_save_standalone_button => 'Сохранить отдельно';

  @override
  String get expenses_no_shift_dialog_title => 'Смена не найдена';

  @override
  String get expenses_no_shift_dialog_content =>
      'На эту дату нет смены. Вы все равно хотите создать этот [[type]]?';

  @override
  String get expenses_create_anyway_button => 'Все равно создать';

  @override
  String get expenses_auto_incomes_updated_msg =>
      'Настройки автодоходов обновлены';

  @override
  String get expenses_auto_incomes_section_title =>
      'Повторяющиеся доходы смены';

  @override
  String get expenses_auto_incomes_section_subtitle =>
      'Добавлять повторяющиеся доходы к каждой новой смене';

  @override
  String get expenses_auto_incomes_section_enable => 'Автодоходы';

  @override
  String get incomes_history_section_title => 'Ежемесячная разбивка доходов';

  @override
  String get incomes_action_new_income => 'Новый доход';

  @override
  String get incomes_dialog_add_title => 'Добавить особый доход';

  @override
  String get incomes_dialog_edit_title => 'Изменить доход';

  @override
  String get incomes_dialog_delete_title => 'Удалить доход';

  @override
  String get incomes_no_history => 'Особые доходы не записаны';

  @override
  String get incomes_delete_income_confirm_content =>
      'Удалить «[[desc]]» на сумму [[amount]]?';

  @override
  String get incomes_deleted_msg => 'Доход удален';

  @override
  String get add_shift_title => 'Новая смена';

  @override
  String get add_shift_edit_title => 'Изменить смену';

  @override
  String get add_shift_timer_tab => 'Таймер';

  @override
  String get add_shift_manual_tab => 'Вручную';

  @override
  String get add_shift_paste_tab => 'Вставить';

  @override
  String get add_shift_timer_accumulated_live => 'Накоплено в реальном времени';

  @override
  String get add_shift_timer_countdown => 'Обратный отсчет: ';

  @override
  String get add_shift_timer_break_paid => 'На оплачиваемом перерыве...';

  @override
  String get add_shift_timer_break_unpaid =>
      'На неоплачиваемом перерыве (таймер остановлен)';

  @override
  String get add_shift_timer_total_break_unpaid =>
      'Всего неоплачиваемых перерывов:';

  @override
  String get add_shift_timer_resume_work => 'Вернуться к работе';

  @override
  String get add_shift_timer_stop_shift => 'Завершить смену';

  @override
  String get add_shift_timer_start_shift => 'Начать смену';

  @override
  String get add_shift_timer_continue_work => 'Продолжить работу';

  @override
  String get add_shift_timer_stopped_msg =>
      'Таймер остановлен. Хотите сохранить смену или продолжить работу?';

  @override
  String get add_shift_timer_reset_title => 'Сбросить таймер';

  @override
  String get add_shift_timer_reset_desc =>
      'Вы уверены, что хотите сбросить таймер? Все текущие данные будут потеряны.';

  @override
  String get add_shift_manual_time_section => 'Время';

  @override
  String get add_shift_manual_date_label => 'Дата';

  @override
  String get add_shift_manual_start_time_label => 'Время начала';

  @override
  String get add_shift_manual_end_time_label => 'Время окончания';

  @override
  String get add_shift_manual_break_type_section => 'Тип перерыва';

  @override
  String get add_shift_manual_no_break => 'Нет';

  @override
  String get add_shift_manual_paid_break => 'Оплачиваемый';

  @override
  String get add_shift_manual_unpaid_break => 'Неоплачиваемый';

  @override
  String get add_shift_manual_work_tips_section => 'Работа и чаевые';

  @override
  String get add_shift_manual_job_type_label => 'Должность';

  @override
  String get add_shift_paste_title => 'Вставить текст смены';

  @override
  String get add_shift_paste_default_job_label => 'Должность по умолчанию';

  @override
  String get add_shift_paste_format_info =>
      'Формат: ДД.ММ (или ДД.ММ.ГГГГ) - ЧЧ:мм - ЧЧ:мм [перерыв] [+ чаевые]\n(Если год не указан, берется текущий год)';

  @override
  String get add_shift_paste_hint =>
      'Вставьте смены сюда...\nПример:\n24.6.2026 - 17:30 - 23:00 45 минут + 50';

  @override
  String get add_shift_paste_parse_button => 'Разобрать и сохранить всё';

  @override
  String get add_shift_paste_parse_dialog_title => 'Разбор смен';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'Разобрать и сохранить смены из вставленного текста?';

  @override
  String get add_shift_paste_error =>
      'Пожалуйста, проверьте формат и попробуйте снова';

  @override
  String get add_shift_tips_title => 'Чаевые';

  @override
  String get add_shift_tips_total => 'Итого';

  @override
  String get add_shift_tips_hint => 'Сумма чаевых';

  @override
  String get add_shift_tips_add_button => 'Добавить чаевые';

  @override
  String get add_shift_expenses_title => 'Расходы смены';

  @override
  String get add_shift_expenses_total => 'Итого';

  @override
  String get add_shift_expenses_add_button => 'Добавить расход';

  @override
  String get add_shift_incomes_title => 'Доходы смены';

  @override
  String get add_shift_incomes_total => 'Итого';

  @override
  String get add_shift_incomes_add_button => 'Добавить доход';

  @override
  String get add_shift_shift_ended_dialog_title => 'Сохранить смену';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'Вы уверены, что хотите сохранить данные смены?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'Вы уверены, что хотите сохранить данные смены?';

  @override
  String get add_shift_shift_edit_dialog_title => 'Обновить смену';

  @override
  String get add_shift_shift_saved => 'Смена успешно сохранена';

  @override
  String get add_shift_preview_title => 'Предпросмотр';

  @override
  String add_shift_segments_count(int count) {
    return '$count периодов';
  }

  @override
  String get add_shift_overlap_title => 'Пересечение смен';

  @override
  String add_shift_overlap_content(num count, String details) {
    return 'Эта смена пересекается с $count существующими сменами:\n\n$details\n\nВсе равно сохранить?';
  }

  @override
  String get add_shift_overlap_confirm => 'Все равно сохранить';

  @override
  String get add_shift_overlap_unknown_job => 'Неизвестная должность';

  @override
  String get add_shift_pick_a_job =>
      'Пожалуйста, сначала выберите тип должности';

  @override
  String get add_shift_delete_title => 'Удалить смену';

  @override
  String get add_shift_delete_desc => 'Вы уверены, что хотите удалить смену от';

  @override
  String get add_shift_delete_msg => 'Смена успешно удалена';

  @override
  String get notification_timer_channel_name => 'Активная смена';

  @override
  String get notification_timer_channel_desc =>
      'Отображает таймер текущей смены';

  @override
  String get notification_timer_title_active => 'Активная смена';

  @override
  String get notification_timer_title_paid_break => 'Оплачиваемый перерыв';

  @override
  String get notification_timer_title_unpaid_break => 'Неоплачиваемый перерыв';

  @override
  String get notification_timer_body_running => 'Таймер запущен...';

  @override
  String get notification_timer_body_countdown => 'Обратный отсчет: [[time]]';

  @override
  String get filter_title => 'Фильтры смен';

  @override
  String get filter_clear_all => 'Сбросить фильтр';

  @override
  String get filter_apply => 'Применить фильтры';

  @override
  String get filter_wage_range => 'Диапазон общей зарплаты';

  @override
  String get filter_tips_range => 'Диапазон чаевых';

  @override
  String get filter_expenses_range => 'Диапазон расходов';

  @override
  String get filter_duration_range => 'Диапазон длительности (часы)';

  @override
  String get filter_date_range => 'Диапазон дат';

  @override
  String get filter_job_type => 'Должность';

  @override
  String get filter_select_all => 'Выбрать все';

  @override
  String get filter_error_no_job_selected =>
      'Пожалуйста, выберите хотя бы один тип должности';

  @override
  String get filter_active_filters => 'Активные фильтры:';

  @override
  String get filter_chip_wage => 'Зарплата: [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'Чаевые: [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'Расходы: [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'Длительность: [[min]] - [[max]] ч.';

  @override
  String get filter_chip_date => 'Дата: [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'Должность: [[name]]';

  @override
  String get filter_empty_state_title => 'Нет подходящих смен';

  @override
  String get filter_empty_state_subtitle =>
      'Попробуйте изменить фильтры, чтобы увидеть больше результатов';

  @override
  String get auth_login_title => 'С возвращением';

  @override
  String get auth_register_title => 'Создать новый аккаунт';

  @override
  String get auth_full_name_label => 'ФИО';

  @override
  String get auth_email_label => 'Эл. почта';

  @override
  String get auth_password_label => 'Пароль';

  @override
  String get auth_error_name_empty => 'Пожалуйста, введите имя';

  @override
  String get auth_error_email_invalid => 'Неверный адрес эл. почты';

  @override
  String get auth_error_password_length =>
      'Пароль должен содержать не менее 6 символов';

  @override
  String get auth_login_button => 'Войти';

  @override
  String get auth_register_button => 'Зарегистрироваться';

  @override
  String get auth_no_account_link => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get auth_has_account_link => 'Уже есть аккаунт? Войти';

  @override
  String get auth_error_generic =>
      'Произошла ошибка. Пожалуйста, попробуйте снова.';

  @override
  String get settings_logout_title => 'Выйти из системы';

  @override
  String get settings_logout_dialog_title => 'Выход';

  @override
  String get settings_logout_confirm_content => 'Вы уверены, что хотите выйти?';

  @override
  String get settings_logout_confirm_button => 'Выйти';

  @override
  String get auth_login_success => 'Успешный вход';

  @override
  String get auth_register_success => 'Аккаунт успешно создан';

  @override
  String get auth_birth_date_label => 'Дата рождения';

  @override
  String get auth_error_underage => 'Пользователь должен быть не младше 12 лет';

  @override
  String get auth_error_birth_date_empty =>
      'Пожалуйста, выберите дату рождения';

  @override
  String get auth_error_email_exists => 'Этот адрес эл. почты уже занят';

  @override
  String get auth_error_user_not_found =>
      'Пользователь не найден или неверный пароль';

  @override
  String get auth_error_network =>
      'Ошибка подключения к сети. Проверьте интернет-соединение и попробуйте снова.';

  @override
  String get auth_continue_as_guest => 'Продолжить как гость';

  @override
  String get auth_replace_guest_data_title => 'Заменить гостевые данные?';

  @override
  String get auth_replace_guest_data_message =>
      'Вход в существующий аккаунт заменит данные, хранящиеся на этом устройстве, на данные вашего аккаунта. Ваши гостевые данные могут быть безвозвратно утеряны, если у вас нет резервной копии. Убедитесь, что вы понимаете последствия, прежде чем продолжить.';

  @override
  String get auth_replace_guest_data_confirm => 'Продолжить';

  @override
  String get auth_replace_guest_data_cancel => 'Отмена';

  @override
  String get auth_guest_mode_title => 'Гостевой режим';

  @override
  String get auth_guest_mode_subtitle =>
      'Вы используете Shiftly в гостевом режиме. Ваши данные сохраняются локально на этом устройстве. Создайте аккаунт для синхронизации между устройствами или войдите в существующий.';

  @override
  String get auth_guest_migration_failed =>
      'Не удалось получить данные аккаунта. Ваши гостевые данные сохранены.';

  @override
  String get auth_register_guest_transfer =>
      'Войти или создать аккаунт Shiftly';

  @override
  String get auth_user_deleted_local_data_preserved =>
      'Ваш аккаунт больше не существует в базе данных. Вы вышли из системы, но ваши локальные данные сохранены на этом устройстве.';

  @override
  String get home_welcome_back => 'Здравствуйте, [[name]]';

  @override
  String get settings_user_name => 'Имя';

  @override
  String get settings_user_email => 'Эл. почта';

  @override
  String get settings_user_password => 'Пароль';

  @override
  String get settings_user_edit_title => 'Редактировать профиль';

  @override
  String get settings_user_update_success => 'Профиль успешно обновлен';

  @override
  String get settings_logout_success => 'Успешный выход из системы';

  @override
  String get settings_byos_title => 'Синхронизация BYOS';

  @override
  String get settings_byos_connected => 'Подключено к Google Диску';

  @override
  String get settings_byos_last_backup => 'Последняя резервная копия: [[time]]';

  @override
  String get settings_byos_backup_now => 'Создать резервную копию';

  @override
  String get settings_byos_auto_sync => 'Автосинхронизация';

  @override
  String get settings_byos_auto_sync_sub =>
      'Мгновенное резервное копирование изменений в облако';

  @override
  String get settings_byos_disconnect => 'Отключить';

  @override
  String get settings_byos_login_shiftly => 'Войти в аккаунт Shiftly';

  @override
  String get settings_byos_login_shiftly_sub =>
      'Полная синхронизация в нашем облаке';

  @override
  String get settings_byos_method_title => 'Метод BYOS (Google Диск)';

  @override
  String get settings_byos_method_sub =>
      'Резервное копирование в ваше личное облако';

  @override
  String get settings_byos_restore_dialog_title => 'Синхронизация BYOS';

  @override
  String get settings_byos_restore_dialog_content =>
      'Хотите восстановить существующие данные с Google Диска?';

  @override
  String get settings_byos_restore_confirm => 'Восстановить';

  @override
  String get settings_byos_restore_cancel => 'Не сейчас';

  @override
  String get settings_byos_login_hint =>
      'Войдите, чтобы сохранять данные в облаке и использовать другие устройства';

  @override
  String get settings_restore_success =>
      'Успешное восстановление: восстановлено смен: [[shifts]], должностей: [[jobs]].';

  @override
  String get settings_restore_no_data =>
      'На Google Диске не найдено резервных копий или произошла ошибка.';

  @override
  String get export_title => 'Экспорт смен';

  @override
  String get export_format_label => 'Формат файла';

  @override
  String get export_format_csv => 'CSV (совместимо с Excel)';

  @override
  String get export_format_txt => 'Текстовый файл (TXT)';

  @override
  String get export_format_json => 'Резервная копия JSON (.json)';

  @override
  String get export_range_label => 'Диапазон экспорта';

  @override
  String get export_range_all => 'Все смены';

  @override
  String get export_range_month => 'Конкретный месяц';

  @override
  String get export_range_custom => 'Произвольный диапазон дат';

  @override
  String get export_start_date => 'Дата начала';

  @override
  String get export_end_date => 'Дата окончания';

  @override
  String get export_select_month => 'Выберите месяц';

  @override
  String get export_button => 'Экспортировать файл';

  @override
  String get export_success_msg => 'Файл успешно экспортирован и сохранен в:';

  @override
  String get export_empty_error =>
      'В выбранном диапазоне не найдено смен для экспорта';

  @override
  String get analytics_title => 'Аналитика и инсайты';

  @override
  String get analytics_hero_greeting => 'Финансовый снимок';

  @override
  String get analytics_hero_subtitle =>
      'Ваши финансовые показатели и рабочий график с первого взгляда';

  @override
  String get analytics_section_overview => 'Обзор';

  @override
  String get analytics_section_earnings => 'Заработок';

  @override
  String get analytics_section_work_patterns => 'Рабочий график';

  @override
  String get analytics_section_pay_breakdown => 'Структура зарплаты';

  @override
  String get analytics_period_monthly => 'За месяц';

  @override
  String get analytics_period_yearly => 'За год';

  @override
  String get analytics_period_all_time => 'За все время';

  @override
  String get analytics_all_jobs => 'Все должности';

  @override
  String get analytics_stat_total_net => 'Всего чистыми';

  @override
  String get analytics_stat_total_hours => 'Всего часов';

  @override
  String get analytics_stat_avg_rate => 'Ср. эффективная ставка';

  @override
  String get analytics_stat_tips => 'Чистые расходы по сменам';

  @override
  String get analytics_chart_earnings_title => 'Заработок и расходы во времени';

  @override
  String get analytics_chart_earnings_subtitle =>
      'Нажмите на столбец, чтобы увидеть детализацию оплаты и расходов';

  @override
  String get analytics_chart_jobs_title => 'Разбивка по должностям';

  @override
  String get analytics_chart_jobs_by_earnings => 'По заработку';

  @override
  String get analytics_chart_jobs_by_hours => 'По часам';

  @override
  String get analytics_no_data => 'Нет данных за выбранный период';

  @override
  String get analytics_selected_breakdown => 'Детали выбранного дня';

  @override
  String get analytics_selected_month_breakdown => 'Детали выбранного месяца';

  @override
  String get analytics_base_salary => 'Базовый оклад';

  @override
  String get analytics_chart_cumulative_title => 'Кумулятивный рост заработка';

  @override
  String get analytics_chart_cumulative_subtitle =>
      'Прокрутите горизонтально, чтобы посмотреть рост оплаты во времени';

  @override
  String get analytics_gross_pay => 'Грязными';

  @override
  String get analytics_net_pay => 'Чистыми';

  @override
  String get analytics_kpi_projected => 'Прогнозируемая зарплата за месяц';

  @override
  String get analytics_kpi_retention => 'Коэффициент сохранения чистой суммы';

  @override
  String get analytics_chart_tod_title => 'Разбивка по времени суток';

  @override
  String get analytics_chart_tod_subtitle =>
      'Сравнение часов по сегментам суток';

  @override
  String get analytics_chart_tod_dawn => 'Рассвет';

  @override
  String get analytics_chart_tod_morning => 'Утро';

  @override
  String get analytics_chart_tod_noon => 'День';

  @override
  String get analytics_chart_tod_afternoon => 'После полудня';

  @override
  String get analytics_chart_tod_evening => 'Вечер';

  @override
  String get analytics_chart_tod_night => 'Ночь';

  @override
  String get analytics_chart_duration_title =>
      'Разбивка по длительности смен и усталости';

  @override
  String get analytics_chart_duration_subtitle =>
      'Распределение длительности смен (короткие, стандартные, длинные)';

  @override
  String get analytics_duration_short => 'Короткие';

  @override
  String get analytics_duration_standard => 'Стандартные';

  @override
  String get analytics_duration_long => 'Длинные';

  @override
  String get analytics_insights_title => 'Ключевые умные инсайты';

  @override
  String get analytics_insight_night_boost =>
      'Вечерние и ночные смены составляют [[percent]]% от вашего рабочего времени.';

  @override
  String get analytics_insight_retention =>
      'Вы сохраняете [[percent]]% валового заработка после расходов на смены.';

  @override
  String get analytics_insight_fatigue =>
      '[[percent]]% ваших смен длились дольше 9 часов.';

  @override
  String get analytics_insight_tips_ratio =>
      'Повторяющиеся расходы составляют [[percent]]% от вашего общего заработка.';

  @override
  String analytics_shifts_format(Object count) {
    return '$count смен';
  }

  @override
  String get analytics_no_shift_data_period =>
      'Нет данных о сменах за этот период';

  @override
  String get analytics_min_shifts_hourly =>
      'Требуется не менее 2 смен для отображения тенденции почасовой ставки';

  @override
  String get analytics_min_shifts_growth =>
      'Требуется не менее 2 смен для отображения кумулятивного роста';

  @override
  String get analytics_min_shifts_retention =>
      'Требуется не менее 2 смен для отображения тенденции сохранения чистой суммы';

  @override
  String get analytics_no_job_data => 'Нет данных о должностях';

  @override
  String analytics_hours_suffix_format(Object hours) {
    return '$hours ч.';
  }

  @override
  String analytics_utilization_format(Object pct) {
    return 'Использование: $pct%';
  }

  @override
  String get common_previous => 'Предыдущий';

  @override
  String get common_next => 'Следующий';

  @override
  String get analytics_tips_and_extra => 'Чаевые и доплаты';

  @override
  String analytics_rate_boost_subtitle(Object boost) {
    return '+$boost/ч чистых доплат';
  }

  @override
  String get analytics_retention_subtitle =>
      'Сохранено после расходов на смены';

  @override
  String analytics_net_extras_pct_subtitle(Object percent) {
    return '$percent% от общей зарплаты чистыми';
  }

  @override
  String get common_unknown_job => 'Неизвестная должность';

  @override
  String get analytics_duration_range_short => '< 6 часов';

  @override
  String get analytics_duration_range_standard => '6-9 часов';

  @override
  String get analytics_duration_range_long => '> 9 часов';

  @override
  String get profile_title => 'Профиль пользователя';

  @override
  String get profile_created_at => 'Аккаунт создан: [[date]]';

  @override
  String get profile_birth_date_display =>
      'Дата рождения: [[date]] (Возраст: [[age]])';

  @override
  String get profile_stats_title => 'Сводка сохраненных данных';

  @override
  String get profile_shifts_count => 'Сохранено смен';

  @override
  String get profile_jobs_count => 'Роли / Типы должностей';

  @override
  String get profile_expenses_count => 'Сохранено расходов';

  @override
  String get profile_incomes_count => 'Сохранено доходов';

  @override
  String get side_menu_profile => 'Профиль пользователя';

  @override
  String get profile_old_password => 'Текущий пароль';

  @override
  String get profile_new_password => 'Новый пароль';

  @override
  String get profile_password_error => 'Текущий пароль указан неверно';

  @override
  String get profile_password_required => 'Пожалуйста, введите текущий пароль';

  @override
  String get shift_descriptions_title => 'Сводки смен';

  @override
  String get shift_descriptions_empty => 'Сводки смен не найдены';

  @override
  String get shift_description_label => 'Сводка / Описание смены';

  @override
  String get shift_description_hint =>
      'Введите заметки или сводку для этой смены...';

  @override
  String get shift_descriptions_delete_title => 'Удалить описание';

  @override
  String get shift_descriptions_delete_content =>
      'Вы уверены, что хотите удалить описание для этой смены?';

  @override
  String get shift_descriptions_deleted_msg => 'Описание успешно удалено';

  @override
  String get shift_descriptions_edit_title => 'Изменить описание';

  @override
  String get shift_descriptions_updated_msg => 'Описание успешно обновлено';

  @override
  String get common_search_by_date => 'Поиск по дате';

  @override
  String get common_clear_date_filter => 'Сбросить фильтр по дате';

  @override
  String get common_filter_date => 'Фильтр по дате';

  @override
  String get profile_delete_account => 'Удалить аккаунт';

  @override
  String get profile_delete_account_sub =>
      'Безвозвратно удалить ваш аккаунт Shiftly';

  @override
  String get profile_delete_dialog_title => 'Удалить аккаунт';

  @override
  String get profile_delete_dialog_content =>
      'Вы уверены, что хотите удалить свой аккаунт Shiftly? Это действие необратимо.';

  @override
  String get profile_delete_final_title => 'Окончательное подтверждение';

  @override
  String get profile_delete_final_content_1 =>
      'Ваш аккаунт и все данные на сервере будут безвозвратно удалены.';

  @override
  String get profile_delete_final_content_2 =>
      'Это действие необратимо. Продолжить удаление аккаунта?';

  @override
  String get profile_delete_success => 'Аккаунт успешно удален';

  @override
  String get settings_byos_delete_title => 'Удалить резервную копию BYOS';

  @override
  String get settings_byos_delete_sub =>
      'Безвозвратно удалить файл резервной копии с Google Диска';

  @override
  String get settings_byos_delete_dialog_title => 'Удалить данные BYOS';

  @override
  String get settings_byos_delete_dialog_content =>
      'Вы уверены, что хотите удалить резервные данные с Google Диска?';

  @override
  String get settings_byos_delete_final_title => 'Последнее предупреждение';

  @override
  String get settings_byos_delete_final_content_1 =>
      'Ваш файл резервной копии на Google Диске будет полностью уничтожен.';

  @override
  String get settings_byos_delete_final_content_2 =>
      'Вы уверены, что хотите навсегда удалить резервные данные BYOS?';

  @override
  String get settings_byos_delete_success =>
      'Резервные данные BYOS успешно удалены';

  @override
  String get add_shift_wage_segments_title =>
      'Сегменты процентной ставки (Необязательно)';

  @override
  String get add_shift_wage_segments_subtitle =>
      'Определите периоды с разным процентом ставки (например, 150%)';

  @override
  String get add_shift_wage_segments_add => 'Добавить период';

  @override
  String get add_shift_wage_segment_start => 'Начало';

  @override
  String get add_shift_wage_segment_end => 'Конец';

  @override
  String get add_shift_wage_segment_percentage => 'Процент ставки %';

  @override
  String get error_segment_invalid_time =>
      'Время окончания сегмента должно быть позже времени начала';

  @override
  String get error_segment_overlap => 'Временные диапазоны пересекаются';

  @override
  String get legal_privacy_policy => 'Политика конфиденциальности';

  @override
  String get legal_terms_of_service => 'Условия обслуживания';

  @override
  String get legal_disclaimer_notice =>
      'Регистрируясь или входя в систему, вы соглашаетесь с нашими Условиями обслуживания и Политикой конфиденциальности.';

  @override
  String get legal_cookie_title =>
      'Настройки файлов cookie и конфиденциальности';

  @override
  String get legal_cookie_description =>
      'Мы используем технологии локального хранения и файлы cookie для аутентификации, безопасности и телеметрии сбоев. Вы можете принять все или использовать только необходимые файлы cookie.';

  @override
  String get legal_cookie_accept_all => 'Принять все';

  @override
  String get legal_cookie_necessary_only => 'Только необходимые';

  @override
  String get legal_cookie_necessary_desc =>
      'Необходимы для аутентификации, безопасного хранения токенов и настроек сеанса.';

  @override
  String get legal_cookie_analytics_desc =>
      'Анонимные журналы ошибок и телеметрия производительности при сбоях через Firebase.';

  @override
  String get legal_cookie_customize => 'Настроить';

  @override
  String get legal_cookie_save_preferences => 'Сохранить настройки';

  @override
  String get legal_cookie_essential => 'Основные и защитные файлы cookie';

  @override
  String get legal_cookie_always_active => 'Всегда активны';

  @override
  String get legal_cookie_optional => 'Необязательные';

  @override
  String get common_close => 'Закрыть';

  @override
  String get settings_section_overtime => 'Правила сверхурочных';

  @override
  String get settings_overtime_enable => 'Включить расчет сверхурочных';

  @override
  String get settings_overtime_enable_sub =>
      'Автоматический расчет многоуровневой компенсации сверхурочных';

  @override
  String get settings_overtime_regular_threshold =>
      'Порог обычных часов (часы)';

  @override
  String get settings_overtime_tier1_limit =>
      'Длительность первого уровня сверхурочных (часы)';

  @override
  String get settings_overtime_tier1_rate => 'Множитель первого уровня (%)';

  @override
  String get settings_overtime_tier2_rate =>
      'Множитель дополнительного уровня (%)';

  @override
  String get settings_overtime_update_button =>
      'Сохранить правила сверхурочных';

  @override
  String get settings_overtime_saved =>
      'Правила сверхурочных успешно обновлены';

  @override
  String get overtime_notification_detected =>
      'Смена включает сверхурочные. Зарплата рассчитана по ставкам сверхурочных.';

  @override
  String get overtime_breakdown_title => 'Структура зарплаты';

  @override
  String get overtime_regular_hours_label => 'Обычные часы';

  @override
  String get overtime_tier1_label => 'Сверхурочные (125%)';

  @override
  String get overtime_tier2_label => 'Сверхурочные (150%)';

  @override
  String get overtime_tier_custom_label => 'Сверхурочные ([[rate]]%)';

  @override
  String get overtime_tag_label => 'Сверхурочные';

  @override
  String get overtime_total_paid_time => 'Всего оплачиваемого времени';

  @override
  String get overtime_total_earnings => 'Общий заработок за смену';

  @override
  String get overtime_unpaid_break => 'Неоплачиваемый перерыв';

  @override
  String get analytics_overtime_section_title => 'Сводка сверхурочных и часы';

  @override
  String get analytics_regular_hours => 'Обычные часы';

  @override
  String get analytics_overtime_hours => 'Часы сверхурочных';

  @override
  String get analytics_overtime_earnings => 'Заработок за сверхурочные';

  @override
  String get shabbat_tag_label => 'Шаббат';

  @override
  String get holiday_tag_label => 'Праздник';

  @override
  String get settings_shabbat_section => 'Шаббат и праздники';

  @override
  String get settings_shabbat_enable =>
      'Автоматический расчет Шаббата и праздников';

  @override
  String get settings_shabbat_enable_sub =>
      'Автоматическое определение Шаббата, праздников и специальных ставок';

  @override
  String get settings_shabbat_multiplier_label => 'Ставка в Шаббат (%)';

  @override
  String get settings_holiday_multiplier_label => 'Ставка в праздник (%)';

  @override
  String get settings_candle_lighting_label =>
      'Зажжение свечей (минут до заката)';

  @override
  String get settings_shabbat_exit_label =>
      'Исход Шаббата (минут после заката)';

  @override
  String get settings_shabbat_saved =>
      'Настройки Шаббата и праздников успешно сохранены';

  @override
  String get settings_shabbat_save_button =>
      'Сохранить настройки Шаббата и праздников';

  @override
  String get analytics_shabbat_holiday_summary =>
      'Сводка по Шаббату и праздникам';

  @override
  String get analytics_shabbat_hours => 'Часы в Шаббат';

  @override
  String get analytics_holiday_hours => 'Праздничные часы';

  @override
  String get onboarding_shabbat_title => 'Шаббат и еврейские праздники';

  @override
  String get onboarding_shabbat_subtitle =>
      'Автоматическое определение Шаббата, праздников и специальных ставок';

  @override
  String add_shift_unknown_job_title(Object trailingText) {
    return 'Нераспознанный тип смены: «$trailingText»';
  }

  @override
  String get add_shift_unknown_job_desc =>
      'Обнаружен тип должности, которого нет в вашем списке. Выберите альтернативную должность или сохраните как описание:';

  @override
  String get add_shift_select_job_label => 'Выберите тип должности';

  @override
  String get add_shift_apply_all_instances =>
      'Применять автоматически ко всем случаям этого типа';

  @override
  String get add_shift_skip => 'Пропустить';

  @override
  String get add_shift_save_as_desc => 'Сохранить только как описание';

  @override
  String get add_shift_assign => 'Назначить';

  @override
  String add_shift_shabbat_breakdown(Object rate) {
    return 'Шаббат ($rate%)';
  }

  @override
  String add_shift_holiday_breakdown(Object name, Object rate) {
    return '$name ($rate%)';
  }

  @override
  String get settings_update_section => 'Обновления приложения';

  @override
  String get settings_update_check_button => 'Проверить обновления на GitHub';

  @override
  String settings_update_current_version(String version) {
    return 'Текущая версия: v$version';
  }

  @override
  String get settings_update_checking_toast =>
      'Проверка обновлений в репозитории GitHub...';

  @override
  String get settings_update_error_toast =>
      'Не удалось подключиться к GitHub. Пожалуйста, попробуйте позже.';

  @override
  String settings_update_latest_toast(String version) {
    return 'Приложение обновлено до последней версии! (v$version)';
  }

  @override
  String get update_dialog_title => 'Доступна новая версия!';

  @override
  String update_dialog_version_available(String version) {
    return 'Доступна для скачивания версия $version';
  }

  @override
  String update_dialog_installed_version(String version) {
    return 'Установленная версия: $version';
  }

  @override
  String update_dialog_new_version(String version) {
    return 'Новая: $version';
  }

  @override
  String get update_dialog_whats_new => 'Что нового в этой версии:';

  @override
  String get update_dialog_downloading => 'Загрузка файла обновления...';

  @override
  String get update_dialog_later => 'Позже';

  @override
  String get update_dialog_open_browser => 'Открыть в браузере';

  @override
  String get update_dialog_update_now => 'Обновить сейчас';

  @override
  String get update_dialog_open_download => 'Открыть страницу загрузки';

  @override
  String get update_dialog_mandatory_notice =>
      'Это обновление обязательно для дальнейшего использования приложения.';

  @override
  String get update_service_no_changelog =>
      'Информация об изменениях недоступна.';

  @override
  String update_service_download_failed(Object statusCode) {
    return 'Не удалось скачать файл (Код ошибки: $statusCode)';
  }

  @override
  String get update_service_no_installer =>
      'На устройстве не найдено приложений для установки APK. Попробуйте открыть в браузере.';

  @override
  String update_service_cannot_launch_installer(String message) {
    return 'Не удалось запустить установщик пакета ($message)';
  }

  @override
  String update_service_download_error(Object error) {
    return 'Ошибка при загрузке обновления: $error';
  }

  @override
  String get common_show_password => 'Показать пароль';

  @override
  String get common_hide_password => 'Скрыть пароль';

  @override
  String get accessibility_statement => 'Заявление о доступности';

  @override
  String get settings_accessibility_sub =>
      'Информация о доступности и контакты';

  @override
  String get all_shifts_title => 'Все смены';

  @override
  String get export_format_excel => 'Таблица Excel (.xlsx)';

  @override
  String get export_format_pdf => 'Документ PDF (.pdf)';

  @override
  String get export_include_analytics => 'Включить аналитику и сводки';

  @override
  String get export_include_analytics_sub =>
      'Добавить графики и обзор статистики в отчет';

  @override
  String get import_title => 'Импорт смен';

  @override
  String get import_button => 'Импортировать файл (.xlsx, .csv, .json)';

  @override
  String get import_paste_or_pick => 'Выберите файл или вставьте содержимое';

  @override
  String get import_preview_title => 'Предпросмотр импорта';

  @override
  String import_found_shifts(int count) {
    return 'Найдено валидных смен для импорта: $count';
  }

  @override
  String import_confirm_button(int count) {
    return 'Импортировать смен: $count';
  }

  @override
  String import_success_msg(int count) {
    return 'Успешно импортировано смен: $count!';
  }

  @override
  String get import_error_msg =>
      'Не удалось импортировать смены или неподдерживаемый формат';

  @override
  String get pdf_report_title => 'Shiftly - Отчет о работе и зарплате';

  @override
  String get pdf_detailed_log => 'Подробная история смен';

  @override
  String get pdf_analytics_summary => 'Аналитика и сводка';

  @override
  String get pdf_total_net_pay => 'Всего зарплата чистыми';

  @override
  String get pdf_total_hours => 'Всего чистых часов';

  @override
  String get pdf_avg_rate => 'Ср. эффективная ставка';

  @override
  String get pdf_shifts_count => 'Количество смен';

  @override
  String get pdf_total_base => 'Базовый оклад';

  @override
  String get pdf_total_tips => 'Чаевые';

  @override
  String get pdf_total_expenses => 'Расходы';

  @override
  String get pdf_total_incomes => 'Доходы';

  @override
  String get pdf_col_date => 'Дата';

  @override
  String get pdf_col_job => 'Должность';

  @override
  String get pdf_col_time => 'Часы';

  @override
  String get pdf_col_start_time => 'Время начала';

  @override
  String get pdf_col_end_time => 'Время окончания';

  @override
  String get pdf_col_tags => 'Теги';

  @override
  String get pdf_col_net_hours => 'Ч. чист.';

  @override
  String get pdf_col_hourly_rate => 'Ставка';

  @override
  String get pdf_col_base => 'База';

  @override
  String get pdf_col_overtime => 'Сверхурочные';

  @override
  String get pdf_col_shabbat => 'Шаббат';

  @override
  String get pdf_col_tips => 'Чаевые';

  @override
  String get pdf_col_extras => 'Доплаты';

  @override
  String get pdf_col_net_pay => 'Итого чистыми';

  @override
  String get pdf_col_notes => 'Примечания';

  @override
  String get excel_sheet_shifts => 'Детали смен';

  @override
  String get excel_sheet_analytics => 'Сводка аналитики';

  @override
  String report_generated_label(String date) {
    return 'Создано: $date';
  }

  @override
  String report_total_shifts_label(int count) {
    return 'Всего смен: $count';
  }

  @override
  String get report_category_label => 'Категория';

  @override
  String get report_rate_multiplier_label => 'Множитель ставки';

  @override
  String get report_hours_label => 'Часы';

  @override
  String get report_earnings_label => 'Заработок';

  @override
  String get report_regular_hours => 'Обычные часы (100%)';

  @override
  String get report_overtime_125 => 'Сверхурочные 1 ур. (125%)';

  @override
  String get report_overtime_150 => 'Сверхурочные 2 ур. (150%)';

  @override
  String get report_shabbat_hours => 'Часы в Шаббат';

  @override
  String get report_holiday_hours => 'Праздничные часы';

  @override
  String get report_disabled_status => '(Отключено в настройках)';

  @override
  String get report_job_distribution => 'Распределение по должностям';

  @override
  String get report_job_name => 'Название должности';

  @override
  String get report_pct_net_pay => '% от зарплаты чистыми';

  @override
  String get report_totals_row => 'ИТОГО';

  @override
  String get report_tag_overtime => 'Сверхурочные';

  @override
  String get report_tag_shabbat => 'Шаббат';

  @override
  String get report_tag_holiday => 'Праздник';

  @override
  String report_page_number(Object current, Object total) {
    return 'Страница $current из $total';
  }

  @override
  String pdf_col_hourly_rate_symbol(String symbol) {
    return 'Почасовая ставка ($symbol)';
  }

  @override
  String pdf_col_base_symbol(String symbol) {
    return 'Базовый оклад ($symbol)';
  }

  @override
  String report_overtime_125_symbol(String symbol) {
    return 'Сверхурочные 125% ($symbol)';
  }

  @override
  String report_overtime_150_symbol(String symbol) {
    return 'Сверхурочные 150% ($symbol)';
  }

  @override
  String pdf_col_shabbat_symbol(String symbol) {
    return 'Шаббат / Праздник ($symbol)';
  }

  @override
  String pdf_col_tips_symbol(String symbol) {
    return 'Чаевые ($symbol)';
  }

  @override
  String pdf_total_incomes_symbol(String symbol) {
    return 'Автодоходы ($symbol)';
  }

  @override
  String pdf_total_expenses_symbol(String symbol) {
    return 'Авторасходы ($symbol)';
  }

  @override
  String pdf_col_net_pay_symbol(String symbol) {
    return 'Всего зарплата чистыми ($symbol)';
  }

  @override
  String get shift_template_title => 'Шаблоны смен';

  @override
  String get shift_template_subtitle =>
      'Быстрые шаблоны для быстрого и легкого добавления смен.';

  @override
  String get shift_template_morning => 'Утренняя смена';

  @override
  String get shift_template_evening => 'Вечерняя смена';

  @override
  String get shift_template_night => 'Ночная смена';

  @override
  String get shift_template_add_button => 'Добавить шаблон';

  @override
  String get shift_template_save_current => 'Сохранить как шаблон';

  @override
  String get shift_template_applied_snack => 'Шаблон применен';

  @override
  String get shift_template_saved_snack => 'Шаблон успешно сохранен';

  @override
  String get shift_template_deleted_snack => 'Шаблон удален';

  @override
  String get shift_template_delete_confirm_title => 'Удалить шаблон';

  @override
  String get shift_template_delete_confirm_content =>
      'Вы уверены, что хотите удалить этот шаблон?';

  @override
  String get shift_template_name_label => 'Название шаблона';

  @override
  String get shift_template_select_prompt => 'Шаблоны быстрых смен';

  @override
  String get shift_template_manage => 'Управление шаблонами';

  @override
  String get shift_template_empty => 'Шаблоны смен еще не сохранены';

  @override
  String get shift_template_edit_title => 'Изменить шаблон';

  @override
  String get shift_template_new_title => 'Новый шаблон смены';

  @override
  String get expenses_type_income => 'доход';

  @override
  String get expenses_type_expense => 'расход';
}
