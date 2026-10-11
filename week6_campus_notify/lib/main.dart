import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (context, state) {
        return AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        );
      },
    ),
  ],
);

final pushService = PushService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await pushService.initLocalNotifications();

  final allowed = await pushService.requestPermission();

  debugPrint(
    'NOTIFICATION PERMISSION: $allowed',
  );

  await pushService.initToken(
    sendToken: (token) async {
      debugPrint(
        'FCM TOKEN: ${token.substring(0, 12)}...',
      );
    },
  );

  pushService.listenMessages(
    go: (route) {
      router.go(route);
    },
  );

  await pushService.handleInitialMessage(
    go: (route) {
      router.go(route);
    },
  );

  await pushService.subscribePengumuman();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}