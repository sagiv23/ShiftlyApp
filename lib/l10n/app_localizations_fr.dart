// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_back => 'Retour';

  @override
  String get common_start => 'Commencer !';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_error => 'Erreur';

  @override
  String get common_success => 'Succès';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_tagline => 'MOTEUR DE SALAIRES ET DE QUARTS';

  @override
  String get nav_calendar => 'Calendrier';

  @override
  String get nav_analytics => 'Analyses';

  @override
  String get nav_home => 'Accueil';

  @override
  String get nav_expenses => 'Dépenses';

  @override
  String get nav_summaries => 'Résumés';

  @override
  String get common_hours_suffix => 'heures';

  @override
  String get common_min_suffix => 'min';

  @override
  String get common_net => 'Net';

  @override
  String get common_shifts_count => 'Quarts';

  @override
  String get common_save_and_finish => 'Enregistrer et terminer';

  @override
  String get common_reset => 'Réinitialiser';

  @override
  String get common_reset_and_cancel => 'Annuler et réinitialiser';

  @override
  String get onboarding_welcome_title => 'Bienvenue sur Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'L\'application qui vous aide à suivre vos quarts, salaires et pourboires facilement et avec précision.';

  @override
  String get onboarding_welcome_description =>
      'Configurons quelques bases pour commencer.';

  @override
  String onboarding_step_progress(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboarding_skip_setup => 'Ignorer la configuration';

  @override
  String get onboarding_language_title => 'Langue de l\'application';

  @override
  String get onboarding_language_subtitle =>
      'Choisissez votre langue préférée.';

  @override
  String get onboarding_currency_title => 'Sélectionner la devise';

  @override
  String get onboarding_currency_subtitle =>
      'Quelle devise souhaitez-vous utiliser pour le salaire et les dépenses ?';

  @override
  String get monthly_progress_setting_title =>
      'Sens de la ligne de progression';

  @override
  String get monthly_progress_mode_month => 'Temps écoulé dans le mois';

  @override
  String get monthly_progress_mode_financial_goal =>
      'Progression vers un objectif financier';

  @override
  String get monthly_progress_goal_amount => 'Montant de l\'objectif mensuel';

  @override
  String get monthly_progress_invalid_goal =>
      'Entrez un objectif financier supérieur à zéro';

  @override
  String get monthly_progress_month_elapsed => 'Progression du mois';

  @override
  String get monthly_progress_financial_goal => 'Progression de l\'objectif';

  @override
  String get onboarding_breaks_title => 'Paramètres des pauses';

  @override
  String get onboarding_breaks_subtitle =>
      'Combien de temps dure généralement une pause ?';

  @override
  String get onboarding_breaks_enable => 'Activer les pauses';

  @override
  String get onboarding_breaks_paid_label => 'Pause payée (minutes)';

  @override
  String get onboarding_breaks_unpaid_label => 'Pause non payée (minutes)';

  @override
  String get onboarding_auto_expenses_title => 'Dépenses récurrentes';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'Avez-vous des dépenses récurrentes à chaque quart ? (ex. transport)';

  @override
  String get onboarding_auto_expenses_enable =>
      'Activer les dépenses automatiques';

  @override
  String get onboarding_auto_expenses_add_button => 'Ajouter une dépense';

  @override
  String get onboarding_auto_expenses_desc_label => 'Description';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'Le montant doit être supérieur à 0';

  @override
  String get onboarding_auto_incomes_title => 'Revenus récurrents';

  @override
  String get onboarding_auto_incomes_subtitle =>
      'Avez-vous des revenus récurrents à chaque quart ? (ex. remboursement de transport)';

  @override
  String get onboarding_auto_incomes_enable =>
      'Activer les revenus automatiques';

  @override
  String get onboarding_auto_incomes_add_button => 'Ajouter un revenu';

  @override
  String get onboarding_job_types_title => 'Quarts et salaires';

  @override
  String get onboarding_job_types_subtitle =>
      'Définissez vos différents rôles et taux horaires.';

  @override
  String get onboarding_job_types_add_button => 'Ajouter un type de quart';

  @override
  String get onboarding_job_types_edit_button => 'Modifier le type de quart';

  @override
  String get onboarding_job_types_delete_title => 'Supprimer le poste';

  @override
  String get onboarding_job_types_delete_desc => 'Supprimer le poste ';

  @override
  String get onboarding_job_types_rate_suffix => 'par heure';

  @override
  String get onboarding_job_types_same => 'Un poste avec ce nom existe déjà';

  @override
  String get default_job_buffet => 'Buffet';

  @override
  String get default_job_steward => 'Steward';

  @override
  String get default_job_unloading => 'Déchargement';

  @override
  String get default_expenses_trips => 'Transport';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_section_app => 'Application';

  @override
  String get settings_section_work_pay => 'Travail et paie';

  @override
  String get settings_section_breaks => 'Durées des pauses (min)';

  @override
  String get settings_section_danger => 'Zone de danger';

  @override
  String get settings_field_theme => 'Thème';

  @override
  String get settings_field_language => 'Langue de l\'application';

  @override
  String get settings_field_currency => 'Devise d\'affichage';

  @override
  String get settings_field_currency_sub =>
      'Devise utilisée pour le salaire et les dépenses';

  @override
  String get settings_field_breaks_enabled => 'Activer les pauses';

  @override
  String get settings_field_breaks_enabled_sub =>
      'Afficher ou masquer les paramètres de pause dans l\'application';

  @override
  String get settings_field_paid_break => 'Pause courte (Payée)';

  @override
  String get settings_field_unpaid_break => 'Pause longue (Non payée)';

  @override
  String get settings_action_update_breaks => 'Mettre à jour les horaires';

  @override
  String get settings_action_factory_reset =>
      'Réinitialisation complète d\'usine';

  @override
  String get settings_action_factory_reset_sub =>
      'Supprimer définitivement tous les quarts, rôles et dépenses';

  @override
  String get settings_dialog_update_breaks_title =>
      'Mettre à jour les heures de pause';

  @override
  String get settings_dialog_factory_reset_title =>
      'Réinitialiser les données ?';

  @override
  String get settings_dialog_factory_reset_content =>
      'Voulez-vous vraiment supprimer toutes les données de travail et réinitialiser l\'application ? Cette action est irréversible.';

  @override
  String get settings_dialog_final_confirm_title => 'Confirmation finale';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'Attention : tout l\'historique des quarts, le salaire et les dépenses seront définitivement supprimés.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'Voulez-vous vraiment tout supprimer ?';

  @override
  String get settings_dialog_final_confirm_button =>
      'Tout supprimer définitivement';

  @override
  String get settings_dialog_error_enter_desc =>
      'Veuillez entrer une description pour chaque dépense';

  @override
  String get settings_dialog_error_enter_income_desc =>
      'Veuillez entrer une description pour chaque revenu';

  @override
  String get settings_theme_system => 'Système';

  @override
  String get settings_theme_light => 'Jour';

  @override
  String get settings_theme_dark => 'Nuit';

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
  String get settings_current_rate => 'Taux actuel';

  @override
  String get settings_wage_history_title => 'Historique des salaires';

  @override
  String get settings_job_name_label => 'Nom du poste';

  @override
  String get settings_job_rate_label => 'Taux horaire (Nouveau)';

  @override
  String get home_empty_state_title => 'Aucun quart enregistré pour l\'instant';

  @override
  String get home_empty_state_subtitle =>
      'Cliquez sur \"Nouveau quart\" pour commencer';

  @override
  String get home_total_card_title => 'Total accumulé (Net moins dépenses)';

  @override
  String get home_total_card_hours => 'Heures';

  @override
  String get home_total_card_base => 'Base';

  @override
  String get home_total_card_tips => 'Pourboires';

  @override
  String get home_total_card_expenses => 'Dépenses';

  @override
  String get home_active_timer_break => 'Quart en pause...';

  @override
  String get home_active_timer_active => 'Quart actif :';

  @override
  String get home_active_timer_time => 'Temps :';

  @override
  String get home_shift_list_net_total => 'Total net';

  @override
  String get home_shift_list_no_shifts => 'Aucun quart ce jour-là';

  @override
  String get home_shift_list_no_shifts_month => 'Aucun quart ce mois-ci';

  @override
  String get shift_history_empty_title => 'Aucun quart trouvé';

  @override
  String get shift_history_empty_subtitle =>
      'Aucun historique de quart disponible';

  @override
  String get home_shift_list_select_day =>
      'Sélectionnez un jour pour afficher les quarts';

  @override
  String get home_shift_list_shifts_on => 'Quarts du';

  @override
  String get home_action_new_shift => 'Nouveau quart';

  @override
  String get home_action_calendar => 'Calendrier';

  @override
  String get calendar_legend_today => 'Aujourd\'hui';

  @override
  String get calendar_legend_selected => 'Sélectionné';

  @override
  String get calendar_legend_shift => 'Quart';

  @override
  String get calendar_legend_holiday => 'Jour férié / Shabbat';

  @override
  String get calendar_legend_holiday_shift => 'Quart de jour férié';

  @override
  String get expenses_title => 'Dépenses et revenus';

  @override
  String get expenses_tab_expenses => 'Dépenses';

  @override
  String get expenses_tab_incomes => 'Revenus spéciaux';

  @override
  String get expenses_auto_section_title => 'Dépenses de quart récurrentes';

  @override
  String get expenses_auto_section_subtitle =>
      'Ajouter des dépenses récurrentes à chaque nouveau quart';

  @override
  String get expenses_auto_section_enable => 'Dépenses automatiques';

  @override
  String get expenses_history_section_title =>
      'Répartition mensuelle des dépenses';

  @override
  String get expenses_action_add_auto => 'Ajouter une dépense récurrente';

  @override
  String get expenses_action_update_settings => 'Mettre à jour les paramètres';

  @override
  String get expenses_action_new_expense => 'Nouvelle dépense';

  @override
  String get expenses_dialog_add_title => 'Ajouter une dépense';

  @override
  String get expenses_dialog_edit_title => 'Modifier la dépense';

  @override
  String get expenses_dialog_delete_title => 'Supprimer la dépense';

  @override
  String get expenses_no_history => 'Aucune dépense enregistrée';

  @override
  String get expenses_delete_expense_confirm_content =>
      'Supprimer \"[[desc]]\" pour [[amount]] ?';

  @override
  String get expenses_total_label => 'Total';

  @override
  String get expenses_auto_updated_msg =>
      'Paramètres de dépenses automatiques mis à jour';

  @override
  String get expenses_deleted_msg => 'Dépense supprimée';

  @override
  String get expenses_link_shift_dialog_title => 'Lier au quart';

  @override
  String get expenses_link_shift_dialog_content =>
      'Un quart a été trouvé à cette date. Souhaitez-vous lier ce [[type]] au quart ou l\'enregistrer de manière indépendante ?';

  @override
  String get expenses_link_shift_button => 'Lier au quart';

  @override
  String get expenses_save_standalone_button => 'Enregistrer indépendamment';

  @override
  String get expenses_no_shift_dialog_title => 'Aucun quart trouvé';

  @override
  String get expenses_no_shift_dialog_content =>
      'Il n\'y a pas de quart à cette date. Voulez-vous quand même créer ce [[type]] ?';

  @override
  String get expenses_create_anyway_button => 'Créer quand même';

  @override
  String get expenses_auto_incomes_updated_msg =>
      'Paramètres de revenus automatiques mis à jour';

  @override
  String get expenses_auto_incomes_section_title =>
      'Revenus de quart récurrents';

  @override
  String get expenses_auto_incomes_section_subtitle =>
      'Ajouter des revenus récurrents à chaque nouveau quart';

  @override
  String get expenses_auto_incomes_section_enable => 'Revenus automatiques';

  @override
  String get incomes_history_section_title =>
      'Répartition mensuelle des revenus';

  @override
  String get incomes_action_new_income => 'Nouveau revenu';

  @override
  String get incomes_dialog_add_title => 'Ajouter un revenu spécial';

  @override
  String get incomes_dialog_edit_title => 'Modifier le revenu';

  @override
  String get incomes_dialog_delete_title => 'Supprimer le revenu';

  @override
  String get incomes_no_history => 'Aucun revenu spécial enregistré';

  @override
  String get incomes_delete_income_confirm_content =>
      'Supprimer \"[[desc]]\" pour [[amount]] ?';

  @override
  String get incomes_deleted_msg => 'Revenu supprimé';

  @override
  String get add_shift_title => 'Nouveau quart';

  @override
  String get add_shift_edit_title => 'Modifier le quart';

  @override
  String get add_shift_timer_tab => 'Chronomètre';

  @override
  String get add_shift_manual_tab => 'Manuel';

  @override
  String get add_shift_paste_tab => 'Coller';

  @override
  String get add_shift_timer_accumulated_live => 'Accumulé en direct';

  @override
  String get add_shift_timer_countdown => 'Compte à rebours : ';

  @override
  String get add_shift_timer_break_paid => 'En pause payée...';

  @override
  String get add_shift_timer_break_unpaid =>
      'En pause non payée (chronomètre arrêté)';

  @override
  String get add_shift_timer_total_break_unpaid =>
      'Total des pauses non payées :';

  @override
  String get add_shift_timer_resume_work => 'Reprendre le travail';

  @override
  String get add_shift_timer_stop_shift => 'Arrêter le quart';

  @override
  String get add_shift_timer_start_shift => 'Démarrer le quart';

  @override
  String get add_shift_timer_continue_work => 'Continuer le travail';

  @override
  String get add_shift_timer_stopped_msg =>
      'Le chronomètre s\'est arrêté. Voulez-vous enregistrer le quart ou continuer à travailler ?';

  @override
  String get add_shift_timer_reset_title => 'Réinitialiser le chronomètre';

  @override
  String get add_shift_timer_reset_desc =>
      'Voulez-vous vraiment réinitialiser le chronomètre ? Toutes les données actuelles seront perdues.';

  @override
  String get add_shift_manual_time_section => 'Heure';

  @override
  String get add_shift_manual_date_label => 'Date';

  @override
  String get add_shift_manual_start_time_label => 'Heure de début';

  @override
  String get add_shift_manual_end_time_label => 'Heure de fin';

  @override
  String get add_shift_manual_break_type_section => 'Type de pause';

  @override
  String get add_shift_manual_no_break => 'Aucune';

  @override
  String get add_shift_manual_paid_break => 'Payée';

  @override
  String get add_shift_manual_unpaid_break => 'Non payée';

  @override
  String get add_shift_manual_work_tips_section => 'Travail et pourboires';

  @override
  String get add_shift_manual_job_type_label => 'Type de poste';

  @override
  String get add_shift_paste_title => 'Coller le texte du quart';

  @override
  String get add_shift_paste_default_job_label => 'Type de poste par défaut';

  @override
  String get add_shift_paste_format_info =>
      'Format : JJ.MM (ou JJ.MM.AAAA) - HH:mm - HH:mm [pause] [+ pourboires]\n(Si l\'année est omise, l\'année en cours est déduite)';

  @override
  String get add_shift_paste_hint =>
      'Collez les quarts ici...\nExemple :\n24.6.2026 - 17:30 - 23:00 45 minutes + 50';

  @override
  String get add_shift_paste_parse_button => 'Analyser et tout enregistrer';

  @override
  String get add_shift_paste_parse_dialog_title => 'Analyser les quarts';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'Analyser et enregistrer les quarts à partir du texte collé ?';

  @override
  String get add_shift_paste_error =>
      'Veuillez vérifier le format et réessayer';

  @override
  String get add_shift_tips_title => 'Pourboires';

  @override
  String get add_shift_tips_total => 'Total';

  @override
  String get add_shift_tips_hint => 'Montant du pourboire';

  @override
  String get add_shift_tips_add_button => 'Ajouter un pourboire';

  @override
  String get add_shift_expenses_title => 'Dépenses du quart';

  @override
  String get add_shift_expenses_total => 'Total';

  @override
  String get add_shift_expenses_add_button => 'Ajouter une dépense';

  @override
  String get add_shift_incomes_title => 'Revenus du quart';

  @override
  String get add_shift_incomes_total => 'Total';

  @override
  String get add_shift_incomes_add_button => 'Ajouter un revenu';

  @override
  String get add_shift_shift_ended_dialog_title => 'Enregistrer le quart';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'Voulez-vous vraiment enregistrer les détails du quart ?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'Voulez-vous vraiment enregistrer les détails du quart ?';

  @override
  String get add_shift_shift_edit_dialog_title => 'Mettre à jour le quart';

  @override
  String get add_shift_shift_saved => 'Quart enregistré avec succès';

  @override
  String get add_shift_preview_title => 'Aperçu';

  @override
  String add_shift_segments_count(int count) {
    return '$count périodes';
  }

  @override
  String get add_shift_overlap_title => 'Quart chevauchant';

  @override
  String add_shift_overlap_content(num count, String details) {
    return 'Ce quart chevauche $count quart(s) existant(s) :\n\n$details\n\nVoulez-vous l\'enregistrer quand même ?';
  }

  @override
  String get add_shift_overlap_confirm => 'Enregistrer quand même';

  @override
  String get add_shift_overlap_unknown_job => 'Poste inconnu';

  @override
  String get add_shift_pick_a_job =>
      'Veuillez d\'abord sélectionner un type de poste';

  @override
  String get add_shift_delete_title => 'Supprimer le quart';

  @override
  String get add_shift_delete_desc =>
      'Voulez-vous vraiment supprimer le quart du';

  @override
  String get add_shift_delete_msg => 'Quart supprimé avec succès';

  @override
  String get notification_timer_channel_name => 'Quart actif';

  @override
  String get notification_timer_channel_desc =>
      'Affiche le chronomètre du quart en cours';

  @override
  String get notification_timer_title_active => 'Quart actif';

  @override
  String get notification_timer_title_paid_break => 'Pause payée';

  @override
  String get notification_timer_title_unpaid_break => 'Pause non payée';

  @override
  String get notification_timer_body_running => 'Chronomètre en cours...';

  @override
  String get notification_timer_body_countdown => 'Compte à rebours : [[time]]';

  @override
  String get filter_title => 'Filtres de quarts';

  @override
  String get filter_clear_all => 'Réinitialiser le filtre';

  @override
  String get filter_apply => 'Appliquer les filtres';

  @override
  String get filter_wage_range => 'Plage de salaire total';

  @override
  String get filter_tips_range => 'Plage de pourboires';

  @override
  String get filter_expenses_range => 'Plage de dépenses';

  @override
  String get filter_duration_range => 'Plage de durée (Heures)';

  @override
  String get filter_date_range => 'Plage de dates';

  @override
  String get filter_job_type => 'Type de poste';

  @override
  String get filter_select_all => 'Tout sélectionner';

  @override
  String get filter_error_no_job_selected =>
      'Veuillez sélectionner au moins un type de poste';

  @override
  String get filter_active_filters => 'Filtres actifs :';

  @override
  String get filter_chip_wage => 'Salaire : [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'Pourboires : [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'Dépenses : [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'Durée : [[min]] - [[max]] h';

  @override
  String get filter_chip_date => 'Date : [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'Poste : [[name]]';

  @override
  String get filter_empty_state_title => 'Aucun quart correspondant';

  @override
  String get filter_empty_state_subtitle =>
      'Essayez d\'ajuster vos filtres pour voir plus de résultats';

  @override
  String get auth_login_title => 'Bon retour';

  @override
  String get auth_register_title => 'Créer un nouveau compte';

  @override
  String get auth_full_name_label => 'Nom complet';

  @override
  String get auth_email_label => 'E-mail';

  @override
  String get auth_password_label => 'Mot de passe';

  @override
  String get auth_error_name_empty => 'Veuillez entrer un nom';

  @override
  String get auth_error_email_invalid => 'E-mail invalide';

  @override
  String get auth_error_password_length =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get auth_login_button => 'Se connecter';

  @override
  String get auth_register_button => 'S\'inscrire';

  @override
  String get auth_no_account_link => 'Pas de compte ? S\'inscrire';

  @override
  String get auth_has_account_link => 'Déjà un compte ? Se connecter';

  @override
  String get auth_error_generic =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get settings_logout_title => 'Se déconnecter du système';

  @override
  String get settings_logout_dialog_title => 'Déconnexion';

  @override
  String get settings_logout_confirm_content =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get settings_logout_confirm_button => 'Se déconnecter';

  @override
  String get auth_login_success => 'Connexion réussie';

  @override
  String get auth_register_success => 'Compte créé avec succès';

  @override
  String get auth_birth_date_label => 'Date de naissance';

  @override
  String get auth_error_underage => 'L\'utilisateur doit avoir au moins 12 ans';

  @override
  String get auth_error_birth_date_empty =>
      'Veuillez sélectionner votre date de naissance';

  @override
  String get auth_error_email_exists =>
      'Cette adresse e-mail est déjà utilisée';

  @override
  String get auth_error_user_not_found =>
      'Utilisateur introuvable ou mot de passe incorrect';

  @override
  String get auth_error_network =>
      'Erreur de connexion réseau. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get auth_continue_as_guest => 'Continuer en tant qu\'invité';

  @override
  String get auth_replace_guest_data_title =>
      'Remplacer les données d\'invité ?';

  @override
  String get auth_replace_guest_data_message =>
      'La connexion à un compte existant remplacera les données actuellement stockées sur cet appareil par celles associées à votre compte. Vos données d\'invité pourraient être définitivement perdues et ne pourront pas être récupérées à moins d\'avoir une sauvegarde. Assurez-vous de comprendre ces conséquences avant de continuer.';

  @override
  String get auth_replace_guest_data_confirm => 'Continuer';

  @override
  String get auth_replace_guest_data_cancel => 'Annuler';

  @override
  String get auth_guest_mode_title => 'Mode invité';

  @override
  String get auth_guest_mode_subtitle =>
      'Vous utilisez Shiftly en mode invité. Vos données sont enregistrées localement sur cet appareil. Créez un compte pour synchroniser vos appareils ou connectez-vous à un compte existant.';

  @override
  String get auth_guest_migration_failed =>
      'Échec de la récupération des données du compte. Vos données d\'invité ont été préservées.';

  @override
  String get auth_register_guest_transfer =>
      'Se connecter ou créer un compte Shiftly';

  @override
  String get auth_user_deleted_local_data_preserved =>
      'Votre compte n\'existe plus dans la base de données. Vous avez été déconnecté, mais vos données locales restent enregistrées sur cet appareil.';

  @override
  String get home_welcome_back => 'Bonjour, [[name]]';

  @override
  String get settings_user_name => 'Nom';

  @override
  String get settings_user_email => 'E-mail';

  @override
  String get settings_user_password => 'Mot de passe';

  @override
  String get settings_user_edit_title => 'Modifier le profil';

  @override
  String get settings_user_update_success => 'Profil mis à jour avec succès';

  @override
  String get settings_logout_success => 'Déconnexion réussie';

  @override
  String get settings_byos_title => 'Synchronisation BYOS';

  @override
  String get settings_byos_connected => 'Connecté à Google Drive';

  @override
  String get settings_byos_last_backup => 'Dernière sauvegarde : [[time]]';

  @override
  String get settings_byos_backup_now => 'Sauvegarder maintenant';

  @override
  String get settings_byos_auto_sync => 'Synchronisation automatique';

  @override
  String get settings_byos_auto_sync_sub =>
      'Sauvegarder instantanément les modifications dans le cloud';

  @override
  String get settings_byos_disconnect => 'Déconnecter';

  @override
  String get settings_byos_login_shiftly => 'Se connecter au compte Shiftly';

  @override
  String get settings_byos_login_shiftly_sub =>
      'Synchronisation complète dans notre cloud';

  @override
  String get settings_byos_method_title => 'Méthode BYOS (Google Drive)';

  @override
  String get settings_byos_method_sub => 'Sauvegarder dans votre cloud privé';

  @override
  String get settings_byos_restore_dialog_title => 'Synchronisation BYOS';

  @override
  String get settings_byos_restore_dialog_content =>
      'Souhaitez-vous restaurer les données existantes depuis votre Google Drive ?';

  @override
  String get settings_byos_restore_confirm => 'Restaurer';

  @override
  String get settings_byos_restore_cancel => 'Pas maintenant';

  @override
  String get settings_byos_login_hint =>
      'Connectez-vous pour sauvegarder vos données dans le cloud et utiliser d\'autres appareils';

  @override
  String get settings_restore_success =>
      'Restauration réussie : [[shifts]] quarts et [[jobs]] postes restaurés.';

  @override
  String get settings_restore_no_data =>
      'Aucune sauvegarde trouvée sur Google Drive ou une erreur s\'est produite.';

  @override
  String get export_title => 'Exporter les quarts';

  @override
  String get export_format_label => 'Format de fichier';

  @override
  String get export_format_csv => 'CSV (Compatible Excel)';

  @override
  String get export_format_txt => 'Fichier texte (TXT)';

  @override
  String get export_format_json => 'Sauvegarde JSON (.json)';

  @override
  String get export_range_label => 'Plage d\'exportation';

  @override
  String get export_range_all => 'Tous les quarts';

  @override
  String get export_range_month => 'Mois spécifique';

  @override
  String get export_range_custom => 'Plage de dates personnalisée';

  @override
  String get export_start_date => 'Date de début';

  @override
  String get export_end_date => 'Date de fin';

  @override
  String get export_select_month => 'Sélectionner le mois';

  @override
  String get export_button => 'Exporter le fichier';

  @override
  String get export_success_msg =>
      'Fichier exporté avec succès et enregistré à :';

  @override
  String get export_empty_error =>
      'Aucun quart trouvé dans la plage sélectionnée pour l\'exportation';

  @override
  String get analytics_title => 'Analyses et aperçus';

  @override
  String get analytics_hero_greeting => 'Aperçu financier';

  @override
  String get analytics_hero_subtitle =>
      'Vos performances financières et vos habitudes de travail en un coup d\'œil';

  @override
  String get analytics_section_overview => 'Vue d\'ensemble';

  @override
  String get analytics_section_earnings => 'Gains';

  @override
  String get analytics_section_work_patterns => 'Habitudes de travail';

  @override
  String get analytics_section_pay_breakdown => 'Répartition de la paie';

  @override
  String get analytics_period_monthly => 'Mensuel';

  @override
  String get analytics_period_yearly => 'Annuel';

  @override
  String get analytics_period_all_time => 'Tout le temps';

  @override
  String get analytics_all_jobs => 'Tous les postes';

  @override
  String get analytics_stat_total_net => 'Net total';

  @override
  String get analytics_stat_total_hours => 'Total des heures';

  @override
  String get analytics_stat_avg_rate => 'Taux effectif moyen';

  @override
  String get analytics_stat_tips => 'Dépenses de quart nettes';

  @override
  String get analytics_chart_earnings_title =>
      'Gains par rapport aux dépenses au fil du temps';

  @override
  String get analytics_chart_earnings_subtitle =>
      'Appuyez sur une barre pour voir la répartition de la paie et des dépenses';

  @override
  String get analytics_chart_jobs_title => 'Répartition par poste';

  @override
  String get analytics_chart_jobs_by_earnings => 'Par gains';

  @override
  String get analytics_chart_jobs_by_hours => 'Par heures';

  @override
  String get analytics_no_data => 'Aucune donnée pour la période sélectionnée';

  @override
  String get analytics_selected_breakdown => 'Détails du jour sélectionné';

  @override
  String get analytics_selected_month_breakdown =>
      'Détails du mois sélectionné';

  @override
  String get analytics_base_salary => 'Salaire de base';

  @override
  String get analytics_chart_cumulative_title =>
      'Croissance cumulative des gains';

  @override
  String get analytics_chart_cumulative_subtitle =>
      'Faites défiler horizontalement pour afficher la croissance de la paie au fil du temps';

  @override
  String get analytics_gross_pay => 'Brut';

  @override
  String get analytics_net_pay => 'Net';

  @override
  String get analytics_kpi_projected => 'Paie de fin de mois projetée';

  @override
  String get analytics_kpi_retention => 'Taux de rétention net';

  @override
  String get analytics_chart_tod_title =>
      'Répartition par moment de la journée';

  @override
  String get analytics_chart_tod_subtitle =>
      'Comparaison des heures selon les segments de la journée';

  @override
  String get analytics_chart_tod_dawn => 'Aube';

  @override
  String get analytics_chart_tod_morning => 'Matin';

  @override
  String get analytics_chart_tod_noon => 'Midi';

  @override
  String get analytics_chart_tod_afternoon => 'Après-midi';

  @override
  String get analytics_chart_tod_evening => 'Soirée';

  @override
  String get analytics_chart_tod_night => 'Nuit';

  @override
  String get analytics_chart_duration_title =>
      'Répartition de la durée des quarts et de la fatigue';

  @override
  String get analytics_chart_duration_subtitle =>
      'Distribution de la durée des quarts (court, standard, long)';

  @override
  String get analytics_duration_short => 'Court';

  @override
  String get analytics_duration_standard => 'Standard';

  @override
  String get analytics_duration_long => 'Long';

  @override
  String get analytics_insights_title => 'Aperçus intelligents clés';

  @override
  String get analytics_insight_night_boost =>
      'Les quarts de soirée et de nuit représentent [[percent]]% de vos heures de travail.';

  @override
  String get analytics_insight_retention =>
      'Vous conservez [[percent]]% des gains bruts après les dépenses de quart.';

  @override
  String get analytics_insight_fatigue =>
      '[[percent]]% de vos quarts ont duré plus de 9 heures.';

  @override
  String get analytics_insight_tips_ratio =>
      'Les dépenses récurrentes représentent [[percent]]% de vos gains totaux.';

  @override
  String analytics_shifts_format(Object count) {
    return '$count quarts';
  }

  @override
  String get analytics_no_shift_data_period =>
      'Aucune donnée de quart pour cette période';

  @override
  String get analytics_min_shifts_hourly =>
      'Au moins 2 quarts requis pour afficher la tendance du salaire horaire';

  @override
  String get analytics_min_shifts_growth =>
      'Au moins 2 quarts requis pour afficher la croissance cumulative';

  @override
  String get analytics_min_shifts_retention =>
      'Au moins 2 quarts requis pour afficher la tendance de la rétention nette';

  @override
  String get analytics_no_job_data => 'Aucune donnée de poste';

  @override
  String analytics_hours_suffix_format(Object hours) {
    return '$hours h';
  }

  @override
  String analytics_utilization_format(Object pct) {
    return '$pct% d\'utilisation';
  }

  @override
  String get common_previous => 'Précédent';

  @override
  String get common_next => 'Suivant';

  @override
  String get analytics_tips_and_extra => 'Pourboires et extras';

  @override
  String analytics_rate_boost_subtitle(Object boost) {
    return '+$boost/h d\'extras nets';
  }

  @override
  String get analytics_retention_subtitle =>
      'Conservé après les dépenses de quart';

  @override
  String analytics_net_extras_pct_subtitle(Object percent) {
    return '$percent% du salaire net total';
  }

  @override
  String get common_unknown_job => 'Poste inconnu';

  @override
  String get analytics_duration_range_short => '< 6 heures';

  @override
  String get analytics_duration_range_standard => '6-9 heures';

  @override
  String get analytics_duration_range_long => '> 9 heures';

  @override
  String get profile_title => 'Profil utilisateur';

  @override
  String get profile_created_at => 'Compte créé le : [[date]]';

  @override
  String get profile_birth_date_display =>
      'Date de naissance : [[date]] (Âge : [[age]])';

  @override
  String get profile_stats_title => 'Résumé des données enregistrées';

  @override
  String get profile_shifts_count => 'Quarts enregistrés';

  @override
  String get profile_jobs_count => 'Rôles / Types de postes';

  @override
  String get profile_expenses_count => 'Dépenses enregistrées';

  @override
  String get profile_incomes_count => 'Revenus enregistrés';

  @override
  String get side_menu_profile => 'Profil utilisateur';

  @override
  String get profile_old_password => 'Mot de passe actuel';

  @override
  String get profile_new_password => 'Nouveau mot de passe';

  @override
  String get profile_password_error => 'Le mot de passe actuel est incorrect';

  @override
  String get profile_password_required =>
      'Veuillez entrer votre mot de passe actuel';

  @override
  String get shift_descriptions_title => 'Résumés de quarts';

  @override
  String get shift_descriptions_empty => 'Aucun résumé de quart trouvé';

  @override
  String get shift_description_label => 'Résumé / Description du quart';

  @override
  String get shift_description_hint =>
      'Entrez des notes ou un résumé pour ce quart...';

  @override
  String get shift_descriptions_delete_title => 'Supprimer la description';

  @override
  String get shift_descriptions_delete_content =>
      'Voulez-vous vraiment supprimer la description de ce quart ?';

  @override
  String get shift_descriptions_deleted_msg =>
      'Description supprimée avec succès';

  @override
  String get shift_descriptions_edit_title => 'Modifier la description';

  @override
  String get shift_descriptions_updated_msg =>
      'Description mise à jour avec succès';

  @override
  String get common_search_by_date => 'Rechercher par date';

  @override
  String get common_clear_date_filter => 'Effacer le filtre de date';

  @override
  String get common_filter_date => 'Filtrer par date';

  @override
  String get profile_delete_account => 'Supprimer le compte';

  @override
  String get profile_delete_account_sub =>
      'Supprimer définitivement votre compte utilisateur Shiftly';

  @override
  String get profile_delete_dialog_title => 'Supprimer le compte';

  @override
  String get profile_delete_dialog_content =>
      'Voulez-vous vraiment supprimer votre compte Shiftly ? Cette action est irréversible.';

  @override
  String get profile_delete_final_title => 'Confirmation finale';

  @override
  String get profile_delete_final_content_1 =>
      'Votre compte utilisateur et toutes les données du serveur seront définitivement supprimés.';

  @override
  String get profile_delete_final_content_2 =>
      'Cette action est irréversible. Procéder à la suppression du compte ?';

  @override
  String get profile_delete_success => 'Compte supprimé avec succès';

  @override
  String get settings_byos_delete_title => 'Supprimer la sauvegarde BYOS';

  @override
  String get settings_byos_delete_sub =>
      'Effacer définitivement le fichier de sauvegarde de Google Drive';

  @override
  String get settings_byos_delete_dialog_title => 'Supprimer les données BYOS';

  @override
  String get settings_byos_delete_dialog_content =>
      'Voulez-vous vraiment supprimer vos données de sauvegarde de Google Drive ?';

  @override
  String get settings_byos_delete_final_title => 'Dernier avertissement';

  @override
  String get settings_byos_delete_final_content_1 =>
      'Votre fichier de sauvegarde dans Google Drive sera complètement détruit.';

  @override
  String get settings_byos_delete_final_content_2 =>
      'Voulez-vous vraiment supprimer définitivement les données de sauvegarde BYOS ?';

  @override
  String get settings_byos_delete_success =>
      'Données de sauvegarde BYOS supprimées avec succès';

  @override
  String get add_shift_wage_segments_title =>
      'Segments de pourcentage du salaire horaire (Facultatif)';

  @override
  String get add_shift_wage_segments_subtitle =>
      'Définir des périodes avec différents pourcentages de salaire (ex. 150%)';

  @override
  String get add_shift_wage_segments_add => 'Ajouter une période';

  @override
  String get add_shift_wage_segment_start => 'Début';

  @override
  String get add_shift_wage_segment_end => 'Fin';

  @override
  String get add_shift_wage_segment_percentage => '% de salaire';

  @override
  String get error_segment_invalid_time =>
      'L\'heure de fin du segment doit être postérieure à l\'heure de début';

  @override
  String get error_segment_overlap =>
      'Il y a un chevauchement dans les plages horaires';

  @override
  String get legal_privacy_policy => 'Politique de confidentialité';

  @override
  String get legal_terms_of_service => 'Conditions d\'utilisation';

  @override
  String get legal_disclaimer_notice =>
      'En vous inscrivant ou en vous connectant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get legal_cookie_title =>
      'Préférences de cookies et de confidentialité';

  @override
  String get legal_cookie_description =>
      'Nous utilisons des technologies de stockage local et des cookies pour l\'authentification essentielle, la sécurité et la télémétrie des plantages de l\'application. Vous pouvez choisir de tout accepter ou d\'utiliser uniquement les cookies nécessaires.';

  @override
  String get legal_cookie_accept_all => 'Tout accepter';

  @override
  String get legal_cookie_necessary_only => 'Nécessaires uniquement';

  @override
  String get legal_cookie_necessary_desc =>
      'Essentiels pour l\'authentification, le stockage sécurisé des jetons et les préférences de session.';

  @override
  String get legal_cookie_analytics_desc =>
      'Journaux d\'erreurs anonymes et télémétrie des performances de plantage via Firebase.';

  @override
  String get legal_cookie_customize => 'Personnaliser';

  @override
  String get legal_cookie_save_preferences => 'Enregistrer les préférences';

  @override
  String get legal_cookie_essential => 'Cookies essentiels et de sécurité';

  @override
  String get legal_cookie_always_active => 'Toujours actif';

  @override
  String get legal_cookie_optional => 'Optionnel';

  @override
  String get common_close => 'Fermer';

  @override
  String get settings_section_overtime => 'Règles des heures supplémentaires';

  @override
  String get settings_overtime_enable =>
      'Activer le calcul des heures supplémentaires';

  @override
  String get settings_overtime_enable_sub =>
      'Calculer automatiquement la rémunération des heures supplémentaires par paliers';

  @override
  String get settings_overtime_regular_threshold =>
      'Seuil des heures normales (heures)';

  @override
  String get settings_overtime_tier1_limit =>
      'Durée du premier palier d\'heures sup (heures)';

  @override
  String get settings_overtime_tier1_rate =>
      'Multiplicateur du premier palier (%)';

  @override
  String get settings_overtime_tier2_rate =>
      'Multiplicateur du palier supplémentaire (%)';

  @override
  String get settings_overtime_update_button =>
      'Enregistrer les règles d\'heures sup';

  @override
  String get settings_overtime_saved =>
      'Règles des heures supplémentaires mises à jour avec succès';

  @override
  String get overtime_notification_detected =>
      'Le quart inclut des heures supplémentaires. Le salaire a été calculé selon les taux d\'heures sup.';

  @override
  String get overtime_breakdown_title => 'Répartition du salaire';

  @override
  String get overtime_regular_hours_label => 'Heures normales';

  @override
  String get overtime_tier1_label => 'Heures sup (125%)';

  @override
  String get overtime_tier2_label => 'Heures sup (150%)';

  @override
  String get overtime_tier_custom_label => 'Heures sup ([[rate]]%)';

  @override
  String get overtime_tag_label => 'Heures sup';

  @override
  String get overtime_total_paid_time => 'Temps payé total';

  @override
  String get overtime_total_earnings => 'Gains totaux du quart';

  @override
  String get overtime_unpaid_break => 'Pause non payée';

  @override
  String get analytics_overtime_section_title =>
      'Résumé et heures des heures sup';

  @override
  String get analytics_regular_hours => 'Heures normales';

  @override
  String get analytics_overtime_hours => 'Heures supplémentaires';

  @override
  String get analytics_overtime_earnings => 'Gains des heures sup';

  @override
  String get shabbat_tag_label => 'Shabbat';

  @override
  String get holiday_tag_label => 'Jour férié';

  @override
  String get settings_shabbat_section => 'Shabbat et jours fériés';

  @override
  String get settings_shabbat_enable =>
      'Calcul automatique Shabbat et jours fériés';

  @override
  String get settings_shabbat_enable_sub =>
      'Détection automatique de Shabbat, des jours fériés et des taux spéciaux';

  @override
  String get settings_shabbat_multiplier_label => 'Taux Shabbat (%)';

  @override
  String get settings_holiday_multiplier_label => 'Taux jour férié (%)';

  @override
  String get settings_candle_lighting_label =>
      'Allumage des bougies (minutes avant le coucher du soleil)';

  @override
  String get settings_shabbat_exit_label =>
      'Sortie de Shabbat (minutes après le coucher du soleil)';

  @override
  String get settings_shabbat_saved =>
      'Paramètres Shabbat et jours fériés enregistrés avec succès';

  @override
  String get settings_shabbat_save_button =>
      'Enregistrer les paramètres Shabbat et jours fériés';

  @override
  String get analytics_shabbat_holiday_summary =>
      'Résumé Shabbat et jours fériés';

  @override
  String get analytics_shabbat_hours => 'Heures de Shabbat';

  @override
  String get analytics_holiday_hours => 'Heures de jours fériés';

  @override
  String get onboarding_shabbat_title => 'Shabbat et fêtes juives';

  @override
  String get onboarding_shabbat_subtitle =>
      'Détection automatique de Shabbat, des jours fériés et des taux spéciaux';

  @override
  String add_shift_unknown_job_title(Object trailingText) {
    return 'Type de quart non reconnu : \"$trailingText\"';
  }

  @override
  String get add_shift_unknown_job_desc =>
      'Un type de poste qui n\'existe pas dans votre liste a été trouvé. Choisissez un type de poste alternatif ou enregistrez comme description :';

  @override
  String get add_shift_select_job_label => 'Sélectionner le type de poste';

  @override
  String get add_shift_apply_all_instances =>
      'Appliquer automatiquement à toutes les occurrences de ce type';

  @override
  String get add_shift_skip => 'Ignorer';

  @override
  String get add_shift_save_as_desc =>
      'Enregistrer comme description uniquement';

  @override
  String get add_shift_assign => 'Attribuer';

  @override
  String add_shift_shabbat_breakdown(Object rate) {
    return 'Shabbat ($rate%)';
  }

  @override
  String add_shift_holiday_breakdown(Object name, Object rate) {
    return '$name ($rate%)';
  }

  @override
  String get settings_update_section => 'Mises à jour de l\'application';

  @override
  String get settings_update_check_button =>
      'Vérifier les mises à jour sur GitHub';

  @override
  String settings_update_current_version(String version) {
    return 'Version actuelle : v$version';
  }

  @override
  String get settings_update_checking_toast =>
      'Vérification des mises à jour sur GitHub Releases...';

  @override
  String get settings_update_error_toast =>
      'Impossible de se connecter à GitHub. Veuillez réessayer plus tard.';

  @override
  String settings_update_latest_toast(String version) {
    return 'L\'application est à jour ! (v$version)';
  }

  @override
  String get update_dialog_title => 'Nouvelle version disponible !';

  @override
  String update_dialog_version_available(String version) {
    return 'La version $version est disponible au téléchargement';
  }

  @override
  String update_dialog_installed_version(String version) {
    return 'Version installée : $version';
  }

  @override
  String update_dialog_new_version(String version) {
    return 'Nouveau : $version';
  }

  @override
  String get update_dialog_whats_new => 'Nouveautés de cette version :';

  @override
  String get update_dialog_downloading =>
      'Téléchargement du fichier de mise à jour...';

  @override
  String get update_dialog_later => 'Plus tard';

  @override
  String get update_dialog_open_browser => 'Ouvrir dans le navigateur';

  @override
  String get update_dialog_update_now => 'Mettre à jour maintenant';

  @override
  String get update_dialog_open_download => 'Ouvrir la page de téléchargement';

  @override
  String get update_dialog_mandatory_notice =>
      'Cette mise à jour est requise pour continuer à utiliser l\'application.';

  @override
  String get update_service_no_changelog =>
      'Aucun détail de journal des modifications disponible.';

  @override
  String update_service_download_failed(Object statusCode) {
    return 'Échec du téléchargement du fichier (Code d\'erreur : $statusCode)';
  }

  @override
  String get update_service_no_installer =>
      'Aucune application trouvée pour installer les fichiers APK sur l\'appareil. Essayez d\'ouvrir dans le navigateur.';

  @override
  String update_service_cannot_launch_installer(String message) {
    return 'Impossible de lancer le programme d\'installation du paquet ($message)';
  }

  @override
  String update_service_download_error(Object error) {
    return 'Erreur lors du téléchargement de la mise à jour : $error';
  }

  @override
  String get common_show_password => 'Afficher le mot de passe';

  @override
  String get common_hide_password => 'Masquer le mot de passe';

  @override
  String get accessibility_statement => 'Déclaration d\'accessibilité';

  @override
  String get settings_accessibility_sub =>
      'Informations d\'accessibilité et coordonnées';

  @override
  String get all_shifts_title => 'Tous les quarts';

  @override
  String get export_format_excel => 'Feuille Excel (.xlsx)';

  @override
  String get export_format_pdf => 'Document PDF (.pdf)';

  @override
  String get export_include_analytics => 'Inclure les analyses et résumés';

  @override
  String get export_include_analytics_sub =>
      'Ajouter des graphiques et un aperçu des statistiques au rapport';

  @override
  String get import_title => 'Importer des quarts';

  @override
  String get import_button => 'Importer un fichier (.xlsx, .csv, .json)';

  @override
  String get import_paste_or_pick => 'Choisir un fichier ou coller le contenu';

  @override
  String get import_preview_title => 'Aperçu de l\'importation';

  @override
  String import_found_shifts(int count) {
    return '$count quarts valides trouvés à importer';
  }

  @override
  String import_confirm_button(int count) {
    return 'Importer $count quarts';
  }

  @override
  String import_success_msg(int count) {
    return '$count quarts importés avec succès !';
  }

  @override
  String get import_error_msg =>
      'Échec de l\'importation des quarts ou format non pris en charge';

  @override
  String get pdf_report_title => 'Shiftly - Rapport de travail et de salaire';

  @override
  String get pdf_detailed_log => 'Historique détaillé des quarts';

  @override
  String get pdf_analytics_summary => 'Analyses et résumé';

  @override
  String get pdf_total_net_pay => 'Salaire net total';

  @override
  String get pdf_total_hours => 'Total des heures nettes';

  @override
  String get pdf_avg_rate => 'Taux effectif moyen';

  @override
  String get pdf_shifts_count => 'Nombre de quarts';

  @override
  String get pdf_total_base => 'Salaire de base';

  @override
  String get pdf_total_tips => 'Pourboires';

  @override
  String get pdf_total_expenses => 'Dépenses';

  @override
  String get pdf_total_incomes => 'Revenus';

  @override
  String get pdf_col_date => 'Date';

  @override
  String get pdf_col_job => 'Poste';

  @override
  String get pdf_col_time => 'Heures';

  @override
  String get pdf_col_start_time => 'Heure de début';

  @override
  String get pdf_col_end_time => 'Heure de fin';

  @override
  String get pdf_col_tags => 'Tags';

  @override
  String get pdf_col_net_hours => 'H. nettes';

  @override
  String get pdf_col_hourly_rate => 'Taux';

  @override
  String get pdf_col_base => 'Base';

  @override
  String get pdf_col_overtime => 'Heures sup';

  @override
  String get pdf_col_shabbat => 'Shabbat';

  @override
  String get pdf_col_tips => 'Pourboires';

  @override
  String get pdf_col_extras => 'Extras';

  @override
  String get pdf_col_net_pay => 'Net total';

  @override
  String get pdf_col_notes => 'Notes';

  @override
  String get excel_sheet_shifts => 'Détails des quarts';

  @override
  String get excel_sheet_analytics => 'Résumé des analyses';

  @override
  String report_generated_label(String date) {
    return 'Généré le : $date';
  }

  @override
  String report_total_shifts_label(int count) {
    return 'Total des quarts : $count';
  }

  @override
  String get report_category_label => 'Catégorie';

  @override
  String get report_rate_multiplier_label => 'Multiplicateur de taux';

  @override
  String get report_hours_label => 'Heures';

  @override
  String get report_earnings_label => 'Gains';

  @override
  String get report_regular_hours => 'Heures normales (100%)';

  @override
  String get report_overtime_125 => 'Heures sup palier 1 (125%)';

  @override
  String get report_overtime_150 => 'Heures sup palier 2 (150%)';

  @override
  String get report_shabbat_hours => 'Heures de Shabbat';

  @override
  String get report_holiday_hours => 'Heures de jours fériés';

  @override
  String get report_disabled_status => '(Désactivé dans les paramètres)';

  @override
  String get report_job_distribution => 'Répartition par type de poste';

  @override
  String get report_job_name => 'Nom du poste';

  @override
  String get report_pct_net_pay => '% du salaire net';

  @override
  String get report_totals_row => 'TOTAUX';

  @override
  String get report_tag_overtime => 'Heures sup';

  @override
  String get report_tag_shabbat => 'Shabbat';

  @override
  String get report_tag_holiday => 'Jour férié';

  @override
  String report_page_number(Object current, Object total) {
    return 'Page $current sur $total';
  }

  @override
  String pdf_col_hourly_rate_symbol(String symbol) {
    return 'Taux horaire ($symbol)';
  }

  @override
  String pdf_col_base_symbol(String symbol) {
    return 'Salaire de base ($symbol)';
  }

  @override
  String report_overtime_125_symbol(String symbol) {
    return 'Heures sup 125% ($symbol)';
  }

  @override
  String report_overtime_150_symbol(String symbol) {
    return 'Heures sup 150% ($symbol)';
  }

  @override
  String pdf_col_shabbat_symbol(String symbol) {
    return 'Shabbat / Férié ($symbol)';
  }

  @override
  String pdf_col_tips_symbol(String symbol) {
    return 'Pourboires ($symbol)';
  }

  @override
  String pdf_total_incomes_symbol(String symbol) {
    return 'Revenus auto ($symbol)';
  }

  @override
  String pdf_total_expenses_symbol(String symbol) {
    return 'Dépenses auto ($symbol)';
  }

  @override
  String pdf_col_net_pay_symbol(String symbol) {
    return 'Salaire net total ($symbol)';
  }

  @override
  String get shift_template_title => 'Modèles de quarts';

  @override
  String get shift_template_subtitle =>
      'Modèles rapides pour ajouter des quarts rapidement et facilement.';

  @override
  String get shift_template_morning => 'Quart du matin';

  @override
  String get shift_template_evening => 'Quart du soir';

  @override
  String get shift_template_night => 'Quart de nuit';

  @override
  String get shift_template_add_button => 'Ajouter un modèle';

  @override
  String get shift_template_save_current => 'Enregistrer comme modèle';

  @override
  String get shift_template_applied_snack => 'Modèle appliqué';

  @override
  String get shift_template_saved_snack => 'Modèle enregistré avec succès';

  @override
  String get shift_template_deleted_snack => 'Modèle supprimé';

  @override
  String get shift_template_delete_confirm_title => 'Supprimer le modèle';

  @override
  String get shift_template_delete_confirm_content =>
      'Voulez-vous vraiment supprimer ce modèle ?';

  @override
  String get shift_template_name_label => 'Nom du modèle';

  @override
  String get shift_template_select_prompt => 'Modèles de quarts rapides';

  @override
  String get shift_template_manage => 'Gérer les modèles';

  @override
  String get shift_template_empty =>
      'Aucun modèle de quart enregistré pour l\'instant';

  @override
  String get shift_template_edit_title => 'Modifier le modèle';

  @override
  String get shift_template_new_title => 'Nouveau modèle de quart';

  @override
  String get expenses_type_income => 'revenu';

  @override
  String get expenses_type_expense => 'dépense';
}
