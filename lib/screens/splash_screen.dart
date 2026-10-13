import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/screens/main_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _exitController;

  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<Offset> _iconOffsetAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _glowScaleAnimation;
  late Animation<double> _splashOpacityAnimation;
  late Animation<double> _splashScaleAnimation;
  late Animation<double> _nextScreenOpacityAnimation;

  bool _hasStarted = false;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // 1. Text & loading circle fade out and slide down slightly (0.0 to 0.35)
    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 0.08)).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.0, 0.35, curve: Curves.easeInCubic),
          ),
        );

    // 2. Icon glides down to center Offset(0, 0) and enlarges (1.0 -> 1.45) (0.08 to 0.72)
    _iconOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, -75), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.08, 0.72, curve: Curves.easeInOutCubic),
          ),
        );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.08, 0.72, curve: Curves.easeInOutCubic),
      ),
    );

    _glowScaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.08, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Splash background overlay zoom-fade to reveal preloaded target screen (0.68 to 1.0)
    _splashOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.68, 1.0, curve: Curves.easeInOut),
      ),
    );

    _splashScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.68, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _nextScreenOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.62, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasStarted && mounted) {
        _hasStarted = true;
        final disabledAnimations = MediaQuery.of(context).disableAnimations;
        if (!disabledAnimations) {
          _floatController.repeat(reverse: true);
        }
        _runInitializationSequence();
      }
    });
  }

  @override
  void dispose() {
    _floatController.stop();
    _floatController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _runInitializationSequence() async {
    final auth = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();
    final startTime = DateTime.now();

    bool isUserValid = false;

    try {
      await auth.restoreLocalSession().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('Local session restore timed out.');
        },
      );

      if (auth.isLoggedIn) {
        final profileSyncOk = await auth.syncProfileAndDrive().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Profile sync timed out.');
            return false;
          },
        );
        isUserValid = profileSyncOk && auth.isLoggedIn;
      }
    } catch (e) {
      debugPrint('Initialization error during splash screen: $e');
      isUserValid = false;
      try {
        await auth.logout(navigate: false);
      } catch (_) {}
    }
    if (!mounted) return;

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1200) {
      await Future.delayed(Duration(milliseconds: 1200 - elapsed));
    }
    if (!mounted) return;

    final Widget nextScreen;
    if (!isUserValid || !auth.isLoggedIn) {
      nextScreen = const AuthScreen();
    } else {
      if (!settings.hasCompletedOnboarding) {
        await settings.completeOnboarding();
      }
      nextScreen = const MainScreen();
    }

    if (!mounted) return;
    setState(() {
      _targetScreen = nextScreen;
    });

    // Wait 2 frame ticks so Flutter compiles, builds and lays out the target screen in memory
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    // Stop ambient float and execute the transition animation
    _floatController.stop();
    final disabledAnimations = MediaQuery.of(context).disableAnimations;
    if (disabledAnimations) {
      _exitController.value = 1.0;
    } else {
      await _exitController.forward();
    }

    if (!mounted) return;

    // Swap to permanent root route with zero lag
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _targetScreen!,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledAnimations = MediaQuery.of(context).disableAnimations;

    final bgColors = isDark
        ? [
            const Color(0xFF131B2E),
            const Color(0xFF0A0F1D),
            const Color(0xFF04060C),
          ]
        : [
            const Color(0xFFF8FAFC),
            const Color(0xFFEEF2F6),
            const Color(0xFFE2E8F0),
          ];

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.85);
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppTheme.primary.withValues(alpha: 0.18);

    return Scaffold(
      body: RepaintBoundary(
        child: Stack(
          children: [
            // 1. Preloaded Target Screen (MainScreen or AuthScreen) in Background Stack
            if (_targetScreen != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _exitController,
                  builder: (context, child) {
                    final opacity = _nextScreenOpacityAnimation.value.clamp(
                      0.0,
                      1.0,
                    );
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: KeyedSubtree(
                    key: const ValueKey('preloaded_target_screen'),
                    child: _targetScreen!,
                  ),
                ),
              ),

            // 2. Foreground Splash Screen Overlay
            AnimatedBuilder(
              animation: _exitController,
              builder: (context, child) {
                final splashOpacity = _splashOpacityAnimation.value.clamp(
                  0.0,
                  1.0,
                );
                if (splashOpacity <= 0.0) {
                  return const SizedBox.shrink();
                }
                final splashScale = _splashScaleAnimation.value;

                return Opacity(
                  opacity: splashOpacity,
                  child: Transform.scale(scale: splashScale, child: child),
                );
              },
              child: Stack(
                children: [
                  // Immersive Radial Gradient Background
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final pulse = disabledAnimations
                            ? 0.0
                            : math.sin(_floatController.value * math.pi);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(0, -0.2 + (pulse * 0.02)),
                              radius: 1.2 + (pulse * 0.06),
                              colors: bgColors,
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Content Layout
                  SafeArea(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Floating / Moving Icon with Glow
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _floatController,
                              _exitController,
                            ]),
                            builder: (context, child) {
                              final floatY =
                                  (disabledAnimations ||
                                      _exitController.isAnimating ||
                                      _exitController.isCompleted)
                                  ? 0.0
                                  : math.sin(
                                          _floatController.value * 2 * math.pi,
                                        ) *
                                        6.0;

                              final currentOffset =
                                  _iconOffsetAnimation.value +
                                  Offset(0, floatY);
                              final currentScale = _iconScaleAnimation.value;
                              final currentGlowScale =
                                  _glowScaleAnimation.value;

                              return Transform.translate(
                                offset: currentOffset,
                                child: Transform.scale(
                                  scale: currentScale,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Ambient Glow
                                      Container(
                                        width: 190 * currentGlowScale,
                                        height: 190 * currentGlowScale,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withValues(
                                                    alpha: isDark ? 0.35 : 0.22,
                                                  ),
                                              blurRadius: 60 * currentGlowScale,
                                              spreadRadius:
                                                  15 * currentGlowScale,
                                            ),
                                          ],
                                        ),
                                      ),
                                      EssentialWorkIcon(
                                        size: 135,
                                        symbol: currencySymbol,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Text & Loading Circle Column
                          AnimatedBuilder(
                            animation: _exitController,
                            builder: (context, child) {
                              final textOpacity = _textOpacityAnimation.value
                                  .clamp(0.0, 1.0);
                              if (textOpacity <= 0.0) {
                                return const SizedBox.shrink();
                              }
                              return Transform.translate(
                                offset:
                                    const Offset(0, 110) +
                                    _textSlideAnimation.value * 100,
                                child: Opacity(
                                  opacity: textOpacity,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // App Name (Larger prominent typography)
                                Text(
                                      l.common_app_name,
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize: 52,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                const SizedBox(height: 10),

                                // Tagline (Larger font)
                                Text(
                                      l.common_tagline,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.9,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 100.ms, duration: 400.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                const SizedBox(height: 48),

                                // Clean Minimalist Loading Circle
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 16,
                                      sigmaY: 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardBorder,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary.withValues(
                                              alpha: isDark ? 0.25 : 0.12,
                                            ),
                                            blurRadius: 28,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppTheme.primary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(
                                  delay: 200.ms,
                                  duration: 400.ms,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
