// ============================================================
// widgets/lesson_card.dart - بطاقة الدرس
// ============================================================

import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../utils/app_theme.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2A3A5A) : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // رقم الدرس
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // المعلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        if (lesson.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            lesson.description.length > 60
                                ? '${lesson.description.substring(0, 60)}...'
                                : lesson.description,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                        const SizedBox(height: 8),
                        // تفاصيل
                        Row(
                          children: [
                            if (lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty)
                              _badge(Icons.picture_as_pdf, 'PDF', Colors.green),
                            const SizedBox(width: 6),
                            if (lesson.solvedExercises.isNotEmpty)
                              _badge(Icons.edit_note, 'تمارين', Colors.orange),
                            const Spacer(),
                            const Icon(Icons.star, size: 12, color: AppTheme.goldColor),
                            const SizedBox(width: 2),
                            Text(
                              lesson.averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.visibility_outlined, size: 12, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(
                              '${lesson.viewCount}',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
