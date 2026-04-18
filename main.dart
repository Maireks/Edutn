// ============================================================
// main.dart - نقطة دخول التطبيق
// EduTN - منصة تعليمية للطلاب التونسيين
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مع الخيارات المخصصة للمنصة
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة خدمة الإشعارات
  await NotificationService().initialize();

  // إجبار اتجاه الشاشة العمودي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ألوان شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // MultiProvider لإدارة الحالة عبر التطبيق
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EduTNApp(),
    ),
  );
}

class EduTNApp extends StatelessWidget {
  const EduTNApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الاستماع لتغييرات الثيم
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'EduTN',
      debugShowCheckedModeBanner: false,

      // دعم RTL للغة العربية
      locale: const Locale('ar', 'TN'),
      supportedLocales: const [
        Locale('ar', 'TN'),
        Locale('ar'),
      ],

      // إجبار اتجاه RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // الثيم الفاتح
      theme: AppTheme.lightTheme,

      // الثيم الداكن
      darkTheme: AppTheme.darkTheme,

      // وضع الثيم الحالي
      themeMode: themeProvider.themeMode,

      // الشاشة الأولى
      home: const SplashScreen(),

      // المسارات
      routes: AppRoutes.routes,
    );
  }
}
