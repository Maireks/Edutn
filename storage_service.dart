// ============================================================
// services/storage_service.dart - خدمة Firebase Storage
// رفع ملفات PDF مع شريط تقدم
// ============================================================

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // ==========================================
  // رفع ملف PDF
  // ==========================================
  Future<UploadResult> uploadPDF({
    required File file,
    required String subjectId,
    Function(double)? onProgress, // callback لتتبع التقدم
  }) async {
    try {
      // اسم فريد للملف
      final fileName = '${_uuid.v4()}.pdf';
      final path = 'lessons/$subjectId/$fileName';

      // مرجع الملف في Storage
      final ref = _storage.ref().child(path);

      // بدء الرفع
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // متابعة التقدم
      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);
        }
      });

      // انتظار الانتهاء
      await uploadTask;

      // جلب رابط التنزيل
      final downloadUrl = await ref.getDownloadURL();

      return UploadResult(
        success: true,
        url: downloadUrl,
        fileName: fileName,
        path: path,
      );
    } on FirebaseException catch (e) {
      return UploadResult(
        success: false,
        error: 'فشل رفع الملف: ${e.message}',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: 'حدث خطأ أثناء رفع الملف.',
      );
    }
  }

  // ==========================================
  // حذف ملف من Storage
  // ==========================================
  Future<bool> deletePDF(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // تنزيل PDF
  // ==========================================
  Future<String?> getPDFDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}

// نتيجة الرفع
class UploadResult {
  final bool success;
  final String? url;
  final String? fileName;
  final String? path;
  final String? error;

  UploadResult({
    required this.success,
    this.url,
    this.fileName,
    this.path,
    this.error,
  });
}
