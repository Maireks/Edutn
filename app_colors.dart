// ============================================================
// utils/app_colors.dart - لوحة الألوان المركزية
// ============================================================
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── الألوان الرئيسية ────────────────────────────────────
  static const Color primary      = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark  = Color(0xFF0D47A1);
  static const Color accent       = Color(0xFFE53935);
  static const Color gold         = Color(0xFFFFB300);

  // ─── الخلفيات - الوضع الفاتح ─────────────────────────────
  static const Color lightBg       = Color(0xFFF5F7FA);
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFFFFFFF);
  static const Color lightBorder   = Color(0xFFE5E7EB);

  // ─── الخلفيات - الوضع الداكن ──────────────────────────────
  static const Color darkBg        = Color(0xFF0A0E1A);
  static const Color darkSurface   = Color(0xFF131929);
  static const Color darkCard      = Color(0xFF1A2235);
  static const Color darkBorder    = Color(0xFF2A3A5A);

  // ─── ألوان الحالة ─────────────────────────────────────────
  static const Color success  = Color(0xFF2E7D32);
  static const Color warning  = Color(0xFFF57F17);
  static const Color error    = Color(0xFFC62828);
  static const Color info     = Color(0xFF01579B);

  // ─── ألوان الفروع التونسية ─────────────────────────────────
  static const Map<String, Color> branches = {
    'علوم':           Color(0xFF2E7D32),
    'رياضيات':        Color(0xFF1565C0),
    'اقتصاد وتصرف':  Color(0xFFE65100),
    'تقنية':          Color(0xFF6A1B9A),
    'إعلامية':        Color(0xFF00838F),
    'آداب':           Color(0xFFAD1457),
    'علوم تجريبية':   Color(0xFF558B2F),
    'رياضة':          Color(0xFFD84315),
    'إرشاد':          Color(0xFF4527A0),
    'عام':            Color(0xFF37474F),
  };

  static Color branchColor(String branch) =>
      branches[branch] ?? primary;
}
