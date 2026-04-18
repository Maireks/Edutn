// ============================================================
// utils/app_constants.dart - ثوابت التطبيق
// ============================================================

class AppConstants {
  // اسم التطبيق
  static const String appName = 'EduTN';
  static const String appNameAr = 'منصة التعليم التونسية';

  // الفروع التونسية
  static const List<String> tunisianBranches = [
    'علوم',
    'رياضيات',
    'اقتصاد وتصرف',
    'تقنية',
    'إعلامية',
    'آداب',
    'علوم تجريبية',
    'رياضة',
    'إرشاد',
    'عام',
  ];

  // المراحل الدراسية
  static const List<String> academicYears = [
    'السنة السابعة',
    'السنة الثامنة',
    'السنة التاسعة',
    'السنة أولى ثانوي',
    'السنة الثانية ثانوي',
    'السنة الثالثة ثانوي',
    'السنة الرابعة ثانوي',
    'تحضيري',
  ];

  // التصنيفات
  static const List<String> categories = [
    'إعدادي',
    'ثانوي',
    'تحضيري',
  ];

  // أنواع البلاغات
  static const List<String> reportTypes = [
    'خطأ في المحتوى',
    'محتوى مفقود',
    'رابط تالف',
    'ملف PDF لا يعمل',
    'اقتراح تحسين',
    'أخرى',
  ];

  // حالات البلاغ
  static const String reportPending = 'pending';
  static const String reportReviewed = 'reviewed';
  static const String reportResolved = 'resolved';
  static const String reportRejected = 'rejected';

  // أدوار المدراء
  static const String roleSuperAdmin = 'superAdmin';
  static const String roleAdmin = 'admin';
  static const String roleEditor = 'editor';

  // مجموعات Firestore
  static const String colLevels = 'levels';
  static const String colSubjects = 'subjects';
  static const String colLessons = 'lessons';
  static const String colRatings = 'ratings';
  static const String colComments = 'comments';
  static const String colReports = 'reports';
  static const String colAdmins = 'admins';
  static const String colNotifications = 'notifications';

  // الرسوم المتحركة
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);

  // ألوان الفروع
  static const Map<String, int> branchColors = {
    'علوم': 0xFF2E7D32,
    'رياضيات': 0xFF1565C0,
    'اقتصاد وتصرف': 0xFFE65100,
    'تقنية': 0xFF6A1B9A,
    'إعلامية': 0xFF00838F,
    'آداب': 0xFFAD1457,
    'علوم تجريبية': 0xFF558B2F,
    'رياضة': 0xFFD84315,
    'إرشاد': 0xFF4527A0,
    'عام': 0xFF37474F,
  };

  // أيقونات الفروع
  static const Map<String, String> branchIcons = {
    'علوم': '🔬',
    'رياضيات': '📐',
    'اقتصاد وتصرف': '📊',
    'تقنية': '⚙️',
    'إعلامية': '💻',
    'آداب': '📚',
    'علوم تجريبية': '🧪',
    'رياضة': '⚽',
    'إرشاد': '🧭',
    'عام': '📖',
  };
}
