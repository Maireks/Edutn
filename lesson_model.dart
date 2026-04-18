// ============================================================
// models/lesson_model.dart - نموذج الدرس
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String solvedExercises;
  final String? pdfUrl;
  final String? pdfName;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final int viewCount;
  final double averageRating;
  final int ratingCount;
  final bool isPublished;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.solvedExercises,
    this.pdfUrl,
    this.pdfName,
    this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.isPublished = true,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      solvedExercises: data['solvedExercises'] ?? '',
      pdfUrl: data['pdfUrl'],
      pdfName: data['pdfName'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      viewCount: data['viewCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      isPublished: data['isPublished'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'solvedExercises': solvedExercises,
      'pdfUrl': pdfUrl,
      'pdfName': pdfName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'viewCount': viewCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'isPublished': isPublished,
    };
  }

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? solvedExercises,
    String? pdfUrl,
    String? pdfName,
    Timestamp? createdAt,
    int? viewCount,
    double? averageRating,
    int? ratingCount,
    bool? isPublished,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      solvedExercises: solvedExercises ?? this.solvedExercises,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pdfName: pdfName ?? this.pdfName,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  // تنسيق التاريخ
  String get formattedDate {
    if (createdAt == null) return '';
    final date = createdAt!.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
