// ============================================================
// models/rating_model.dart
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String lessonId;
  final String studentName;
  final String deviceId;
  final int stars;
  final Timestamp? createdAt;

  RatingModel({
    required this.id,
    required this.lessonId,
    required this.studentName,
    required this.deviceId,
    required this.stars,
    this.createdAt,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      lessonId: d['lessonId'] ?? '',
      studentName: d['studentName'] ?? 'طالب مجهول',
      deviceId: d['deviceId'] ?? '',
      stars: d['stars'] ?? 0,
      createdAt: d['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lessonId': lessonId,
        'studentName': studentName,
        'deviceId': deviceId,
        'stars': stars,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
