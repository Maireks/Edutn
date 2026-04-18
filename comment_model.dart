// ============================================================
// models/comment_model.dart
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String lessonId;
  final String studentName;
  final String deviceId;
  final String comment;
  final Timestamp? createdAt;
  final bool isApproved;

  CommentModel({
    required this.id,
    required this.lessonId,
    required this.studentName,
    required this.deviceId,
    required this.comment,
    this.createdAt,
    this.isApproved = true,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      lessonId: d['lessonId'] ?? '',
      studentName: d['studentName'] ?? 'طالب مجهول',
      deviceId: d['deviceId'] ?? '',
      comment: d['comment'] ?? '',
      createdAt: d['createdAt'],
      isApproved: d['isApproved'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lessonId': lessonId,
        'studentName': studentName,
        'deviceId': deviceId,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'isApproved': isApproved,
      };

  String get formattedDate {
    if (createdAt == null) return '';
    final date = createdAt!.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
