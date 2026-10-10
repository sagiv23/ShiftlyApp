import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRestoring = false;
  bool _isBackingUp = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final shiftProvider = context.watch<ShiftProvider>();

    final shiftsCount = shiftProvider.shifts.length;
    final jobsCount = shiftProvider.jobTypes.length;
    final expensesCount = shiftProvider.expenses.length;
    final incomesCount = shiftProvider.incomes.length;
    final descriptionsCount = shiftProvider.shifts
        .where((s) => s.description != null && s.description!.trim().isNotEmpty)
        .length;

    final statRows = <Widget>[];
    if (shiftsCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.access_time_filled_rounded,
          label: l.profile_shifts_count,
          value: shiftsCount.toString(),
          color: AppTheme.primary,
        ),
      );
    }
    if (jobsCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.badge_rounded,
          label: l.profile_jobs_count,
          value: jobsCount.toString(),
          color: Colors.orange,
        ),
      );
    }
    if (expensesCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.receipt_long_rounded,
          label: l.profile_expenses_count,
          value: expensesCount.toString(),
          color: AppTheme.expense,
        ),
      );
    }
    if (incomesCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.account_balance_wallet_rounded,
          label: l.profile_incomes_count,
          value: incomesCount.toString(),
          color: AppTheme.profit,
        ),
      );
    }
    if (descriptionsCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.note_alt_rounded,
          label: l.shift_descriptions_title,
          value: descriptionsCount.toString(),
          color: Colors.purple,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.profile_title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            // User Shiftly Account Card
            PageEntranceAnimation(
              delayFraction: 0.0,
              child: auth.isLoggedIn
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spaceMd),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                (auth.userName?.isNotEmpty == true
                                        ? auth.userName![0]
                                        : (auth.userEmail?.isNotEmpty == true
                                              ? auth.userEmail![0]
                                              : 'U'))
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              auth.userName ?? l.settings_user_name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.userEmail ?? '',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            if (auth.userCreatedAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                l.profile_created_at.replaceAll(
                                  '[[date]]',
                                  DateFormat('dd/MM/yyyy').format(
                                    DateTime.tryParse(auth.userCreatedAt!) ??
                                        DateTime.now(),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                            if (auth.userBirthDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                l.profile_birth_date_display
                                    .replaceAll(
                                      '[[date]]',
                                      DateFormat('dd/MM/yyyy').format(
                                        DateTime.tryParse(
                                              auth.userBirthDate!,
                                            ) ??
                                            DateTime.now(),
                                      ),
                                    )
                                    .replaceAll(
                                      '[[age]]',
                                      auth.userAge?.toString() ?? '',
                                    ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showEditProfileDialog(context),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: Text(l.settings_user_edit_title),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _handleLogout(context),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 18,
                                  ),
                                  label: Text(l.settings_logout_title),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.person_add_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                        title: Text(
                          l.settings_byos_login_shiftly,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(l.settings_byos_login_shiftly_sub),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.push(
                          context,
                          AppPageRoute.slideUp(const AuthScreen()),
                        ),
                      ),
                    ),
            ),
            if (statRows.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceLg),
              // Statistics Summary Card
              PageEntranceAnimation(
                delayFraction: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.profile_stats_title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spaceMd),
                        child: Column(
                          children: [
                            for (int i = 0; i < statRows.length; i++) ...[
                              if (i > 0) const Divider(height: 24),
                              statRows[i],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            // BYOS Section
            PageEntranceAnimation(
              delayFraction: 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, l.settings_byos_title),
                  const SizedBox(height: AppTheme.spaceXs),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceSm),
                      child: Column(
                        children: [
                          if (auth.isByosConnected) ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.cloud_done_rounded,
                                color: Colors.green,
                              ),
                              title: Text(l.settings_byos_connected),
                              subtitle: Text(auth.byosEmail ?? ''),
                              trailing: TextButton(
                                onPressed: () => context
                                    .read<AuthProvider>()
                                    .disconnectBYOS(),
                                child: Text(l.settings_byos_disconnect),
                              ),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                l.settings_byos_auto_sync,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                l.settings_byos_auto_sync_sub,
                                style: const TextStyle(fontSize: 12),
                              ),
                              value: settings.autoSyncEnabled,
                              onChanged: (val) =>
                                  settings.setAutoSyncEnabled(val),
                            ),
                            if (shiftProvider.lastBackupTime != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.settings_byos_last_backup.replaceFirst(
                                        '[[time]]',
                                        DateFormat(
                                          'dd/MM/yyyy HH:mm:ss',
                                        ).format(shiftProvider.lastBackupTime!),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _isBackingUp
                                      ? null
                                      : () async {
                                          setState(() => _isBackingUp = true);
                                          try {
                                            final success = await shiftProvider
                                                .manualBackup();
                                            if (context.mounted) {
                                              if (success) {
                                                UIUtils.showSnackBar(
                                                  context,
                                                  l.common_success,
                                                );
                                              } else {
                                                UIUtils.showSnackBar(
                                                  context,
                                                  l.common_error,
                                                  isError: true,
                                                );
                                              }
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              setState(
                                                () => _isBackingUp = false,
                                              );
                                            }
                                          }
                                        },
                                  icon: _isBackingUp
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 16,
                                        ),
                                  label: Text(
                                    l.settings_byos_backup_now,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _isRestoring
                                      ? null
                                      : () async {
                                          final confirmed = await UIUtils.showConfirmDialog(
                                            context: context,
                                            title: l
                                                .settings_byos_restore_dialog_title,
                                            content: l
                                                .settings_byos_restore_dialog_content,
                                            confirmLabel:
                                                l.settings_byos_restore_confirm,
                                            cancelLabel:
                                                l.settings_byos_restore_cancel,
                                          );
                                          if (confirmed == true &&
                                              context.mounted) {
                                            setState(() => _isRestoring = true);
                                            try {
                                              final results =
                                                  await shiftProvider
                                                      .restoreFromBYOS();
                                              if (context.mounted) {
                                                if (results['shifts']! > 0 ||
                                                    results['jobs']! > 0 ||
                                                    results['expenses']! > 0) {
                                                  UIUtils.showSnackBar(
                                                    context,
                                                    l.settings_restore_success
                                                        .replaceFirst(
                                                          '[[shifts]]',
                                                          results['shifts']
                                                              .toString(),
                                                        )
                                                        .replaceFirst(
                                                          '[[jobs]]',
                                                          results['jobs']
                                                              .toString(),
                                                        ),
                                                  );
                                                } else {
                                                  UIUtils.showSnackBar(
                                                    context,
                                                    l.settings_restore_no_data,
                                                    isError: true,
                                                  );
                                                }
                                              }
                                            } finally {
                                              if (context.mounted) {
                                                setState(
                                                  () => _isRestoring = false,
                                                );
                                              }
                                            }
                                          }
                                        },
                                  icon: _isRestoring
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.cloud_download_outlined,
                                          size: 16,
                                        ),
                                  label: Text(
                                    l.settings_byos_restore_confirm,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.storage_rounded,
                                color: Colors.orange,
                              ),
                              title: Text(l.settings_byos_method_title),
                              subtitle: Text(l.settings_byos_method_sub),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  await auth.connectBYOS();
                                  if (context.mounted && auth.isByosConnected) {
                                    final confirmed = await UIUtils.showConfirmDialog(
                                      context: context,
                                      title:
                                          l.settings_byos_restore_dialog_title,
                                      content: l
                                          .settings_byos_restore_dialog_content,
                                      confirmLabel:
                                          l.settings_byos_restore_confirm,
                                      cancelLabel:
                                          l.settings_byos_restore_cancel,
                                    );
                                    if (confirmed == true && context.mounted) {
                                      final results = await shiftProvider
                                          .restoreFromBYOS();
                                      if (context.mounted) {
                                        if (results['shifts']! > 0 ||
                                            results['jobs']! > 0 ||
                                            results['expenses']! > 0) {
                                          UIUtils.showSnackBar(
                                            context,
                                            l.settings_restore_success
                                                .replaceFirst(
                                                  '[[shifts]]',
                                                  results['shifts'].toString(),
                                                )
                                                .replaceFirst(
                                                  '[[jobs]]',
                                                  results['jobs'].toString(),
                                                ),
                                          );
                                        } else {
                                          UIUtils.showSnackBar(
                                            context,
                                            l.settings_restore_no_data,
                                            isError: true,
                                          );
                                        }
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  l.settings_byos_disconnect.replaceFirst(
                                    'נתק',
                                    'חבר',
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.expense,
                            ),
                            title: Text(
                              l.settings_byos_delete_title,
                              style: const TextStyle(
                                color: AppTheme.expense,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              l.settings_byos_delete_sub,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () => _handleDeleteBYOS(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (auth.isLoggedIn) ...[
              const SizedBox(height: AppTheme.spaceLg),
              PageEntranceAnimation(
                delayFraction: 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, l.settings_section_danger),
                    const SizedBox(height: AppTheme.spaceXs),
                    Card(
                      child: ScalePress(
                        onTap: () => _handleDeleteAccount(context),
                        child: ListTile(
                          title: Text(
                            l.profile_delete_account,
                            style: const TextStyle(
                              color: AppTheme.expense,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(l.profile_delete_account_sub),
                          leading: const Icon(
                            Icons.delete_forever_rounded,
                            color: AppTheme.expense,
                          ),
                          onTap: () => _handleDeleteAccount(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.settings_logout_dialog_title,
      content: l.settings_logout_confirm_content,
      confirmLabel: l.settings_logout_confirm_button,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        UIUtils.showSnackBar(context, l.settings_logout_success);
      }
    }
  }

  Future<void> _handleDeleteBYOS(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    // Step 1: First Confirmation
    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.settings_byos_delete_dialog_title,
      content: l.settings_byos_delete_dialog_content,
      confirmLabel: l.common_continue,
      isDestructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Step 2: Second Confirmation (Final Warning)
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.expense),
            const SizedBox(width: 8),
            Expanded(child: Text(l.settings_byos_delete_final_title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settings_byos_delete_final_content_1),
            const SizedBox(height: 16),
            Text(
              l.settings_byos_delete_final_content_2,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l.common_cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expense,
              foregroundColor: Colors.white,
            ),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;
    if (!context.mounted) return;

    final driveService = GoogleDriveService();
    await driveService.deleteBackup();
    if (context.mounted && context.read<AuthProvider>().isByosConnected) {
      await context.read<AuthProvider>().disconnectBYOS();
    }

    if (!context.mounted) return;

    UIUtils.showSnackBar(context, l.settings_byos_delete_success);
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.profile_delete_dialog_title,
      content: l.profile_delete_dialog_content,
      confirmLabel: l.common_continue,
      isDestructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.expense),
            const SizedBox(width: 8),
            Expanded(child: Text(l.profile_delete_final_title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.profile_delete_final_content_1),
            const SizedBox(height: 16),
            Text(
              l.profile_delete_final_content_2,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l.common_cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expense,
              foregroundColor: Colors.white,
            ),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;
    if (!context.mounted) return;

    await context.read<AuthProvider>().deleteAccount();

    if (!context.mounted) return;

    UIUtils.showSnackBar(context, l.profile_delete_success);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: auth.userName);
    final emailController = TextEditingController(text: auth.userEmail);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    DateTime? editBirthDate = auth.userBirthDate != null
        ? DateTime.tryParse(auth.userBirthDate!)
        : null;
    bool obscureOld = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l.settings_user_edit_title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l.settings_user_name,
                    hintText: l.settings_user_name,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: l.settings_user_email,
                    hintText: 'name@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await AppDatePicker.showBirthDatePicker(
                      context: context,
                      initialDate: editBirthDate,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        editBirthDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.auth_birth_date_label,
                      hintText: l.auth_birth_date_label,
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                      ),
                    ),
                    child: Text(
                      editBirthDate == null
                          ? l.auth_birth_date_label
                          : AppConstants.formatDate(editBirthDate),
                    ),
                  ),
                ),
                const Divider(height: 32),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l.settings_user_password,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(
                    labelText: l.profile_old_password,
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureOld
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureOld = !obscureOld;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureOld,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: l.profile_new_password,
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureNew,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editBirthDate != null) {
                  final now = DateTime.now();
                  int age = now.year - editBirthDate!.year;
                  if (now.month < editBirthDate!.month ||
                      (now.month == editBirthDate!.month &&
                          now.day < editBirthDate!.day)) {
                    age--;
                  }
                  if (age < 12) {
                    UIUtils.showSnackBar(
                      context,
                      l.auth_error_underage,
                      isError: true,
                    );
                    return;
                  }
                }

                try {
                  await context.read<AuthProvider>().updateProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    oldPassword: oldPasswordController.text.trim(),
                    newPassword: newPasswordController.text.trim(),
                    birthDate: editBirthDate,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    UIUtils.showSnackBar(
                      context,
                      l.settings_user_update_success,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final errKey = e
                        .toString()
                        .replaceAll('Exception: ', '')
                        .trim();
                    String msg = errKey;
                    if (errKey == 'profile_password_error') {
                      msg = l.profile_password_error;
                    } else if (errKey == 'profile_password_required') {
                      msg = l.profile_password_required;
                    }
                    UIUtils.showSnackBar(context, msg, isError: true);
                  }
                }
              },
              child: Text(l.common_save),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
