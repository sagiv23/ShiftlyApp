import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/screens/main_screen.dart';
import 'package:shiftly/screens/onboarding_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/widgets/app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _iconGlow;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // Staggered intro animations
    _iconScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _iconGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.70, curve: Curves.easeIn),
      ),
    );

    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.50, 0.88, curve: Curves.easeOutCubic),
          ),
        );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.80, curve: Curves.easeIn),
      ),
    );

    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
    _navigateToHome();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3100));
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    final Widget nextScreen = settings.hasCompletedOnboarding
        ? const MainScreen()
        : const OnboardingScreen();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      AppPageRoute.fadeScale(
        nextScreen,
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient with Ambient Glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final pulse = math.sin(_floatController.value * math.pi);
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2 + (pulse * 0.05)),
                      radius: 1.2 + (pulse * 0.15),
                      colors: [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                        const Color(0xFF080D1A),
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // Central Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon with Glow Aura and Gentle Floating Motion
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _mainController,
                      _floatController,
                    ]),
                    builder: (context, child) {
                      final floatY =
                          math.sin(_floatController.value * 2 * math.pi) * 5.0;
                      final glowOpacity =
                          _iconGlow.value *
                          (0.4 +
                              (0.2 *
                                  math.sin(_floatController.value * math.pi)));

                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient Radial Glow behind Icon
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(
                                      alpha: glowOpacity,
                                    ),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            // Icon with Scale & Fade
                            FadeTransition(
                              opacity: _iconFade,
                              child: ScaleTransition(
                                scale: _iconScale,
                                child: EssentialWorkIcon(
                                  size: 180,
                                  symbol: currencySymbol,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // App Name Title
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Text(
                        l.common_app_name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        l.common_tagline,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 54),

                  // Loading Indicator
                  FadeTransition(
                    opacity: _loaderFade,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 3,
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
