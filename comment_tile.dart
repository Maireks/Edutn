// ============================================================
// widgets/comment_tile.dart - بطاقة التعليق
// ============================================================
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isAdmin;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.isAdmin = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A5A) : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس التعليق
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                child: Text(
                  _getInitial(comment.studentName),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.studentName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (comment.formattedDate.isNotEmpty)
                      Text(
                        comment.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (isAdmin && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            comment.comment,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
              height: 1.7,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // أخذ الحرف الأول بأمان بدون package
  String _getInitial(String name) {
    if (name.isEmpty) return '؟';
    final runes = name.runes.toList();
    return String.fromCharCode(runes.first);
  }
}
