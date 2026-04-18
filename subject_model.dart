// ============================================================
// models/subject_model.dart - نموذج المادة الدراسية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String levelId;
  final String branch;
  final String academicYear;
  final String category;
  final String? iconEmoji;
  final String? colorHex;
  final int order;

  SubjectModel({
    required this.id,
    required this.name,
    required this.levelId,
    required this.branch,
    required this.academicYear,
    required this.category,
    this.iconEmoji,
    this.colorHex,
    this.order = 0,
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      levelId: data['levelId'] ?? '',
      branch: data['branch'] ?? '',
      academicYear: data['academicYear'] ?? '',
      category: data['category'] ?? '',
      iconEmoji: data['iconEmoji'],
      colorHex: data['colorHex'],
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'levelId': levelId,
      'branch': branch,
      'academicYear': academicYear,
      'category': category,
      'iconEmoji': iconEmoji ?? '📘',
      'colorHex': colorHex ?? '#1565C0',
      'order': order,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? levelId,
    String? branch,
    String? academicYear,
    String? category,
    String? iconEmoji,
    String? colorHex,
    int? order,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      levelId: levelId ?? this.levelId,
      branch: branch ?? this.branch,
      academicYear: academicYear ?? this.academicYear,
      category: category ?? this.category,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      colorHex: colorHex ?? this.colorHex,
      order: order ?? this.order,
    );
  }
}
