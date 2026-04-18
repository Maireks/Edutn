// ============================================================
// utils/app_validators.dart - دوال التحقق من المدخلات
// ============================================================

class AppValidators {
  /// التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  /// التحقق من كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// حقل مطلوب
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  /// التحقق من طول النص
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.trim().length < min) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  /// التحقق من رقم
  static String? number(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return 'يجب إدخال رقم صحيح';
    }
    return null;
  }

  /// التحقق من رابط URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(
        r'^https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    if (!urlRegex.hasMatch(value.trim())) {
      return 'الرابط غير صحيح';
    }
    return null;
  }
}
