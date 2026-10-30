import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.profile_title)),
        body: const ProfileScreenSkeleton(),
      );
    }

    final auth = context.watch<AuthProvider>();
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
          color: AppTheme.electricCyan,
        ),
      );
    }
    if (jobsCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.badge_rounded,
          label: l.profile_jobs_count,
          value: jobsCount.toString(),
          color: AppTheme.warmAmber,
        ),
      );
    }
    if (expensesCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.receipt_long_rounded,
          label: l.profile_expenses_count,
          value: expensesCount.toString(),
          color: AppTheme.softCoral,
        ),
      );
    }
    if (incomesCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.account_balance_wallet_rounded,
          label: l.profile_incomes_count,
          value: incomesCount.toString(),
          color: AppTheme.mintGreen,
        ),
      );
    }
    if (descriptionsCount > 0) {
      statRows.add(
        _StatRow(
          icon: Icons.note_alt_rounded,
          label: l.shift_descriptions_title,
          value: descriptionsCount.toString(),
          color: AppTheme.neonViolet,
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.electricCyan.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: AppTheme.electricCyan,
                                child: Text(
                                  (auth.userName?.isNotEmpty == true
                                          ? auth.userName![0]
                                          : (auth.userEmail?.isNotEmpty == true
                                                ? auth.userEmail![0]
                                                : 'U'))
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFF040711),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              auth.userName ?? l.settings_user_name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.userEmail ?? '',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.secondaryText
                                    : Colors.grey.shade700,
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
                                  color: isDark
                                      ? AppTheme.mutedText
                                      : Colors.grey.shade600,
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
                                  color: isDark
                                      ? AppTheme.mutedText
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
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
                                    color: AppTheme.electricCyan,
                                  ),
                                  label: Text(
                                    l.settings_user_edit_title,
                                    style: const TextStyle(
                                      color: AppTheme.electricCyan,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppTheme.electricCyan,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _handleLogout(context),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 18,
                                  ),
                                  label: Text(l.settings_logout_title),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.softCoral,
                                    side: BorderSide(
                                      color: AppTheme.softCoral.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.electricCyan.withValues(
                                      alpha: 0.14,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppTheme.electricCyan,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.auth_guest_mode_title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l.auth_guest_mode_subtitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppTheme.secondaryText
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  AppPageRoute.slideUp(const AuthScreen()),
                                ),
                                icon: const Icon(
                                  Icons.person_add_rounded,
                                  size: 18,
                                  color: Color(0xFF040711),
                                ),
                                label: Text(
                                  l.auth_register_guest_transfer,
                                  style: const TextStyle(
                                    color: Color(0xFF040711),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.electricCyan,
                                ),
                              ),
                            ),
                          ],
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.electricCyan,
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
            if (auth.isLoggedIn) ...[
              const SizedBox(height: AppTheme.spaceLg),
              PageEntranceAnimation(
                delayFraction: 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_section_danger,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.softCoral,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Card(
                      child: ScalePress(
                        onTap: () => _handleDeleteAccount(context),
                        child: ListTile(
                          title: Text(
                            l.profile_delete_account,
                            style: const TextStyle(
                              color: AppTheme.softCoral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(l.profile_delete_account_sub),
                          leading: const Icon(
                            Icons.delete_forever_rounded,
                            color: AppTheme.softCoral,
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
            const Icon(Icons.warning_amber_rounded, color: AppTheme.softCoral),
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
              backgroundColor: AppTheme.softCoral,
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
                        color: AppTheme.electricCyan,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
