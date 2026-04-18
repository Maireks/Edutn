// ============================================================
// models/report_model.dart
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String lessonId;
  final String studentName;
  final String deviceId;
  final String type;
  final String message;
  final Timestamp? createdAt;
  final String status;

  ReportModel({
    required this.id,
    required this.lessonId,
    required this.studentName,
    required this.deviceId,
    required this.type,
    required this.message,
    this.createdAt,
    this.status = 'pending',
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      lessonId: d['lessonId'] ?? '',
      studentName: d['studentName'] ?? 'مجهول',
      deviceId: d['deviceId'] ?? '',
      type: d['type'] ?? '',
      message: d['message'] ?? '',
      createdAt: d['createdAt'],
      status: d['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lessonId': lessonId,
        'studentName': studentName,
        'deviceId': deviceId,
        'type': type,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status,
      };

  String get formattedDate {
    if (createdAt == null) return '';
    final date = createdAt!.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String get statusAr {
    switch (status) {
      case 'pending':   return 'قيد الانتظار';
      case 'reviewed':  return 'تمت المراجعة';
      case 'resolved':  return 'تم الحل';
      case 'rejected':  return 'مرفوض';
      default:          return 'غير معروف';
    }
  }
}
