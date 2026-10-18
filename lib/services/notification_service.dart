import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shiftly/main.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Function(String)? onActionReceived;

  static bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Maps any Dart hash/id into a positive 31-bit int safe for iOS UNNotification.
  static int toNotificationId(int rawId) => rawId & 0x7FFFFFFF;

  static Future<void> init() async {
    try {
      if (!_isSupported) return;

      // Must run before any TZDateTime / tz.local usage.
      await _configureLocalTimeZone();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open');

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux,
          );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          try {
            if (details.actionId != null) {
              onActionReceived?.call(details.actionId!);

              if (details.actionId == 'stop_shift') {
                navigatorKey.currentState?.push(
                  AppPageRoute.slideUp(
                    const AddShiftScreen(initialTabIndex: 0),
                  ),
                );
              }
            } else {
              navigatorKey.currentState?.push(
                AppPageRoute.slideUp(const AddShiftScreen(initialTabIndex: 0)),
              );
            }
          } catch (e) {
            debugPrint('Error handling notification response: $e');
          }
        },
      );

      await requestPermissions();
    } catch (e) {
      debugPrint('Error in NotificationService.init: $e');
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    try {
      final TimezoneInfo timeZoneInfo =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      debugPrint('Local timezone set to ${timeZoneInfo.identifier}');
    } catch (e) {
      debugPrint('Failed to resolve device timezone: $e');
      // App locale is he_IL; Asia/Jerusalem is a safe fallback if lookup fails.
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jerusalem'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  /// Explicit permission request for iOS/macOS/Android. Safe to call multiple times.
  static Future<bool> requestPermissions() async {
    if (!_isSupported) return false;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        final granted = await macPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  static Future<void> showTimerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime startTime,
    required String channelName,
    required String channelDescription,
    required String stopActionLabel,
    required String resumeActionLabel,
    required String paidBreakActionLabel,
    required String unpaidBreakActionLabel,
    bool isOnBreak = false,
  }) async {
    if (!_isSupported) return;

    try {
      final List<AndroidNotificationAction> androidActions = [];
      if (isOnBreak) {
        androidActions.add(
          AndroidNotificationAction(
            'end_break',
            resumeActionLabel,
            showsUserInterface: true,
          ),
        );
      } else {
        androidActions.add(
          AndroidNotificationAction(
            'start_paid_break',
            paidBreakActionLabel,
            showsUserInterface: true,
          ),
        );
        androidActions.add(
          AndroidNotificationAction(
            'start_unpaid_break',
            unpaidBreakActionLabel,
            showsUserInterface: true,
          ),
        );
      }
      androidActions.add(
        AndroidNotificationAction(
          'stop_shift',
          stopActionLabel,
          showsUserInterface: true,
        ),
      );

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'timer_channel',
            channelName,
            channelDescription: channelDescription,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            showWhen: true,
            usesChronometer: !isOnBreak,
            when: startTime.millisecondsSinceEpoch,
            actions: androidActions,
          );

      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const LinuxNotificationDetails linuxPlatformChannelSpecifics =
          LinuxNotificationDetails();

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics,
        macOS: darwinPlatformChannelSpecifics,
        linux: linuxPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        id: toNotificationId(id),
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: 'timer_action',
      );
    } catch (e) {
      debugPrint('Error showing timer notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (!_isSupported) return;
    try {
      await _notificationsPlugin.cancel(id: toNotificationId(id));
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }
}
