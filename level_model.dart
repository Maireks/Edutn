// ============================================================
// models/level_model.dart - نموذج المرحلة الدراسية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class LevelModel {
  final String id;
  final String name;
  final String? iconEmoji;
  final String? colorHex;
  final int order;

  LevelModel({
    required this.id,
    required this.name,
    this.iconEmoji,
    this.colorHex,
    this.order = 0,
  });

  // تحويل من Firestore
  factory LevelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LevelModel(
      id: doc.id,
      name: data['name'] ?? '',
      iconEmoji: data['iconEmoji'],
      colorHex: data['colorHex'],
      order: data['order'] ?? 0,
    );
  }

  // تحويل إلى Map لحفظه في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconEmoji': iconEmoji ?? '📚',
      'colorHex': colorHex ?? '#1565C0',
      'order': order,
    };
  }

  // نسخة معدلة
  LevelModel copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    String? colorHex,
    int? order,
  }) {
    return LevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      colorHex: colorHex ?? this.colorHex,
      order: order ?? this.order,
    );
  }
}
