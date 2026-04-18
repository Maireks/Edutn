// ============================================================
// utils/date_formatter.dart - تنسيق التواريخ بالعربية
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static const List<String> _monthsAr = [
    '', 'جانفي', 'فيفري', 'مارس', 'أفريل',
    'ماي', 'جوان', 'جويلية', 'أوت',
    'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> _daysAr = [
    '', 'الإثنين', 'الثلاثاء', 'الأربعاء',
    'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  /// تنسيق: 15 جانفي 2024
  static String format(DateTime date) {
    return '${date.day} ${_monthsAr[date.month]} ${date.year}';
  }

  /// تنسيق من Firestore Timestamp
  static String fromTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return format(timestamp.toDate());
  }

  /// الوقت المنقضي: منذ 3 دقائق / منذ يومين
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'منذ لحظات';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1)    return 'أمس';
    if (diff.inDays < 7)     return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30)    return 'منذ ${(diff.inDays / 7).round()} أسابيع';
    if (diff.inDays < 365)   return 'منذ ${(diff.inDays / 30).round()} أشهر';
    return 'منذ ${(diff.inDays / 365).round()} سنوات';
  }

  static String timeAgoFromTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return timeAgo(timestamp.toDate());
  }
}
