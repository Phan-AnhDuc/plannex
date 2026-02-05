import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton service cấu hình và hiển thị local notifications.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _hasPermission = false;

  bool get hasPermission => _hasPermission;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Yêu cầu quyền hiển thị thông báo (nên gọi sau init, trước khi show).
  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      _hasPermission = granted ?? false;
    } else if (Platform.isAndroid) {
      _hasPermission = true;
    } else {
      _hasPermission = true;
    }
  }

  /// Hiển thị thông báo đơn giản ngay lập tức.
  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'plannex_default_channel',
      'General Notifications',
      channelDescription: 'General notifications for Plannex',
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details);
  }
}

