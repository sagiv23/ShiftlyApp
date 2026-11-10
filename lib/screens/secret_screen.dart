import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
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

                // ── 2-Column Table: Pro-Shiftly vs Anti-Shiftly ─────
                const ShiftlySidesTable()
                    .animate()
                    .fade(delay: 150.ms)
                    .slideY(begin: 0.1, end: 0.0),

                const SizedBox(height: 24),

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

/// 2-Column Table for "פרושיפטלי" and "אנטישיפטלי"
class ShiftlySidesTable extends StatefulWidget {
  const ShiftlySidesTable({super.key});

  @override
  State<ShiftlySidesTable> createState() => _ShiftlySidesTableState();
}

class _ShiftlySidesTableState extends State<ShiftlySidesTable> {
  static const String _proKey = 'secret_pro_shiftly_list';
  static const String _antiKey = 'secret_anti_shiftly_list';
  static const String _joinedChoiceKey = 'secret_user_joined_choice';
  static const String _joinedNameKey = 'secret_user_joined_name';
  static const String _collapsedKey = 'secret_is_table_collapsed';

  final ApiService _apiService = ApiService();
  late List<String> _proList;
  late List<String> _antiList;
  String? _joinedChoice; // 'pro' or 'anti'
  String? _joinedName;
  bool _isCollapsed = false;
  bool _isSyncing = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchRemoteData();
    // Real-time polling timer every 3 seconds to keep devices perfectly in sync
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _fetchRemoteData(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    final box = Hive.box<dynamic>('settings');
    final rawPro = box.get(_proKey);
    final rawAnti = box.get(_antiKey);

    const demoItems = {'שגיב (המייסד)', 'אוהב Shiftly', 'שעון נוכחות ישן'};

    if (rawPro is List) {
      _proList =
          rawPro
              .map((e) => e.toString())
              .where((e) => !demoItems.contains(e))
              .toList();
    } else {
      _proList = [];
    }

    if (rawAnti is List) {
      _antiList =
          rawAnti
              .map((e) => e.toString())
              .where((e) => !demoItems.contains(e))
              .toList();
    } else {
      _antiList = [];
    }

    _joinedChoice = box.get(_joinedChoiceKey) as String?;
    _joinedName = box.get(_joinedNameKey) as String?;
    _isCollapsed = box.get(_collapsedKey, defaultValue: false) as bool;
  }

  Future<void> _fetchRemoteData({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _isSyncing = true);
    }
    try {
      final remoteData = await _apiService.getSecretTable();
      if (remoteData != null) {
        final remotePro = remoteData['pro'] ?? [];
        final remoteAnti = remoteData['anti'] ?? [];

        final proEqual = listEquals(_proList, remotePro);
        final antiEqual = listEquals(_antiList, remoteAnti);

        if (!proEqual || !antiEqual) {
          _proList = List<String>.from(remotePro);
          _antiList = List<String>.from(remoteAnti);
          if (mounted) {
            setState(() {});
          }
          final box = Hive.box<dynamic>('settings');
          await box.put(_proKey, _proList);
          await box.put(_antiKey, _antiList);
        }
      }
    } catch (_) {} finally {
      if (!silent && mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _saveData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final box = Hive.box<dynamic>('settings');
    await box.put(_proKey, _proList);
    await box.put(_antiKey, _antiList);
    await box.put(_collapsedKey, _isCollapsed);
    if (_joinedChoice != null) {
      await box.put(_joinedChoiceKey, _joinedChoice);
    } else {
      await box.delete(_joinedChoiceKey);
    }
    if (_joinedName != null) {
      await box.put(_joinedNameKey, _joinedName);
    } else {
      await box.delete(_joinedNameKey);
    }

    // Sync to remote API server globally for all users
    await _apiService.updateSecretTable(
      _proList,
      _antiList,
      token: token,
    );

    // Immediate silent re-fetch to confirm server state
    _fetchRemoteData(silent: true);
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    final box = Hive.box<dynamic>('settings');
    box.put(_collapsedKey, _isCollapsed);
  }

  (String?, String?) _getEffectiveState(AuthProvider authProvider) {
    if (authProvider.isLoggedIn) {
      final name = authProvider.userName ?? authProvider.userEmail;
      if (name != null && name.isNotEmpty) {
        if (_proList.contains(name)) return ('pro', name);
        if (_antiList.contains(name)) return ('anti', name);
      }
    }
    if (_joinedName != null && _joinedName!.isNotEmpty) {
      if (_proList.contains(_joinedName!)) return ('pro', _joinedName);
      if (_antiList.contains(_joinedName!)) return ('anti', _joinedName);
    }
    return (null, null);
  }

  void _cancelRegistration() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final (effectiveSide, effectiveName) = _getEffectiveState(authProvider);

    if (effectiveSide == null || effectiveName == null) return;

    final sideName = effectiveSide == 'pro' ? 'פרושיפטלי' : 'אנטישיפטלי';
    showDialog(
      context: context,
      builder:
          (ctx) =>
          AlertDialog(
            title: const Text('ביטול הרשמה'),
            content: Text(
              'האם ברצונך לבטל את הרשמתך ("$effectiveName") מ-$sideName?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.softCoral,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _performCancelRegistration(effectiveName);
                },
                child: const Text('אישור ביטול'),
              ),
            ],
          ),
    );
  }

  void _performCancelRegistration(String name) {
    setState(() {
      _proList.remove(name);
      _antiList.remove(name);
      if (_joinedName == name) {
        _joinedChoice = null;
        _joinedName = null;
      }
    });

    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ההרשמה בוטלה בהצלחה'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _handleJoin(String side) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final (effectiveSide, effectiveName) = _getEffectiveState(authProvider);

    if (effectiveSide != null && effectiveName != null) {
      final currentSideName =
      effectiveSide == 'pro' ? 'פרושיפטלי' : 'אנטישיפטלי';
      final targetSideName = side == 'pro' ? 'פרושיפטלי' : 'אנטישיפטלי';

      if (effectiveSide == side) {
        showDialog(
          context: context,
          builder:
              (ctx) =>
              AlertDialog(
                title: Text('כבר הצטרפת ל$currentSideName'),
                content: Text(
                  'הנך רשום כבר ב-$currentSideName בתור "$effectiveName". האם ברצונך לבטל את ההרשמה?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('סגור'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.softCoral,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cancelRegistration();
                    },
                    child: const Text('ביטול הרשמה'),
                  ),
                ],
              ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (ctx) =>
              AlertDialog(
                title: const Text('ביטול הרשמה קודמת'),
                content: Text(
                  'הנך רשום כרגע ב-$currentSideName בתור "$effectiveName". כדי להצטרף ל-$targetSideName, עליך לבטל תחילה את ההרשמה הקודמת. לבטל כעת?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('ביטול'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.softCoral,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _performCancelRegistration(effectiveName);
                    },
                    child: const Text('ביטול הרשמה קודמת'),
                  ),
                ],
              ),
        );
      }
      return;
    }

    final isPro = side == 'pro';
    final sideTitle = isPro ? 'פרושיפטלי' : 'אנטישיפטלי';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _buildJoinOptionsSheet(ctx, side, sideTitle, authProvider),
    );
  }

  Widget _buildJoinOptionsSheet(BuildContext context,
      String side,
      String sideTitle,
      AuthProvider authProvider,) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.secondaryText : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'הצטרפות ל$sideTitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.primaryText : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'בחר כיצד ברצונך להופיע בטבלה (ניתן להצטרף פעם אחת בלבד):',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.secondaryText : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            if (authProvider.isLoggedIn) ...[
              ScalePress(
                onTap: () {
                  Navigator.pop(context);
                  final name =
                      authProvider.userName ??
                          authProvider.userEmail ??
                          'משתמש Shiftly';
                  _addEntry(side, name);
                },
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor:
                    side == 'pro' ? AppTheme.mintGreen : AppTheme.softCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: const Icon(Icons.account_circle_rounded),
                  label: Text(
                    'הצטרף כמשתמש Shiftly (${authProvider.userName ??
                        authProvider.userEmail ?? "משתמש"})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: null, // Handled by ScalePress
                ),
              ),
              const SizedBox(height: 12),
            ] else
              ...[
                ScalePress(
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      AppPageRoute.fadeScale(const AuthScreen()),
                    );
                    if (context.mounted) {
                      setState(() {});
                    }
                  },
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color:
                        side == 'pro'
                            ? AppTheme.mintGreen
                            : AppTheme.softCoral,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'התחבר למשתמש Shiftly (auth_screen.dart)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: null, // Handled by ScalePress
                  ),
                ),
                const SizedBox(height: 12),
              ],

            ScalePress(
              onTap: () {
                Navigator.pop(context);
                _showManualNameDialog(side);
              },
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor:
                  isDark
                      ? AppTheme.darkSecondaryBackground
                      : AppTheme.lightSurfaceElevated,
                  foregroundColor:
                  isDark ? AppTheme.primaryText : Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'הזן שם מלא ידנית',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: null, // Handled by ScalePress
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualNameDialog(String side) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isPro = side == 'pro';
    final sideTitle = isPro ? 'פרושיפטלי' : 'אנטישיפטלי';

    showDialog(
      context: context,
      builder:
          (ctx) =>
          AlertDialog(
            title: Text('הזנת שם ל$sideTitle'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'שם מלא',
                  hintText: 'הזן את שמך מלא...',
                ),
                validator: (val) {
                  if (val == null || val
                      .trim()
                      .isEmpty) {
                    return 'אנא הזן שם מלא';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isPro ? AppTheme.mintGreen : AppTheme.softCoral,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final name = controller.text.trim();
                    Navigator.pop(ctx);
                    _addEntry(side, name);
                  }
                },
                child: const Text('הוסף אותי'),
              ),
            ],
          ),
    );
  }

  void _addEntry(String side, String name) {
    setState(() {
      if (side == 'pro') {
        _antiList.remove(name);
        if (!_proList.contains(name)) {
          _proList.add(name);
        }
      } else {
        _proList.remove(name);
        if (!_antiList.contains(name)) {
          _antiList.add(name);
        }
      }
      _joinedChoice = side;
      _joinedName = name;
    });
    _saveData();

    final sideTitle = side == 'pro' ? 'פרושיפטלי' : 'אנטישיפטלי';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נוספת בהצלחה ל-$sideTitle בתור "$name"'),
        backgroundColor:
        side == 'pro' ? AppTheme.mintGreen : AppTheme.softCoral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final (effectiveSide, effectiveName) = _getEffectiveState(authProvider);

    return Container(
      decoration: AppTheme.glassDecoration(
        context,
        borderRadius: AppTheme.radiusLg,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Collapse Toggle & Refresh
          InkWell(
            onTap: _toggleCollapse,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_rounded,
                  color: AppTheme.electricCyan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'פרושיפטלי vs אנטישיפטלי',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isSyncing) ...[
                            const SizedBox(width: 6),
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.electricCyan,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_isCollapsed)
                        Text(
                          'לחץ להרחבת הטבלה (${_proList
                              .length} פרו vs ${_antiList.length} אנטי)',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                            isDark
                                ? AppTheme.mutedText
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'רענון נתונים',
                  onPressed: () => _fetchRemoteData(silent: false),
                ),
                IconButton(
                  icon: Icon(
                    _isCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color:
                    isDark ? AppTheme.secondaryText : Colors.grey.shade700,
                  ),
                  tooltip: _isCollapsed ? 'להרחבת הטבלה' : 'למזעור הטבלה',
                  onPressed: _toggleCollapse,
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
            _isCollapsed
                ? const SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Text(
                  'בחר צד והוסף את עצמך לטבלה',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    isDark
                        ? AppTheme.secondaryText
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // 2 Columns
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Column 1: Pro-Shiftly
                      Expanded(
                        child: _buildSideColumn(
                          context: context,
                          title: 'פרושיפטלי',
                          color: AppTheme.mintGreen,
                          items: _proList,
                          side: 'pro',
                          effectiveSide: effectiveSide,
                          effectiveName: effectiveName,
                        ),
                      ),
                      const VerticalDivider(width: 16, thickness: 1),
                      // Column 2: Anti-Shiftly
                      Expanded(
                        child: _buildSideColumn(
                          context: context,
                          title: 'אנטישיפטלי',
                          color: AppTheme.softCoral,
                          items: _antiList,
                          side: 'anti',
                          effectiveSide: effectiveSide,
                          effectiveName: effectiveName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideColumn({
    required BuildContext context,
    required String title,
    required Color color,
    required List<String> items,
    required String side,
    required String? effectiveSide,
    required String? effectiveName,
  }) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final hasJoined = effectiveSide != null;
    final isMySide = hasJoined && effectiveSide == side;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${items.length} חברים',
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // List of names with smart multiline text wrapping
        Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
            isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child:
          items.isEmpty
              ? Center(
            child: Text(
              'אין נרשמים עדיין',
              style: TextStyle(
                fontSize: 12,
                color:
                isDark
                    ? AppTheme.mutedText
                    : Colors.grey.shade500,
              ),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
            items.map((name) {
              final isMe = name == effectiveName;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                  isMe
                      ? color.withValues(alpha: 0.2)
                      : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(
                    AppTheme.radiusSm,
                  ),
                  border:
                  isMe
                      ? Border.all(color: color, width: 1.5)
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        isMe
                            ? Icons.stars_rounded
                            : Icons.person_rounded,
                        size: 14,
                        color:
                        isMe
                            ? color
                            : (isDark
                            ? AppTheme.secondaryText
                            : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight:
                          isMe
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                          isMe
                              ? color
                              : Theme
                              .of(
                            context,
                          )
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                    ),
                    if (isMe)
                      GestureDetector(
                        onTap: _cancelRegistration,
                        child: const Padding(
                          padding: EdgeInsets.only(
                            right: 4,
                            top: 2,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppTheme.softCoral,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Join/Cancel button for this side
        ScalePress(
          onTap: isMySide ? _cancelRegistration : () => _handleJoin(side),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isMySide
                  ? AppTheme.softCoral
                  : (hasJoined ? Colors.grey.shade400 : color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              elevation: isMySide ? 2 : (hasJoined ? 0 : 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            icon: Icon(
              isMySide
                  ? Icons.close_rounded
                  : (hasJoined ? Icons.lock_outlined : Icons.add_rounded),
              size: 16,
            ),
            label: Text(
              isMySide
                  ? 'ביטול הרשמה'
                  : (hasJoined ? 'החלף צד' : '+ הצטרף'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: null, // Handled by ScalePress
          ),
        ),
      ],
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

    return ScalePress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: 14,
        ),
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
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      isDark
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
    ).animate().fade(delay: delayMs.ms).slideX(begin: 0.05, end: 0.0);
  }
}
