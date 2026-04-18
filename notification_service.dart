// ============================================================
// services/notification_service.dart - خدمة الإشعارات
// Firebase Cloud Messaging + Local Notifications
// ============================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// معالجة الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // يمكن معالجة الإشعار هنا
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ==========================================
  // التهيئة
  // ==========================================
  Future<void> initialize() async {
    // طلب الإذن
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // معالجة الرسائل في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // تهيئة الإشعارات المحلية
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // إنشاء قناة الإشعارات لـ Android
    const channel = AndroidNotificationChannel(
      'edtn_lessons',
      'دروس جديدة',
      description: 'إشعارات الدروس الجديدة على منصة EduTN',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // الاستماع للرسائل عند فتح التطبيق
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // الاستماع عند فتح التطبيق من إشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // معالجة الإشعارات أثناء فتح التطبيق
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'edtn_lessons',
          'دروس جديدة',
          channelDescription: 'إشعارات الدروس الجديدة',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // معالجة فتح التطبيق من إشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    // يمكن التنقل إلى الشاشة المناسبة هنا
  }

  // ==========================================
  // إرسال إشعار درس جديد (من الأدمن)
  // ==========================================
  Future<void> sendNewLessonNotification({
    required String lessonTitle,
    required String subjectName,
  }) async {
    // حفظ الإشعار في Firestore لإرساله عبر Cloud Functions
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'درس جديد: $lessonTitle',
      'body': 'تم إضافة درس جديد في مادة $subjectName',
      'type': 'new_lesson',
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  // جلب FCM Token
  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  // الاشتراك في موضوع
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  // إلغاء الاشتراك
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
