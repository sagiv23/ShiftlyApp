import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final shiftProvider = context.watch<ShiftProvider>();

    final shiftsCount = shiftProvider.shifts.length;
    final jobsCount = shiftProvider.jobTypes.length;
    final expensesCount = shiftProvider.expenses.length;
    final incomesCount = shiftProvider.incomes.length;

    return Scaffold(
      appBar: AppBar(title: Text(l.profile_title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primary,
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.userName ?? l.settings_user_name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l.settings_user_edit_title),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            // Statistics Summary Card
            Text(
              l.profile_stats_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.access_time_filled_rounded,
                      label: l.profile_shifts_count,
                      value: shiftsCount.toString(),
                      color: AppTheme.primary,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.badge_rounded,
                      label: l.profile_jobs_count,
                      value: jobsCount.toString(),
                      color: Colors.orange,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.receipt_long_rounded,
                      label: l.profile_expenses_count,
                      value: expensesCount.toString(),
                      color: AppTheme.expense,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: l.profile_incomes_count,
                      value: incomesCount.toString(),
                      color: AppTheme.profit,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l.settings_section_danger,
              style: Theme
                  .of(
                context,
              )
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
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
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    // Step 1: First Confirmation
    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.profile_delete_dialog_title,
      content: l.profile_delete_dialog_content,
      confirmLabel: l.common_continue,
      isDestructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Step 2: Second Confirmation (Final Warning)
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Row(
              children: [
                const Icon(
                    Icons.warning_amber_rounded, color: AppTheme.expense),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_user_edit_title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l.settings_user_name),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: l.settings_user_email),
                keyboardType: TextInputType.emailAddress,
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
                decoration: InputDecoration(labelText: l.profile_old_password),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: l.profile_new_password),
                obscureText: true,
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
              try {
                await context.read<AuthProvider>().updateProfile(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  oldPassword: oldPasswordController.text.trim(),
                  newPassword: newPasswordController.text.trim(),
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
