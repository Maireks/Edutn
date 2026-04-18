// ============================================================
// widgets/level_card.dart - بطاقة المستوى الدراسي
// ============================================================

import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../utils/app_theme.dart';

class LevelCard extends StatelessWidget {
  final LevelModel level;
  final VoidCallback onTap;

  const LevelCard({super.key, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(level.colorHex ?? '#1565C0');
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [color, color.withOpacity(0.75)],
              ),
            ),
            child: Stack(
              children: [
                // دائرة زخرفية
                Positioned(
                  left: -20, top: -20,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                Positioned(
                  left: 40, bottom: -30,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                // المحتوى
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // أيقونة
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(level.iconEmoji ?? '📚', style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // النص
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              level.name,
                              style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اضغط لعرض المواد',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white.withOpacity(0.75)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
