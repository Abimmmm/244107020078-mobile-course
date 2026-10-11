import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // JANGAN akses BuildContext / Navigator / Riverpod di sini.
  // Handler background berjalan di isolate terpisah.
}

class PushService {
  PushService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> initLocalNotifications() async {
    // Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS
    const ios = DarwinInitializationSettings();

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> initToken({
    required Future<void> Function(String token) sendToken,
  }) async {
    final token = await _messaging.getToken();

    if (token != null) {
      await sendToken(token);
    }

    _messaging.onTokenRefresh.listen(sendToken);
  }

  void listenMessages({required void Function(String route) go}) {
    // FOREGROUND
    FirebaseMessaging.onMessage.listen((message) async {
      final route = message.data['route'] ?? '/';

      const androidDetails = AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // BACKGROUND -> notif diklik
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'] ?? '/';

      go(route);
    });
  }

  Future<void> handleInitialMessage({
    required void Function(String route) go,
  }) async {
    // TERMINATED -> notif diklik
    final initial = await _messaging.getInitialMessage();

    if (initial != null) {
      final route = initial.data['route'] ?? '/';

      go(route);
    }
  }

  Future<void> subscribePengumuman() async {
    await _messaging.subscribeToTopic('pengumuman-kampus');
  }

  Future<void> unsubscribePengumuman() async {
    await _messaging.unsubscribeFromTopic('pengumuman-kampus');
  }
}
