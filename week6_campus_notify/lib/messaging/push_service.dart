import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Jangan akses BuildContext / Riverpod di sini.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(
      android: android,
      iOS: ios,
    ),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
    },
  );
}

void listenForeground(
  void Function(String route) go,
) {
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
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(message.data['route'] ?? '/');
  });
}

Future<void> handleTerminated(
  void Function(String route) go,
) async {
  final initial =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initial != null) {
    go(initial.data['route'] ?? '/');
  }

  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
  }
}

Future<void> subscribeTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic(
    'pengumuman-kampus',
  );
}

Future<void> unsubscribeTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(
    'pengumuman-kampus',
  );
}