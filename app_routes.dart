// ============================================================
// utils/app_routes.dart - مسارات التطبيق
// ============================================================

import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/subjects_screen.dart';
import '../screens/lessons_screen.dart';
import '../screens/lesson_details_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/add_edit_level_screen.dart';
import '../screens/admin/add_edit_subject_screen.dart';
import '../screens/admin/add_edit_lesson_screen.dart';
import '../screens/admin/reports_screen.dart';

class AppRoutes {
  // أسماء المسارات
  static const String splash = '/';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String lessons = '/lessons';
  static const String lessonDetails = '/lesson-details';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String contact = '/contact';
  static const String adminLogin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String addEditLevel = '/add-edit-level';
  static const String addEditSubject = '/add-edit-subject';
  static const String addEditLesson = '/add-edit-lesson';
  static const String reports = '/reports';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    search: (_) => const SearchScreen(),
    settings: (_) => const SettingsScreen(),
    contact: (_) => const ContactUsScreen(),
    adminLogin: (_) => const AdminLoginScreen(),
    adminDashboard: (_) => const AdminDashboard(),
    reports: (_) => const ReportsScreen(),
  };
}
