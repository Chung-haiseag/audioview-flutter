import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';
import './notice_service.dart';
import '../screens/notice/notice_detail_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // 1. Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          handleNotificationMessage(response.payload!);
        }
      },
    );

    // 3. Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              autoCancel: false,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['notice_id'],
        );
      }
    });

    // 5. Handle Background Taps (App was in background, not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['notice_id'] != null) {
        handleNotificationMessage(message.data['notice_id']);
      }
    });
  }

  // Call this after runApp() or in the first screen's initState
  static Future<void> checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data['notice_id'] != null) {
      handleNotificationMessage(initialMessage.data['notice_id']);
    }
  }

  static void handleNotificationMessage(String? noticeId) async {
    if (noticeId == null || noticeId.isEmpty) return;

    // print('--- Notification Received for Notice ID: $noticeId ---');

    try {
      // 1. Wait for Navigator to be ready (up to 5 seconds)
      int retryCount = 0;
      while (navigatorKey.currentState == null && retryCount < 10) {
        // print('Waiting for Navigator... ($retryCount)');
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
      }

      if (navigatorKey.currentState == null) {
        // print('Navigator not found after retries.');
        return;
      }

      // 2. Fetch Notice Data
      final notice = await NoticeService().getNoticeById(noticeId);
      if (notice == null) {
        // print('Notice not found in Firestore for ID: $noticeId');
        return;
      }

      // 3. Navigate
      // print('Navigating to detail screen for: ${notice.title}');
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => NoticeDetailScreen(notice: notice),
        ),
      );
    } catch (e) {
      // print('Navigation failed with error: $e');
    }
  }

  static Future<void> saveTokenToDatabase(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        String platformName = kIsWeb ? 'web' : Platform.operatingSystem;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcm_token': token,
          'platform': platformName,
        });
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcm_token': newToken,
        });
      });
    } catch (e) {
      // print('Error saving FCM token: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Background message handling logic
  }
}
