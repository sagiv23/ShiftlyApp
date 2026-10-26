import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/main_screen.dart';
import 'package:shiftly/screens/onboarding_screen.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/legal_utils.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/app_icon.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _entranceController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login
          ? AuthMode.register
          : AuthMode.login;
    });
  }

  Future<void> _continueAsGuest() async {
    final authProvider = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await authProvider.continueAsGuest();

    if (!mounted) return;

    final Widget nextScreen;
    if (!settingsProvider.hasCompletedOnboarding) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const MainScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      AppPageRoute.fadeScale(
        nextScreen,
        duration: const Duration(milliseconds: 200),
      ),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final shiftProvider = context.read<ShiftProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final l = AppLocalizations.of(context)!;

      if (_authMode == AuthMode.login) {
        // Section 3.A: Confirm before replacing local guest data
        final hasGuestData =
            authProvider.isGuest ||
            shiftProvider.shifts.isNotEmpty ||
            shiftProvider.expenses.isNotEmpty;

        if (hasGuestData) {
          final confirmed = await UIUtils.showConfirmDialog(
            context: context,
            title: l.auth_replace_guest_data_title,
            content: l.auth_replace_guest_data_message,
            confirmLabel: l.auth_replace_guest_data_confirm,
            cancelLabel: l.auth_replace_guest_data_cancel,
            isDestructive: true,
          );

          if (confirmed != true) {
            setState(() => _isLoading = false);
            return;
          }
        }

        // Authenticate on server
        final authData = await authProvider.authenticateOnly(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final token = authData['token']?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('No token returned');
        }

        // Retrieve and validate account data from server before overwriting local guest data
        final apiService = ApiService();
        final remoteJobTypes = await apiService.getJobTypes(token);
        final remoteExpenses = await apiService.getExpenses(token);
        final remoteShifts = await apiService.getShifts(token);

        final replaced = await shiftProvider.replaceLocalDataAtomic(
          remoteJobTypes: remoteJobTypes,
          remoteExpenses: remoteExpenses,
          remoteShifts: remoteShifts,
        );

        if (!replaced) {
          throw Exception('Failed to apply account data');
        }

        await authProvider.applyLoginSession(authData);
      } else {
        // Section 3.B: Registering a new account from guest mode
        if (_selectedBirthDate == null) {
          UIUtils.showSnackBar(
            context,
            l.auth_error_birth_date_empty,
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }

        final now = DateTime.now();
        int age = now.year - _selectedBirthDate!.year;
        if (now.month < _selectedBirthDate!.month ||
            (now.month == _selectedBirthDate!.month &&
                now.day < _selectedBirthDate!.day)) {
          age--;
        }

        if (age < 12) {
          UIUtils.showSnackBar(context, l.auth_error_underage, isError: true);
          setState(() => _isLoading = false);
          return;
        }

        await authProvider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          birthDate: _selectedBirthDate,
        );

        // Migrate local guest data to newly created account
        final migrated = await shiftProvider.migrateGuestDataToServer(
          authProvider.token!,
        );
        if (!migrated) {
          debugPrint(
            'Guest data migration failed, local data preserved for retry.',
          );
        }
      }

      if (!mounted) return;

      shiftProvider.updateAuthStatus(
        authProvider.token,
        false, // authProvider.isByosConnected,
        settingsProvider.autoSyncEnabled,
      );

      if (_authMode == AuthMode.login) {
        await shiftProvider.syncWithServer();
      }

      if (!mounted) return;
      UIUtils.showSnackBar(
        context,
        _authMode == AuthMode.login
            ? l.auth_login_success
            : l.auth_register_success,
      );

      final Widget nextScreen;
      if (_authMode == AuthMode.register) {
        await settingsProvider.setOnboardingCompleted(false);
        nextScreen = const OnboardingScreen();
      } else {
        await settingsProvider.completeOnboarding();
        nextScreen = const MainScreen();
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        AppPageRoute.fadeScale(
          nextScreen,
          duration: const Duration(milliseconds: 200),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        final errStr = e.toString().toLowerCase();
        String message;

        if (errStr.contains('socket') ||
            errStr.contains('timeout') ||
            errStr.contains('connection') ||
            errStr.contains('clientexception') ||
            errStr.contains('network') ||
            errStr.contains('failed host lookup') ||
            errStr.contains('unreachable')) {
          message = l.auth_error_network;
        } else if (_authMode == AuthMode.login) {
          message = l.auth_error_user_not_found;
        } else {
          if (errStr.contains('email') ||
              errStr.contains('exist') ||
              errStr.contains('taken') ||
              errStr.contains('already') ||
              errStr.contains('use') ||
              errStr.contains('400')) {
            message = l.auth_error_email_exists;
          } else {
            message = l.auth_error_generic;
          }
        }

        UIUtils.showSnackBar(context, message, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLogin = _authMode == AuthMode.login;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColors = isDark
        ? [AppTheme.darkCard, AppTheme.darkBackground]
        : [AppTheme.lightBackground, AppTheme.lightBorder];

    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = textColor.withValues(alpha: isDark ? 0.7 : 0.65);
    final mutedTextColor = textColor.withValues(alpha: isDark ? 0.38 : 0.45);
    final inputFill = isDark
        ? AppTheme.darkCard.withValues(alpha: 0.7)
        : AppTheme.lightCard;
    final inputBorderColor = isDark
        ? AppTheme.darkBorder
        : const Color(0xFF94A3B8);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Glowing Icon
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          final glow =
                              0.3 +
                              (0.2 * math.sin(_glowController.value * math.pi));
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(
                                        alpha: isDark ? glow : glow * 0.5,
                                      ),
                                      blurRadius: 36,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              EssentialWorkIcon(
                                size: 80,
                                symbol: context
                                    .watch<SettingsProvider>()
                                    .currencySymbol,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Animated Switcher for Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          isLogin ? l.auth_login_title : l.auth_register_title,
                          key: ValueKey(isLogin),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Animated Expansion for Full Name & Date of Birth Fields
                      AnimatedSize(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        child: !isLogin
                            ? Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(color: textColor),
                                    decoration: _buildInputDecoration(
                                      label: l.auth_full_name_label,
                                      hint: l.auth_full_name_label,
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                      inputFill: inputFill,
                                      inputBorderColor: inputBorderColor,
                                      subtextColor: subtextColor,
                                      mutedTextColor: mutedTextColor,
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? l.auth_error_name_empty
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  InkWell(
                                    onTap: () async {
                                      final picked =
                                          await AppDatePicker.showBirthDatePicker(
                                            context: context,
                                            initialDate: _selectedBirthDate,
                                          );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedBirthDate = picked;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration:
                                          _buildInputDecoration(
                                            label: l.auth_birth_date_label,
                                            hint: l.auth_birth_date_label,
                                            icon: Icons.cake_outlined,
                                            isDark: isDark,
                                            inputFill: inputFill,
                                            inputBorderColor: inputBorderColor,
                                            subtextColor: subtextColor,
                                            mutedTextColor: mutedTextColor,
                                          ).copyWith(
                                            suffixIcon: Icon(
                                              Icons.calendar_today_rounded,
                                              color: subtextColor,
                                            ),
                                          ),
                                      child: Text(
                                        _selectedBirthDate == null
                                            ? l.auth_birth_date_label
                                            : AppConstants.formatDate(
                                                _selectedBirthDate,
                                              ),
                                        style: TextStyle(
                                          color: _selectedBirthDate == null
                                              ? mutedTextColor
                                              : textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: textColor),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          label: l.auth_email_label,
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          inputFill: inputFill,
                          inputBorderColor: inputBorderColor,
                          subtextColor: subtextColor,
                          mutedTextColor: mutedTextColor,
                        ),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return l.auth_error_email_invalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: textColor),
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          label: l.auth_password_label,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          isDark: isDark,
                          inputFill: inputFill,
                          inputBorderColor: inputBorderColor,
                          subtextColor: subtextColor,
                          mutedTextColor: mutedTextColor,
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? l.common_show_password
                                : l.common_hide_password,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: subtextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return l.auth_error_password_length;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ScalePress(
                          onTap: _isLoading ? null : _submit,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0F172A),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    isLogin
                                        ? l.auth_login_button
                                        : l.auth_register_button,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isLoading ? null : _switchAuthMode,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            isLogin
                                ? l.auth_no_account_link
                                : l.auth_has_account_link,
                            key: ValueKey(isLogin),
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.primary
                                  : AppTheme.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _continueAsGuest,
                          icon: Icon(
                            Icons.person_outline_rounded,
                            color: subtextColor,
                          ),
                          label: Text(
                            l.auth_continue_as_guest,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: inputBorderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legal Disclaimer & Links
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l.legal_disclaimer_notice,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => LegalUtils.showTermsOfService(context),
                            child: Text(
                              l.legal_terms_of_service,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.primary
                                    : AppTheme.primaryDark,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            '  •  ',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.38),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => LegalUtils.showPrivacyPolicy(context),
                            child: Text(
                              l.legal_privacy_policy,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.primary
                                    : AppTheme.primaryDark,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color inputFill,
    required Color inputBorderColor,
    required Color subtextColor,
    required Color mutedTextColor,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: inputFill,
      labelText: label,
      hintText: hint ?? label,
      hintStyle: TextStyle(color: mutedTextColor),
      labelStyle: TextStyle(color: subtextColor),
      prefixIcon: Icon(icon, color: subtextColor),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppTheme.primary : AppTheme.primaryDark,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
