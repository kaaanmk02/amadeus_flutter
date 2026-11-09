import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Amadeus iç bildirimleri: mesaj geldiğinde kendi içinden bildirim verir.
class NotificationManager {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();

  late final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (!_initialized) await init();
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (result != true && Platform.isAndroid) {
      // İzin reddedildi; sessizce devam et
    }
  }

  Future<void> showMessageNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    const android = AndroidNotificationDetails(
      'amadeus_channel',
      'Amadeus',
      channelDescription: 'Amadeus mesaj bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ticker: 'Amadeus',
    );
    const details = NotificationDetails(android: android);
    await _plugin.show(id, title, body, details, payload: 'amadeus');
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
