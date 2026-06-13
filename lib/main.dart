import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // AUTO-GENERATED oleh flutterfire configure
import 'app.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/models/notification_model.dart';
import 'core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
  
  if (message.notification != null) {
    final notif = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification!.title ?? 'New Notification',
      body: message.notification!.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
    );
    await NotificationService.instance.saveNotification(notif);
  }
}

void main() async {
  // Wajib dipanggil sebelum Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'drawable/ic_notification',
  );

  // ── Inisialisasi Firebase ──────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  await messaging.subscribeToTopic('new_songs');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Got a foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      final notif = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        timestamp: message.sentTime ?? DateTime.now(),
      );
      await NotificationService.instance.saveNotification(notif);
    }
  });

  // Load env file
  await dotenv.load(fileName: ".env");

  // ── Inisialisasi Supabase ──────────────────────────────────
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://vikvtiwghzvjuthghlxu.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_anUSAdPm26P4Am2TzlAqDQ_7wvQOJWH',
  );

  // ── Paksa portrait mode ────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar transparan (sesuai desain Figma) ────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MikuPlayApp());
}
