// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_back => 'Atrás';

  @override
  String get common_start => '¡Empezar!';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_tagline => 'MOTOR DE TURNOS Y SALARIOS';

  @override
  String get nav_calendar => 'Calendario';

  @override
  String get nav_analytics => 'Análisis';

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_expenses => 'Gastos';

  @override
  String get nav_summaries => 'Resúmenes';

  @override
  String get common_hours_suffix => 'horas';

  @override
  String get common_min_suffix => 'min';

  @override
  String get common_net => 'Neto';

  @override
  String get common_shifts_count => 'Turnos';

  @override
  String get common_save_and_finish => 'Guardar y terminar';

  @override
  String get common_reset => 'Restablecer';

  @override
  String get common_reset_and_cancel => 'Cancelar y restablecer';

  @override
  String get onboarding_welcome_title => 'Bienvenido a Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'La aplicación que te ayuda a registrar tus turnos, salario y propinas de forma fácil y precisa.';

  @override
  String get onboarding_welcome_description =>
      'Configuremos algunos datos básicos para empezar.';

  @override
  String onboarding_step_progress(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboarding_skip_setup => 'Omitir configuración';

  @override
  String get onboarding_language_title => 'Idioma de la aplicación';

  @override
  String get onboarding_language_subtitle => 'Elige tu idioma preferido.';

  @override
  String get onboarding_currency_title => 'Seleccionar moneda';

  @override
  String get onboarding_currency_subtitle =>
      '¿Qué moneda te gustaría usar para el salario y los gastos?';

  @override
  String get monthly_progress_setting_title =>
      'Significado de la línea de progreso';

  @override
  String get monthly_progress_mode_month => 'Tiempo transcurrido en el mes';

  @override
  String get monthly_progress_mode_financial_goal =>
      'Progreso hacia una meta financiera';

  @override
  String get monthly_progress_goal_amount => 'Monto de la meta mensual';

  @override
  String get monthly_progress_invalid_goal =>
      'Ingresa una meta financiera mayor que cero';

  @override
  String get monthly_progress_month_elapsed => 'Progreso del mes';

  @override
  String get monthly_progress_financial_goal => 'Progreso de la meta';

  @override
  String get onboarding_breaks_title => 'Configuración de descansos';

  @override
  String get onboarding_breaks_subtitle => '¿Cuánto suele durar un descanso?';

  @override
  String get onboarding_breaks_enable => 'Activar descansos';

  @override
  String get onboarding_breaks_paid_label => 'Descanso pagado (minutos)';

  @override
  String get onboarding_breaks_unpaid_label => 'Descanso no pagado (minutos)';

  @override
  String get onboarding_auto_expenses_title => 'Gastos recurrentes';

  @override
  String get onboarding_auto_expenses_subtitle =>
      '¿Tienes gastos recurrentes en cada turno? (ej. transporte)';

  @override
  String get onboarding_auto_expenses_enable => 'Activar gastos automáticos';

  @override
  String get onboarding_auto_expenses_add_button => 'Añadir gasto';

  @override
  String get onboarding_auto_expenses_desc_label => 'Descripción';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'El monto debe ser mayor a 0';

  @override
  String get onboarding_auto_incomes_title => 'Ingresos recurrentes';

  @override
  String get onboarding_auto_incomes_subtitle =>
      '¿Tienes ingresos recurrentes en cada turno? (ej. reembolso de transporte)';

  @override
  String get onboarding_auto_incomes_enable => 'Activar ingresos automáticos';

  @override
  String get onboarding_auto_incomes_add_button => 'Añadir ingreso';

  @override
  String get onboarding_job_types_title => 'Turnos y salarios';

  @override
  String get onboarding_job_types_subtitle =>
      'Define tus diferentes roles y tarifas por hora.';

  @override
  String get onboarding_job_types_add_button => 'Añadir tipo de turno';

  @override
  String get onboarding_job_types_edit_button => 'Editar tipo de turno';

  @override
  String get onboarding_job_types_delete_title => 'Eliminar puesto';

  @override
  String get onboarding_job_types_delete_desc => 'Eliminar puesto ';

  @override
  String get onboarding_job_types_rate_suffix => 'por hora';

  @override
  String get onboarding_job_types_same => 'Ya existe un puesto con este nombre';

  @override
  String get default_job_buffet => 'Bufé';

  @override
  String get default_job_steward => 'Steward';

  @override
  String get default_job_unloading => 'Descarga';

  @override
  String get default_expenses_trips => 'Viajes';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_section_app => 'Aplicación';

  @override
  String get settings_section_work_pay => 'Trabajo y pago';

  @override
  String get settings_section_breaks => 'Duración de los descansos (min)';

  @override
  String get settings_section_danger => 'Zona de peligro';

  @override
  String get settings_field_theme => 'Tema';

  @override
  String get settings_field_language => 'Idioma de la aplicación';

  @override
  String get settings_field_currency => 'Moneda de visualización';

  @override
  String get settings_field_currency_sub =>
      'Moneda utilizada para el salario y los gastos';

  @override
  String get settings_field_breaks_enabled => 'Activar descansos';

  @override
  String get settings_field_breaks_enabled_sub =>
      'Mostrar u ocultar la configuración de descansos en la app';

  @override
  String get settings_field_paid_break => 'Descanso corto (Pagado)';

  @override
  String get settings_field_unpaid_break => 'Descanso largo (No pagado)';

  @override
  String get settings_action_update_breaks => 'Actualizar horarios';

  @override
  String get settings_action_factory_reset => 'Restablecer valores de fábrica';

  @override
  String get settings_action_factory_reset_sub =>
      'Eliminar permanentemente todos los turnos, roles y gastos';

  @override
  String get settings_dialog_update_breaks_title =>
      'Actualizar tiempos de descanso';

  @override
  String get settings_dialog_factory_reset_title => '¿Restablecer datos?';

  @override
  String get settings_dialog_factory_reset_content =>
      '¿Estás seguro de que deseas eliminar todos los datos de trabajo y restablecer la aplicación? Esta acción no se puede deshacer.';

  @override
  String get settings_dialog_final_confirm_title => 'Confirmación final';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'Advertencia: Todo el historial de turnos, salarios y gastos se eliminará permanentemente.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      '¿Estás seguro de que quieres eliminar todo?';

  @override
  String get settings_dialog_final_confirm_button =>
      'Eliminar todo permanentemente';

  @override
  String get settings_dialog_error_enter_desc =>
      'Por favor, introduce una descripción para cada gasto';

  @override
  String get settings_dialog_error_enter_income_desc =>
      'Por favor, introduce una descripción para cada ingreso';

  @override
  String get settings_theme_system => 'Sistema';

  @override
  String get settings_theme_light => 'Día';

  @override
  String get settings_theme_dark => 'Noche';

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
  String get settings_current_rate => 'Tarifa actual';

  @override
  String get settings_wage_history_title => 'Historial salarial';

  @override
  String get settings_job_name_label => 'Nombre del puesto';

  @override
  String get settings_job_rate_label => 'Tarifa por hora (Nueva)';

  @override
  String get home_empty_state_title => 'Aún no hay turnos registrados';

  @override
  String get home_empty_state_subtitle =>
      'Haz clic en \"Nuevo turno\" para empezar';

  @override
  String get home_total_card_title => 'Total acumulado (Neto menos gastos)';

  @override
  String get home_total_card_hours => 'Horas';

  @override
  String get home_total_card_base => 'Base';

  @override
  String get home_total_card_tips => 'Propinas';

  @override
  String get home_total_card_expenses => 'Gastos';

  @override
  String get home_active_timer_break => 'Turno en descanso...';

  @override
  String get home_active_timer_active => 'Turno activo:';

  @override
  String get home_active_timer_time => 'Tiempo:';

  @override
  String get home_shift_list_net_total => 'Total neto';

  @override
  String get home_shift_list_no_shifts => 'No hay turnos este día';

  @override
  String get home_shift_list_no_shifts_month => 'No hay turnos este mes';

  @override
  String get shift_history_empty_title => 'No se encontraron turnos';

  @override
  String get shift_history_empty_subtitle =>
      'No hay historial de turnos disponible';

  @override
  String get home_shift_list_select_day =>
      'Selecciona un día para ver los turnos';

  @override
  String get home_shift_list_shifts_on => 'Turnos el';

  @override
  String get home_action_new_shift => 'Nuevo turno';

  @override
  String get home_action_calendar => 'Calendario';

  @override
  String get calendar_legend_today => 'Hoy';

  @override
  String get calendar_legend_selected => 'Seleccionado';

  @override
  String get calendar_legend_shift => 'Turno';

  @override
  String get calendar_legend_holiday => 'Festivo / Shabat';

  @override
  String get calendar_legend_holiday_shift => 'Turno en festivo';

  @override
  String get expenses_title => 'Gastos e ingresos';

  @override
  String get expenses_tab_expenses => 'Gastos';

  @override
  String get expenses_tab_incomes => 'Ingresos especiales';

  @override
  String get expenses_auto_section_title => 'Gastos recurrentes de turno';

  @override
  String get expenses_auto_section_subtitle =>
      'Añadir gastos recurrentes a cada nuevo turno';

  @override
  String get expenses_auto_section_enable => 'Gastos automáticos';

  @override
  String get expenses_history_section_title => 'Desglose mensual de gastos';

  @override
  String get expenses_action_add_auto => 'Añadir gasto recurrente';

  @override
  String get expenses_action_update_settings => 'Actualizar ajustes';

  @override
  String get expenses_action_new_expense => 'Nuevo gasto';

  @override
  String get expenses_dialog_add_title => 'Añadir gasto';

  @override
  String get expenses_dialog_edit_title => 'Editar gasto';

  @override
  String get expenses_dialog_delete_title => 'Eliminar gasto';

  @override
  String get expenses_no_history => 'No hay gastos registrados';

  @override
  String get expenses_delete_expense_confirm_content =>
      '¿Eliminar \"[[desc]]\" por [[amount]]?';

  @override
  String get expenses_total_label => 'Total';

  @override
  String get expenses_auto_updated_msg =>
      'Ajustes de gastos automáticos actualizados';

  @override
  String get expenses_deleted_msg => 'Gasto eliminado';

  @override
  String get expenses_link_shift_dialog_title => 'Vincular al turno';

  @override
  String get expenses_link_shift_dialog_content =>
      'Se encontró un turno en esta fecha. ¿Deseas vincular este [[type]] al turno o guardarlo de forma independiente?';

  @override
  String get expenses_link_shift_button => 'Vincular al turno';

  @override
  String get expenses_save_standalone_button => 'Guardar independiente';

  @override
  String get expenses_no_shift_dialog_title => 'No se encontró ningún turno';

  @override
  String get expenses_no_shift_dialog_content =>
      'No hay ningún turno en esta fecha. ¿Aún quieres crear este [[type]]?';

  @override
  String get expenses_create_anyway_button => 'Crear de todos modos';

  @override
  String get expenses_auto_incomes_updated_msg =>
      'Ajustes de ingresos automáticos actualizados';

  @override
  String get expenses_auto_incomes_section_title =>
      'Ingresos recurrentes de turno';

  @override
  String get expenses_auto_incomes_section_subtitle =>
      'Añadir ingresos recurrentes a cada nuevo turno';

  @override
  String get expenses_auto_incomes_section_enable => 'Ingresos automáticos';

  @override
  String get incomes_history_section_title => 'Desglose mensual de ingresos';

  @override
  String get incomes_action_new_income => 'Nuevo ingreso';

  @override
  String get incomes_dialog_add_title => 'Añadir ingreso especial';

  @override
  String get incomes_dialog_edit_title => 'Editar ingreso';

  @override
  String get incomes_dialog_delete_title => 'Eliminar ingreso';

  @override
  String get incomes_no_history => 'No hay ingresos especiales registrados';

  @override
  String get incomes_delete_income_confirm_content =>
      '¿Eliminar \"[[desc]]\" por [[amount]]?';

  @override
  String get incomes_deleted_msg => 'Ingreso eliminado';

  @override
  String get add_shift_title => 'Nuevo turno';

  @override
  String get add_shift_edit_title => 'Editar turno';

  @override
  String get add_shift_timer_tab => 'Temporizador';

  @override
  String get add_shift_manual_tab => 'Manual';

  @override
  String get add_shift_paste_tab => 'Pegar';

  @override
  String get add_shift_timer_accumulated_live => 'Acumulado en vivo';

  @override
  String get add_shift_timer_countdown => 'Cuenta regresiva: ';

  @override
  String get add_shift_timer_break_paid => 'En descanso pagado...';

  @override
  String get add_shift_timer_break_unpaid =>
      'En descanso no pagado (temporizador detenido)';

  @override
  String get add_shift_timer_total_break_unpaid =>
      'Total de descansos no pagados:';

  @override
  String get add_shift_timer_resume_work => 'Volver al trabajo';

  @override
  String get add_shift_timer_stop_shift => 'Detener turno';

  @override
  String get add_shift_timer_start_shift => 'Iniciar turno';

  @override
  String get add_shift_timer_continue_work => 'Continuar trabajando';

  @override
  String get add_shift_timer_stopped_msg =>
      'El temporizador se detuvo. ¿Deseas guardar el turno o seguir trabajando?';

  @override
  String get add_shift_timer_reset_title => 'Restablecer temporizador';

  @override
  String get add_shift_timer_reset_desc =>
      '¿Estás seguro de que quieres restablecer el temporizador? Se perderán todos los datos actuales.';

  @override
  String get add_shift_manual_time_section => 'Hora';

  @override
  String get add_shift_manual_date_label => 'Fecha';

  @override
  String get add_shift_manual_start_time_label => 'Hora de inicio';

  @override
  String get add_shift_manual_end_time_label => 'Hora de fin';

  @override
  String get add_shift_manual_break_type_section => 'Tipo de descanso';

  @override
  String get add_shift_manual_no_break => 'Ninguno';

  @override
  String get add_shift_manual_paid_break => 'Pagado';

  @override
  String get add_shift_manual_unpaid_break => 'No pagado';

  @override
  String get add_shift_manual_work_tips_section => 'Trabajo y propinas';

  @override
  String get add_shift_manual_job_type_label => 'Tipo de puesto';

  @override
  String get add_shift_paste_title => 'Pegar texto del turno';

  @override
  String get add_shift_paste_default_job_label =>
      'Tipo de puesto predeterminado';

  @override
  String get add_shift_paste_format_info =>
      'Formato: DD.MM (o DD.MM.AAAA) - HH:mm - HH:mm [descanso] [+ propinas]\n(Si se omite el año, se infiere el año actual)';

  @override
  String get add_shift_paste_hint =>
      'Pega los turnos aquí...\nEjemplo:\n24.6.2026 - 17:30 - 23:00 45 minutos + 50';

  @override
  String get add_shift_paste_parse_button => 'Analizar y guardar todo';

  @override
  String get add_shift_paste_parse_dialog_title => 'Analizar turnos';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      '¿Analizar y guardar los turnos del texto pegado?';

  @override
  String get add_shift_paste_error =>
      'Por favor, verifica el formato e inténtalo de nuevo';

  @override
  String get add_shift_tips_title => 'Propinas';

  @override
  String get add_shift_tips_total => 'Total';

  @override
  String get add_shift_tips_hint => 'Monto de propina';

  @override
  String get add_shift_tips_add_button => 'Añadir propina';

  @override
  String get add_shift_expenses_title => 'Gastos del turno';

  @override
  String get add_shift_expenses_total => 'Total';

  @override
  String get add_shift_expenses_add_button => 'Añadir gasto';

  @override
  String get add_shift_incomes_title => 'Ingresos del turno';

  @override
  String get add_shift_incomes_total => 'Total';

  @override
  String get add_shift_incomes_add_button => 'Añadir ingreso';

  @override
  String get add_shift_shift_ended_dialog_title => 'Guardar turno';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      '¿Estás seguro de que deseas guardar los detalles del turno?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      '¿Estás seguro de que deseas guardar los detalles del turno?';

  @override
  String get add_shift_shift_edit_dialog_title => 'Actualizar turno';

  @override
  String get add_shift_shift_saved => 'Turno guardado con éxito';

  @override
  String get add_shift_preview_title => 'Vista previa';

  @override
  String add_shift_segments_count(int count) {
    return '$count períodos';
  }

  @override
  String get add_shift_overlap_title => 'Turno superpuesto';

  @override
  String add_shift_overlap_content(num count, String details) {
    return 'Este turno se superpone con $count turno(s) existente(s):\n\n$details\n\n¿Guardarlo de todos modos?';
  }

  @override
  String get add_shift_overlap_confirm => 'Guardar de todos modos';

  @override
  String get add_shift_overlap_unknown_job => 'Puesto desconocido';

  @override
  String get add_shift_pick_a_job =>
      'Por favor, selecciona primero un tipo de puesto';

  @override
  String get add_shift_delete_title => 'Eliminar turno';

  @override
  String get add_shift_delete_desc =>
      '¿Estás seguro de que deseas eliminar el turno del';

  @override
  String get add_shift_delete_msg => 'Turno eliminado con éxito';

  @override
  String get notification_timer_channel_name => 'Turno activo';

  @override
  String get notification_timer_channel_desc =>
      'Muestra el temporizador del turno actual';

  @override
  String get notification_timer_title_active => 'Turno activo';

  @override
  String get notification_timer_title_paid_break => 'Descanso pagado';

  @override
  String get notification_timer_title_unpaid_break => 'Descanso no pagado';

  @override
  String get notification_timer_body_running => 'Temporizador en ejecución...';

  @override
  String get notification_timer_body_countdown => 'Cuenta regresiva: [[time]]';

  @override
  String get filter_title => 'Filtros de turnos';

  @override
  String get filter_clear_all => 'Restablecer filtro';

  @override
  String get filter_apply => 'Aplicar filtros';

  @override
  String get filter_wage_range => 'Rango de salario total';

  @override
  String get filter_tips_range => 'Rango de propinas';

  @override
  String get filter_expenses_range => 'Rango de gastos';

  @override
  String get filter_duration_range => 'Rango de duración (Horas)';

  @override
  String get filter_date_range => 'Rango de fechas';

  @override
  String get filter_job_type => 'Tipo de puesto';

  @override
  String get filter_select_all => 'Seleccionar todo';

  @override
  String get filter_error_no_job_selected =>
      'Por favor, selecciona al menos un tipo de puesto';

  @override
  String get filter_active_filters => 'Filtros activos:';

  @override
  String get filter_chip_wage => 'Salario: [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'Propinas: [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'Gastos: [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'Duración: [[min]] - [[max]] h';

  @override
  String get filter_chip_date => 'Fecha: [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'Puesto: [[name]]';

  @override
  String get filter_empty_state_title => 'No hay turnos coincidentes';

  @override
  String get filter_empty_state_subtitle =>
      'Intenta ajustar tus filtros para ver más resultados';

  @override
  String get auth_login_title => 'Bienvenido de nuevo';

  @override
  String get auth_register_title => 'Crear una nueva cuenta';

  @override
  String get auth_full_name_label => 'Nombre completo';

  @override
  String get auth_email_label => 'Correo electrónico';

  @override
  String get auth_password_label => 'Contraseña';

  @override
  String get auth_error_name_empty => 'Por favor, introduce tu nombre';

  @override
  String get auth_error_email_invalid => 'Correo electrónico inválido';

  @override
  String get auth_error_password_length =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get auth_login_button => 'Iniciar sesión';

  @override
  String get auth_register_button => 'Registrarse';

  @override
  String get auth_no_account_link => '¿No tienes cuenta? Regístrate ahora';

  @override
  String get auth_has_account_link => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get auth_error_generic =>
      'Ocurrió un error. Por favor, inténtalo de nuevo.';

  @override
  String get settings_logout_title => 'Cerrar sesión del sistema';

  @override
  String get settings_logout_dialog_title => 'Cerrar sesión';

  @override
  String get settings_logout_confirm_content =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settings_logout_confirm_button => 'Cerrar sesión';

  @override
  String get auth_login_success => 'Inicio de sesión exitoso';

  @override
  String get auth_register_success => 'Cuenta creada con éxito';

  @override
  String get auth_birth_date_label => 'Fecha de nacimiento';

  @override
  String get auth_error_underage => 'El usuario debe tener al menos 12 años';

  @override
  String get auth_error_birth_date_empty =>
      'Por favor, selecciona tu fecha de nacimiento';

  @override
  String get auth_error_email_exists =>
      'Esta dirección de correo electrónico ya está en uso';

  @override
  String get auth_error_user_not_found =>
      'Usuario no encontrado o contraseña incorrecta';

  @override
  String get auth_error_network =>
      'Error de conexión de red. Por favor, comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get auth_continue_as_guest => 'Continuar como invitado';

  @override
  String get auth_replace_guest_data_title => '¿Reemplazar datos de invitado?';

  @override
  String get auth_replace_guest_data_message =>
      'Iniciar sesión en una cuenta existente reemplazará los datos almacenados actualmente en este dispositivo con los datos asociados a tu cuenta. Tus datos de invitado podrían perderse permanentemente y no se podrán recuperar a menos que tengas una copia de seguridad. Asegúrate de entender estas consecuencias antes de continuar.';

  @override
  String get auth_replace_guest_data_confirm => 'Continuar';

  @override
  String get auth_replace_guest_data_cancel => 'Cancelar';

  @override
  String get auth_guest_mode_title => 'Modo invitado';

  @override
  String get auth_guest_mode_subtitle =>
      'Estás usando Shiftly en modo invitado. Tus datos se guardan localmente en este dispositivo. Crea una cuenta para sincronizar entre dispositivos o inicia sesión en una cuenta existente.';

  @override
  String get auth_guest_migration_failed =>
      'No se pudieron recuperar los datos de la cuenta. Tus datos de invitado se han conservado.';

  @override
  String get auth_register_guest_transfer =>
      'Iniciar sesión o crear cuenta de Shiftly';

  @override
  String get auth_user_deleted_local_data_preserved =>
      'Tu cuenta ya no existe en la base de datos. Se ha cerrado tu sesión, pero tus datos locales siguen guardados en este dispositivo.';

  @override
  String get home_welcome_back => 'Hola, [[name]]';

  @override
  String get settings_user_name => 'Nombre';

  @override
  String get settings_user_email => 'Correo electrónico';

  @override
  String get settings_user_password => 'Contraseña';

  @override
  String get settings_user_edit_title => 'Editar perfil';

  @override
  String get settings_user_update_success => 'Perfil actualizado con éxito';

  @override
  String get settings_logout_success => 'Sesión cerrada con éxito';

  @override
  String get settings_byos_title => 'Sincronización BYOS';

  @override
  String get settings_byos_connected => 'Conectado a Google Drive';

  @override
  String get settings_byos_last_backup => 'Última copia de seguridad: [[time]]';

  @override
  String get settings_byos_backup_now => 'Hacer copia de seguridad ahora';

  @override
  String get settings_byos_auto_sync => 'Sincronización automática';

  @override
  String get settings_byos_auto_sync_sub =>
      'Sincronizar cambios instantáneamente en la nube';

  @override
  String get settings_byos_disconnect => 'Desconectar';

  @override
  String get settings_byos_login_shiftly =>
      'Iniciar sesión en la cuenta de Shiftly';

  @override
  String get settings_byos_login_shiftly_sub =>
      'Sincronización completa en nuestra nube';

  @override
  String get settings_byos_method_title => 'Método BYOS (Google Drive)';

  @override
  String get settings_byos_method_sub =>
      'Copia de seguridad en tu nube privada';

  @override
  String get settings_byos_restore_dialog_title => 'Sincronización BYOS';

  @override
  String get settings_byos_restore_dialog_content =>
      '¿Te gustaría restaurar los datos existentes desde tu Google Drive?';

  @override
  String get settings_byos_restore_confirm => 'Restaurar';

  @override
  String get settings_byos_restore_cancel => 'Ahora no';

  @override
  String get settings_byos_login_hint =>
      'Inicia sesión para respaldar datos en la nube y usar más dispositivos';

  @override
  String get settings_restore_success =>
      'Restauración exitosa: se restauraron [[shifts]] turnos y [[jobs]] puestos.';

  @override
  String get settings_restore_no_data =>
      'No se encontró ninguna copia de seguridad en Google Drive o ocurrió un error.';

  @override
  String get export_title => 'Exportar turnos';

  @override
  String get export_format_label => 'Formato de archivo';

  @override
  String get export_format_csv => 'CSV (Compatible con Excel)';

  @override
  String get export_format_txt => 'Archivo de texto (TXT)';

  @override
  String get export_format_json => 'Copia de seguridad JSON (.json)';

  @override
  String get export_range_label => 'Rango de exportación';

  @override
  String get export_range_all => 'Todos los turnos';

  @override
  String get export_range_month => 'Mes específico';

  @override
  String get export_range_custom => 'Rango de fechas personalizado';

  @override
  String get export_start_date => 'Fecha de inicio';

  @override
  String get export_end_date => 'Fecha de fin';

  @override
  String get export_select_month => 'Seleccionar mes';

  @override
  String get export_button => 'Exportar archivo';

  @override
  String get export_success_msg => 'Archivo exportado con éxito y guardado en:';

  @override
  String get export_empty_error =>
      'No se encontraron turnos en el rango seleccionado para la exportación';

  @override
  String get analytics_title => 'Análisis e información';

  @override
  String get analytics_hero_greeting => 'Resumen financiero';

  @override
  String get analytics_hero_subtitle =>
      'Tu rendimiento financiero y tus patrones de trabajo de un vistazo';

  @override
  String get analytics_section_overview => 'Resumen';

  @override
  String get analytics_section_earnings => 'Ganancias';

  @override
  String get analytics_section_work_patterns => 'Patrones de trabajo';

  @override
  String get analytics_section_pay_breakdown => 'Desglose de pago';

  @override
  String get analytics_period_monthly => 'Mensual';

  @override
  String get analytics_period_yearly => 'Anual';

  @override
  String get analytics_period_all_time => 'Todo el tiempo';

  @override
  String get analytics_all_jobs => 'Todos los puestos';

  @override
  String get analytics_stat_total_net => 'Neto total';

  @override
  String get analytics_stat_total_hours => 'Horas totales';

  @override
  String get analytics_stat_avg_rate => 'Tarifa efectiva media';

  @override
  String get analytics_stat_tips => 'Gastos de turno netos';

  @override
  String get analytics_chart_earnings_title =>
      'Ganancias vs Gastos a lo largo del tiempo';

  @override
  String get analytics_chart_earnings_subtitle =>
      'Toca una barra para ver el desglose de pago y gastos';

  @override
  String get analytics_chart_jobs_title => 'Desglose por puesto';

  @override
  String get analytics_chart_jobs_by_earnings => 'Por ganancias';

  @override
  String get analytics_chart_jobs_by_hours => 'Por horas';

  @override
  String get analytics_no_data => 'No hay datos para el período seleccionado';

  @override
  String get analytics_selected_breakdown => 'Detalles del día seleccionado';

  @override
  String get analytics_selected_month_breakdown =>
      'Detalles del mes seleccionado';

  @override
  String get analytics_base_salary => 'Salario base';

  @override
  String get analytics_chart_cumulative_title =>
      'Crecimiento acumulado de ganancias';

  @override
  String get analytics_chart_cumulative_subtitle =>
      'Desplázate horizontalmente para ver el crecimiento salarial a lo largo del tiempo';

  @override
  String get analytics_gross_pay => 'Bruto';

  @override
  String get analytics_net_pay => 'Neto';

  @override
  String get analytics_kpi_projected => 'Pago proyectado de fin de mes';

  @override
  String get analytics_kpi_retention => 'Tasa de retención neta';

  @override
  String get analytics_chart_tod_title => 'Desglose por hora del día';

  @override
  String get analytics_chart_tod_subtitle =>
      'Comparando horas según los segmentos del día';

  @override
  String get analytics_chart_tod_dawn => 'Madrugada';

  @override
  String get analytics_chart_tod_morning => 'Mañana';

  @override
  String get analytics_chart_tod_noon => 'Mediodía';

  @override
  String get analytics_chart_tod_afternoon => 'Tarde';

  @override
  String get analytics_chart_tod_evening => 'Atardecer';

  @override
  String get analytics_chart_tod_night => 'Noche';

  @override
  String get analytics_chart_duration_title =>
      'Desglose de duración de turnos y fatiga';

  @override
  String get analytics_chart_duration_subtitle =>
      'Distribución de la duración de los turnos (corto, estándar, largo)';

  @override
  String get analytics_duration_short => 'Corto';

  @override
  String get analytics_duration_standard => 'Estándar';

  @override
  String get analytics_duration_long => 'Largo';

  @override
  String get analytics_insights_title => 'Información inteligente clave';

  @override
  String get analytics_insight_night_boost =>
      'Los turnos de tarde y noche representan el [[percent]]% de tus horas de trabajo.';

  @override
  String get analytics_insight_retention =>
      'Retienes el [[percent]]% de las ganancias brutas después de los gastos de turno.';

  @override
  String get analytics_insight_fatigue =>
      'El [[percent]]% de tus turnos duraron más de 9 horas.';

  @override
  String get analytics_insight_tips_ratio =>
      'Los gastos recurrentes representan el [[percent]]% de tus ganancias totales.';

  @override
  String analytics_shifts_format(Object count) {
    return '$count turnos';
  }

  @override
  String get analytics_no_shift_data_period =>
      'No hay datos de turnos para este período';

  @override
  String get analytics_min_shifts_hourly =>
      'Se requieren al menos 2 turnos para mostrar la tendencia del salario por hora';

  @override
  String get analytics_min_shifts_growth =>
      'Se requieren al menos 2 turnos para mostrar el crecimiento acumulado';

  @override
  String get analytics_min_shifts_retention =>
      'Se requieren al menos 2 turnos para mostrar la tendencia de retención neta';

  @override
  String get analytics_no_job_data => 'No hay datos de puestos';

  @override
  String analytics_hours_suffix_format(Object hours) {
    return '$hours h';
  }

  @override
  String analytics_utilization_format(Object pct) {
    return '$pct% de utilización';
  }

  @override
  String get common_previous => 'Anterior';

  @override
  String get common_next => 'Siguiente';

  @override
  String get analytics_tips_and_extra => 'Propinas y extras';

  @override
  String analytics_rate_boost_subtitle(Object boost) {
    return '+$boost/h extras netos';
  }

  @override
  String get analytics_retention_subtitle =>
      'Retenido después de los gastos de turno';

  @override
  String analytics_net_extras_pct_subtitle(Object percent) {
    return '$percent% del pago neto total';
  }

  @override
  String get common_unknown_job => 'Puesto desconocido';

  @override
  String get analytics_duration_range_short => '< 6 horas';

  @override
  String get analytics_duration_range_standard => '6-9 horas';

  @override
  String get analytics_duration_range_long => '> 9 horas';

  @override
  String get profile_title => 'Perfil de usuario';

  @override
  String get profile_created_at => 'Cuenta creada: [[date]]';

  @override
  String get profile_birth_date_display =>
      'Fecha de nacimiento: [[date]] (Edad: [[age]])';

  @override
  String get profile_stats_title => 'Resumen de datos guardados';

  @override
  String get profile_shifts_count => 'Turnos guardados';

  @override
  String get profile_jobs_count => 'Roles / Tipos de puesto';

  @override
  String get profile_expenses_count => 'Gastos guardados';

  @override
  String get profile_incomes_count => 'Ingresos guardados';

  @override
  String get side_menu_profile => 'Perfil de usuario';

  @override
  String get profile_old_password => 'Contraseña actual';

  @override
  String get profile_new_password => 'Nueva contraseña';

  @override
  String get profile_password_error => 'La contraseña actual es incorrecta';

  @override
  String get profile_password_required =>
      'Por favor, introduce tu contraseña actual';

  @override
  String get shift_descriptions_title => 'Resúmenes de turnos';

  @override
  String get shift_descriptions_empty =>
      'No se encontraron resúmenes de turnos';

  @override
  String get shift_description_label => 'Resumen / Descripción del turno';

  @override
  String get shift_description_hint =>
      'Introduce notas o resumen para este turno...';

  @override
  String get shift_descriptions_delete_title => 'Eliminar descripción';

  @override
  String get shift_descriptions_delete_content =>
      '¿Estás seguro de que deseas eliminar la descripción de este turno?';

  @override
  String get shift_descriptions_deleted_msg =>
      'Descripción eliminada con éxito';

  @override
  String get shift_descriptions_edit_title => 'Editar descripción';

  @override
  String get shift_descriptions_updated_msg =>
      'Descripción actualizada con éxito';

  @override
  String get common_search_by_date => 'Buscar por fecha';

  @override
  String get common_clear_date_filter => 'Borrar filtro de fecha';

  @override
  String get common_filter_date => 'Filtrar fecha';

  @override
  String get profile_delete_account => 'Eliminar cuenta';

  @override
  String get profile_delete_account_sub =>
      'Eliminar permanentemente tu cuenta de usuario de Shiftly';

  @override
  String get profile_delete_dialog_title => 'Eliminar cuenta';

  @override
  String get profile_delete_dialog_content =>
      '¿Estás seguro de que deseas eliminar tu cuenta de Shiftly? Esta acción no se puede deshacer.';

  @override
  String get profile_delete_final_title => 'Confirmación final';

  @override
  String get profile_delete_final_content_1 =>
      'Tu cuenta de usuario y todos los datos del servidor se eliminarán permanentemente.';

  @override
  String get profile_delete_final_content_2 =>
      'Esta acción es irreversible. ¿Proceder con la eliminación de la cuenta?';

  @override
  String get profile_delete_success => 'Cuenta eliminada con éxito';

  @override
  String get settings_byos_delete_title => 'Eliminar copia de seguridad BYOS';

  @override
  String get settings_byos_delete_sub =>
      'Borrar permanentemente el archivo de respaldo de Google Drive';

  @override
  String get settings_byos_delete_dialog_title => 'Eliminar datos BYOS';

  @override
  String get settings_byos_delete_dialog_content =>
      '¿Estás seguro de que deseas eliminar tus datos de respaldo de Google Drive?';

  @override
  String get settings_byos_delete_final_title => 'Advertencia final';

  @override
  String get settings_byos_delete_final_content_1 =>
      'Tu archivo de respaldo en Google Drive será destruido por completo.';

  @override
  String get settings_byos_delete_final_content_2 =>
      '¿Estás seguro de que deseas eliminar permanentemente los datos de respaldo BYOS?';

  @override
  String get settings_byos_delete_success =>
      'Datos de respaldo BYOS eliminados con éxito';

  @override
  String get add_shift_wage_segments_title =>
      'Segmentos de porcentaje de salario por hora (Opcional)';

  @override
  String get add_shift_wage_segments_subtitle =>
      'Define períodos con diferentes porcentajes de salario (ej. 150%)';

  @override
  String get add_shift_wage_segments_add => 'Añadir período';

  @override
  String get add_shift_wage_segment_start => 'Inicio';

  @override
  String get add_shift_wage_segment_end => 'Fin';

  @override
  String get add_shift_wage_segment_percentage => '% de salario';

  @override
  String get error_segment_invalid_time =>
      'La hora de fin del segmento debe ser posterior a la hora de inicio';

  @override
  String get error_segment_overlap =>
      'Hay una superposición en los rangos de tiempo';

  @override
  String get legal_privacy_policy => 'Política de privacidad';

  @override
  String get legal_terms_of_service => 'Términos de servicio';

  @override
  String get legal_disclaimer_notice =>
      'Al registrarte o iniciar sesión, aceptas nuestros Términos de servicio y Política de privacidad.';

  @override
  String get legal_cookie_title => 'Preferencias de cookies y privacidad';

  @override
  String get legal_cookie_description =>
      'Utilizamos tecnologías de almacenamiento local y cookies para la autenticación esencial, la seguridad y la telemetría de fallos de la aplicación. Puedes elegir aceptarlas todas o usar solo las cookies necesarias.';

  @override
  String get legal_cookie_accept_all => 'Aceptar todas';

  @override
  String get legal_cookie_necessary_only => 'Solo necesarias';

  @override
  String get legal_cookie_necessary_desc =>
      'Esenciales para la autenticación, almacenamiento seguro de tokens y preferencias de sesión.';

  @override
  String get legal_cookie_analytics_desc =>
      'Registros de errores anónimos y telemetría de rendimiento de fallos a través de Firebase.';

  @override
  String get legal_cookie_customize => 'Personalizar';

  @override
  String get legal_cookie_save_preferences => 'Guardar preferencias';

  @override
  String get legal_cookie_essential => 'Cookies esenciales y de seguridad';

  @override
  String get legal_cookie_always_active => 'Siempre activas';

  @override
  String get legal_cookie_optional => 'Opcionales';

  @override
  String get common_close => 'Cerrar';

  @override
  String get settings_section_overtime => 'Reglas de horas extras';

  @override
  String get settings_overtime_enable => 'Activar cálculo de horas extras';

  @override
  String get settings_overtime_enable_sub =>
      'Calcular automáticamente la compensación de horas extras por niveles';

  @override
  String get settings_overtime_regular_threshold =>
      'Umbral de horas normales (horas)';

  @override
  String get settings_overtime_tier1_limit =>
      'Duración del primer nivel de horas extras (horas)';

  @override
  String get settings_overtime_tier1_rate =>
      'Multiplicador del primer nivel (%)';

  @override
  String get settings_overtime_tier2_rate =>
      'Multiplicador del nivel adicional (%)';

  @override
  String get settings_overtime_update_button =>
      'Guardar reglas de horas extras';

  @override
  String get settings_overtime_saved =>
      'Reglas de horas extras actualizadas con éxito';

  @override
  String get overtime_notification_detected =>
      'El turno incluye horas extras. El salario se calculó según las tarifas de horas extras.';

  @override
  String get overtime_breakdown_title => 'Desglose salarial';

  @override
  String get overtime_regular_hours_label => 'Horas normales';

  @override
  String get overtime_tier1_label => 'Horas extras (125%)';

  @override
  String get overtime_tier2_label => 'Horas extras (150%)';

  @override
  String get overtime_tier_custom_label => 'Horas extras ([[rate]]%)';

  @override
  String get overtime_tag_label => 'Horas extras';

  @override
  String get overtime_total_paid_time => 'Tiempo pagado total';

  @override
  String get overtime_total_earnings => 'Ganancias totales del turno';

  @override
  String get overtime_unpaid_break => 'Descanso no pagado';

  @override
  String get analytics_overtime_section_title =>
      'Resumen y horas de horas extras';

  @override
  String get analytics_regular_hours => 'Horas normales';

  @override
  String get analytics_overtime_hours => 'Horas extras';

  @override
  String get analytics_overtime_earnings => 'Ganancias de horas extras';

  @override
  String get shabbat_tag_label => 'Shabat';

  @override
  String get holiday_tag_label => 'Festivo';

  @override
  String get settings_shabbat_section => 'Shabat y días festivos';

  @override
  String get settings_shabbat_enable =>
      'Cálculo automático de Shabat y días festivos';

  @override
  String get settings_shabbat_enable_sub =>
      'Detección automática de Shabat, días festivos y tarifas especiales';

  @override
  String get settings_shabbat_multiplier_label => 'Tarifa de Shabat (%)';

  @override
  String get settings_holiday_multiplier_label => 'Tarifa de día festivo (%)';

  @override
  String get settings_candle_lighting_label =>
      'Minutos de encendido de velas antes del atardecer';

  @override
  String get settings_shabbat_exit_label =>
      'Minutos de salida de Shabat después del atardecer';

  @override
  String get settings_shabbat_saved =>
      'Ajustes de Shabat y días festivos guardados con éxito';

  @override
  String get settings_shabbat_save_button =>
      'Guardar ajustes de Shabat y días festivos';

  @override
  String get analytics_shabbat_holiday_summary =>
      'Resumen de Shabat y días festivos';

  @override
  String get analytics_shabbat_hours => 'Horas de Shabat';

  @override
  String get analytics_holiday_hours => 'Horas de días festivos';

  @override
  String get onboarding_shabbat_title => 'Shabat y festivos judíos';

  @override
  String get onboarding_shabbat_subtitle =>
      'Detección automática de Shabat, días festivos y tarifas especiales';

  @override
  String add_shift_unknown_job_title(Object trailingText) {
    return 'Tipo de turno no reconocido: \"$trailingText\"';
  }

  @override
  String get add_shift_unknown_job_desc =>
      'Se encontró un tipo de puesto que no existe en tu lista de puestos. Elige un tipo de puesto alternativo o guárdalo como descripción:';

  @override
  String get add_shift_select_job_label => 'Seleccionar tipo de puesto';

  @override
  String get add_shift_apply_all_instances =>
      'Aplicar automáticamente a todas las instancias de este tipo';

  @override
  String get add_shift_skip => 'Omitir';

  @override
  String get add_shift_save_as_desc => 'Guardar solo como descripción';

  @override
  String get add_shift_assign => 'Asignar';

  @override
  String add_shift_shabbat_breakdown(Object rate) {
    return 'Shabbat ($rate%)';
  }

  @override
  String add_shift_holiday_breakdown(Object name, Object rate) {
    return '$name ($rate%)';
  }

  @override
  String get settings_update_section => 'Actualizaciones de la aplicación';

  @override
  String get settings_update_check_button => 'Buscar actualizaciones en GitHub';

  @override
  String settings_update_current_version(String version) {
    return 'Versión actual: v$version';
  }

  @override
  String get settings_update_checking_toast =>
      'Buscando actualizaciones en GitHub Releases...';

  @override
  String get settings_update_error_toast =>
      'No se pudo conectar a GitHub. Por favor, inténtalo de nuevo más tarde.';

  @override
  String settings_update_latest_toast(String version) {
    return '¡La aplicación está actualizada! (v$version)';
  }

  @override
  String get update_dialog_title => '¡Nueva versión disponible!';

  @override
  String update_dialog_version_available(String version) {
    return 'La versión $version está disponible para descargar';
  }

  @override
  String update_dialog_installed_version(String version) {
    return 'Versión instalada: $version';
  }

  @override
  String update_dialog_new_version(String version) {
    return 'Nuevo: $version';
  }

  @override
  String get update_dialog_whats_new => 'Novedades en esta versión:';

  @override
  String get update_dialog_downloading =>
      'Descargando archivo de actualización...';

  @override
  String get update_dialog_later => 'Más tarde';

  @override
  String get update_dialog_open_browser => 'Abrir en el navegador';

  @override
  String get update_dialog_update_now => 'Actualizar ahora';

  @override
  String get update_dialog_open_download => 'Abrir página de descarga';

  @override
  String get update_dialog_mandatory_notice =>
      'Esta actualización es necesaria para seguir usando la aplicación.';

  @override
  String get update_service_no_changelog =>
      'No hay detalles de registro de cambios disponibles.';

  @override
  String update_service_download_failed(Object statusCode) {
    return 'Error al descargar el archivo (Código de error: $statusCode)';
  }

  @override
  String get update_service_no_installer =>
      'No se encontró ninguna aplicación para instalar archivos APK en el dispositivo. Intenta abrirlo en el navegador.';

  @override
  String update_service_cannot_launch_installer(String message) {
    return 'No se pudo iniciar el instalador de paquetes ($message)';
  }

  @override
  String update_service_download_error(Object error) {
    return 'Error durante la descarga de la actualización: $error';
  }

  @override
  String get common_show_password => 'Mostrar contraseña';

  @override
  String get common_hide_password => 'Ocultar contraseña';

  @override
  String get accessibility_statement => 'Declaración de accesibilidad';

  @override
  String get settings_accessibility_sub =>
      'Información de accesibilidad y datos de contacto';

  @override
  String get all_shifts_title => 'Todos los turnos';

  @override
  String get export_format_excel => 'Hoja de Excel (.xlsx)';

  @override
  String get export_format_pdf => 'Documento PDF (.pdf)';

  @override
  String get export_include_analytics => 'Incluir análisis y resúmenes';

  @override
  String get export_include_analytics_sub =>
      'Añadir gráficos y resumen de estadísticas al informe';

  @override
  String get import_title => 'Importar turnos';

  @override
  String get import_button => 'Importar archivo (.xlsx, .csv, .json)';

  @override
  String get import_paste_or_pick => 'Elegir archivo o pegar contenido';

  @override
  String get import_preview_title => 'Vista previa de importación';

  @override
  String import_found_shifts(int count) {
    return 'Se encontraron $count turnos válidos para importar';
  }

  @override
  String import_confirm_button(int count) {
    return 'Importar $count turnos';
  }

  @override
  String import_success_msg(int count) {
    return '¡Se importaron $count turnos con éxito!';
  }

  @override
  String get import_error_msg =>
      'Error al importar turnos o formato no compatible';

  @override
  String get pdf_report_title => 'Shiftly - Informe de trabajo y salario';

  @override
  String get pdf_detailed_log => 'Historial detallado de turnos';

  @override
  String get pdf_analytics_summary => 'Análisis y resumen';

  @override
  String get pdf_total_net_pay => 'Pago neto total';

  @override
  String get pdf_total_hours => 'Horas netas totales';

  @override
  String get pdf_avg_rate => 'Tarifa efectiva media';

  @override
  String get pdf_shifts_count => 'Recuento de turnos';

  @override
  String get pdf_total_base => 'Salario base';

  @override
  String get pdf_total_tips => 'Propinas';

  @override
  String get pdf_total_expenses => 'Gastos';

  @override
  String get pdf_total_incomes => 'Ingresos';

  @override
  String get pdf_col_date => 'Fecha';

  @override
  String get pdf_col_job => 'Puesto';

  @override
  String get pdf_col_time => 'Horas';

  @override
  String get pdf_col_start_time => 'Hora de inicio';

  @override
  String get pdf_col_end_time => 'Hora de fin';

  @override
  String get pdf_col_tags => 'Etiquetas';

  @override
  String get pdf_col_net_hours => 'H. netas';

  @override
  String get pdf_col_hourly_rate => 'Tarifa';

  @override
  String get pdf_col_base => 'Base';

  @override
  String get pdf_col_overtime => 'Horas extras';

  @override
  String get pdf_col_shabbat => 'Shabat';

  @override
  String get pdf_col_tips => 'Propinas';

  @override
  String get pdf_col_extras => 'Extras';

  @override
  String get pdf_col_net_pay => 'Neto total';

  @override
  String get pdf_col_notes => 'Notas';

  @override
  String get excel_sheet_shifts => 'Detalles de turnos';

  @override
  String get excel_sheet_analytics => 'Resumen de análisis';

  @override
  String report_generated_label(String date) {
    return 'Generado: $date';
  }

  @override
  String report_total_shifts_label(int count) {
    return 'Total de turnos: $count';
  }

  @override
  String get report_category_label => 'Categoría';

  @override
  String get report_rate_multiplier_label => 'Multiplicador de tarifa';

  @override
  String get report_hours_label => 'Horas';

  @override
  String get report_earnings_label => 'Ganancias';

  @override
  String get report_regular_hours => 'Horas normales (100%)';

  @override
  String get report_overtime_125 => 'Horas extras nivel 1 (125%)';

  @override
  String get report_overtime_150 => 'Horas extras nivel 2 (150%)';

  @override
  String get report_shabbat_hours => 'Horas de Shabat';

  @override
  String get report_holiday_hours => 'Horas de festivos';

  @override
  String get report_disabled_status => '(Desactivado en ajustes)';

  @override
  String get report_job_distribution => 'Distribución por tipo de puesto';

  @override
  String get report_job_name => 'Nombre del puesto';

  @override
  String get report_pct_net_pay => '% del pago neto';

  @override
  String get report_totals_row => 'TOTALES';

  @override
  String get report_tag_overtime => 'Horas extras';

  @override
  String get report_tag_shabbat => 'Shabat';

  @override
  String get report_tag_holiday => 'Festivo';

  @override
  String report_page_number(Object current, Object total) {
    return 'Página $current de $total';
  }

  @override
  String pdf_col_hourly_rate_symbol(String symbol) {
    return 'Tarifa por hora ($symbol)';
  }

  @override
  String pdf_col_base_symbol(String symbol) {
    return 'Salario base ($symbol)';
  }

  @override
  String report_overtime_125_symbol(String symbol) {
    return 'Horas extras 125% ($symbol)';
  }

  @override
  String report_overtime_150_symbol(String symbol) {
    return 'Horas extras 150% ($symbol)';
  }

  @override
  String pdf_col_shabbat_symbol(String symbol) {
    return 'Shabat/Festivo ($symbol)';
  }

  @override
  String pdf_col_tips_symbol(String symbol) {
    return 'Propinas ($symbol)';
  }

  @override
  String pdf_total_incomes_symbol(String symbol) {
    return 'Ingresos auto ($symbol)';
  }

  @override
  String pdf_total_expenses_symbol(String symbol) {
    return 'Gastos auto ($symbol)';
  }

  @override
  String pdf_col_net_pay_symbol(String symbol) {
    return 'Pago neto total ($symbol)';
  }

  @override
  String get shift_template_title => 'Plantillas de turnos';

  @override
  String get shift_template_subtitle =>
      'Plantillas rápidas para agregar turnos de forma rápida y sencilla.';

  @override
  String get shift_template_morning => 'Turno de mañana';

  @override
  String get shift_template_evening => 'Turno de tarde';

  @override
  String get shift_template_night => 'Turno de noche';

  @override
  String get shift_template_add_button => 'Añadir plantilla';

  @override
  String get shift_template_save_current => 'Guardar como plantilla';

  @override
  String get shift_template_applied_snack => 'Plantilla aplicada';

  @override
  String get shift_template_saved_snack => 'Plantilla guardada con éxito';

  @override
  String get shift_template_deleted_snack => 'Plantilla eliminada';

  @override
  String get shift_template_delete_confirm_title => 'Eliminar plantilla';

  @override
  String get shift_template_delete_confirm_content =>
      '¿Estás seguro de que deseas eliminar esta plantilla?';

  @override
  String get shift_template_name_label => 'Nombre de la plantilla';

  @override
  String get shift_template_select_prompt => 'Plantillas de turnos rápidos';

  @override
  String get shift_template_manage => 'Gestionar plantillas';

  @override
  String get shift_template_empty =>
      'Aún no hay plantillas de turnos guardadas';

  @override
  String get shift_template_edit_title => 'Editar plantilla';

  @override
  String get shift_template_new_title => 'Nueva plantilla de turno';

  @override
  String get expenses_type_income => 'ingreso';

  @override
  String get expenses_type_expense => 'gasto';
}
