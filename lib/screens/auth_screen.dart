import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/app_icon.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;

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
    )
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final shiftProvider = context.read<ShiftProvider>();
      final l = AppLocalizations.of(context)!;

      if (_authMode == AuthMode.login) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
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
          UIUtils.showSnackBar(
            context,
            l.auth_error_underage,
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }

        await authProvider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          birthDate: _selectedBirthDate,
        );
      }

      if (!mounted) return;

      final remoteShifts = await ApiService().getShifts(authProvider.token!);
      bool? keepLocal;

      if (remoteShifts.isNotEmpty && shiftProvider.shifts.isNotEmpty) {
        if (mounted) {
          keepLocal = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text(l.auth_sync_dialog_title),
              content: Text(l.auth_sync_dialog_content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.auth_sync_dialog_cloud),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.auth_sync_dialog_local),
                ),
              ],
            ),
          );
        }
      }

      await shiftProvider.syncWithServer(keepLocal: keepLocal);

      if (!mounted) return;
      UIUtils.showSnackBar(
        context,
        _authMode == AuthMode.login
            ? l.auth_login_success
            : l.auth_register_success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        UIUtils.showSnackBar(context, l.auth_error_generic, isError: true);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
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
                          final glow = 0.3 +
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
                                          alpha: glow),
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
                          style: const TextStyle(
                            color: Colors.white,
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
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                label: l.auth_full_name_label,
                                hint: l.auth_full_name_label,
                                icon: Icons.person_outline,
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? l.auth_error_name_empty
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedBirthDate ??
                                      DateTime.now().subtract(
                                        const Duration(days: 365 * 18),
                                      ),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedBirthDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: _buildInputDecoration(
                                  label: l.auth_birth_date_label,
                                  hint: l.auth_birth_date_label,
                                  icon: Icons.cake_outlined,
                                ).copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white70,
                                  ),
                                ),
                                child: Text(
                                  _selectedBirthDate == null
                                      ? l.auth_birth_date_label
                                      : DateFormat('dd/MM/yyyy')
                                      .format(_selectedBirthDate!),
                                  style: TextStyle(
                                    color: _selectedBirthDate == null
                                        ? Colors.white38
                                        : Colors.white,
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
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          label: l.auth_email_label,
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
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
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: _buildInputDecoration(
                          label: l.auth_password_label,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
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
                            style: const TextStyle(color: AppTheme.primary),
                          ),
                        ),
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
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      hintStyle: const TextStyle(color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
