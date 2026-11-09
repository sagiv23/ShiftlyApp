import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Secret Easter Egg screen triggered by holding 23.11 for 5 seconds in CalendarScreen.
class SecretScreen extends StatelessWidget {
  const SecretScreen({super.key});

  // ── Configurable Asset Image Path ─────────────────────────────────────
  static const String easterEggImagePath = 'assets/images/easter_egg.png';

  // ── Configurable URLs ──────────────────────────────────────────────────
  static const String instagramUrl1 = 'https://www.instagram.com/sagiv23/';
  static const String instagramUrl2 = 'https://www.instagram.com/shiftlyapp23/';
  static const String instagramUrl3 = 'https://www.instagram.com/mewo.010/';
  static const String youtubeUrl = 'https://www.youtube.com/@Sagiv23';
  static const String githubUrl = 'https://github.com/sagiv23';

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('לא ניתן לפתוח את הקישור: $urlString')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('שגיאה בפתיחת הקישור: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('שגיב המלך'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          child: PageEntranceAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // ── Imported Image Section ────────────────────────────
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : AppTheme.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonViolet.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    easterEggImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback UI if asset image is not found yet
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.neonViolet.withValues(alpha: 0.2),
                              AppTheme.electricCyan.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: AppTheme.electricCyan,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'תמונה מיובאת (Easter Egg)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'כדי להציג את התמונה שלך, שים קובץ ב-assets/images/easter_egg.png',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.secondaryText
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0.0),

                const SizedBox(height: 20),

                // ── 5 Web Links ──────────────────────────────────────
                _SocialLinkTile(
                  title: 'sagiv23',
                  subtitle: instagramUrl1,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF833AB4),
                      Color(0xFFFD1D1D),
                      Color(0xFFF77737),
                    ],
                  ),
                  icon: Icons.camera_alt_rounded,
                  onTap: () => _openUrl(context, instagramUrl1),
                  delayMs: 200,
                ),
                const SizedBox(height: 10),

                _SocialLinkTile(
                  title: 'shiftlyapp23',
                  subtitle: instagramUrl2,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF833AB4),
                      Color(0xFFE1306C),
                      Color(0xFFF56040),
                    ],
                  ),
                  icon: Icons.camera_alt_rounded,
                  onTap: () => _openUrl(context, instagramUrl2),
                  delayMs: 250,
                ),
                const SizedBox(height: 10),

                _SocialLinkTile(
                  title: 'mewo.010',
                  subtitle: instagramUrl3,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF405DE6),
                      Color(0xFF833AB4),
                      Color(0xFFC13584),
                    ],
                  ),
                  icon: Icons.camera_alt_rounded,
                  onTap: () => _openUrl(context, instagramUrl3),
                  delayMs: 300,
                ),
                const SizedBox(height: 10),

                _SocialLinkTile(
                  title: '@Sagiv23',
                  subtitle: youtubeUrl,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                  ),
                  icon: Icons.play_circle_fill_rounded,
                  onTap: () => _openUrl(context, youtubeUrl),
                  delayMs: 350,
                ),
                const SizedBox(height: 10),

                _SocialLinkTile(
                  title: 'sagiv23',
                  subtitle: githubUrl,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF24292E), Color(0xFF0D1117)],
                  ),
                  icon: Icons.code_rounded,
                  onTap: () => _openUrl(context, githubUrl),
                  delayMs: 400,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLinkTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;
  final int delayMs;

  const _SocialLinkTile({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppTheme.glassDecoration(
            context,
            borderRadius: AppTheme.radiusMd,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.mutedText
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: isDark ? AppTheme.secondaryText : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: delayMs.ms).slideX(begin: 0.05, end: 0.0);
  }
}
