// ============================================================
// widgets/app_badge.dart - شارات وعلامات قابلة لإعادة الاستخدام
// ============================================================
import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final String? emoji;
  final double fontSize;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.emoji,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        emoji != null ? '$emoji $label' : label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── شارة الحالة ───
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static Color colorFor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.grey;
      default: return Colors.grey;
    }
  }

  static String labelFor(String status) {
    switch (status) {
      case 'pending': return '⏳ قيد الانتظار';
      case 'reviewed': return '🔍 تمت المراجعة';
      case 'resolved': return '✅ تم الحل';
      case 'rejected': return '❌ مرفوض';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        labelFor(status),
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
