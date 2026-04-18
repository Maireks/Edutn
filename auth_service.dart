// ============================================================
// services/auth_service.dart - خدمة المصادقة
// تسجيل دخول الأدمن فقط عبر Firebase Auth
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // Stream لحالة تسجيل الدخول
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==========================================
  // تسجيل الدخول
  // ==========================================
  Future<AuthResult> signInAdmin(String email, String password) async {
    try {
      // تسجيل الدخول عبر Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'فشل تسجيل الدخول. حاول مرة أخرى.',
        );
      }

      // التحقق من صلاحية الأدمن في Firestore
      final adminDoc = await _db
          .collection(AppConstants.colAdmins)
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) {
        // المستخدم ليس أدمن - تسجيل خروج فوري
        await _auth.signOut();
        return AuthResult(
          success: false,
          error: 'ليس لديك صلاحية الوصول إلى لوحة التحكم.',
        );
      }

      final role = adminDoc.data()?['role'] as String?;

      return AuthResult(
        success: true,
        uid: user.uid,
        email: user.email,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: _getArabicError(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'حدث خطأ غير متوقع. حاول مرة أخرى.',
      );
    }
  }

  // ==========================================
  // تسجيل الخروج
  // ==========================================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================================
  // التحقق من الدور
  // ==========================================
  Future<String?> getCurrentAdminRole() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _db
        .collection(AppConstants.colAdmins)
        .doc(user.uid)
        .get();

    return doc.data()?['role'] as String?;
  }

  // تحويل رموز الخطأ إلى عربي
  String _getArabicError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'too-many-requests':
        return 'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً.';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت. تحقق من اتصالك.';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة.';
      default:
        return 'حدث خطأ. حاول مرة أخرى. ($code)';
    }
  }
}

// نتيجة تسجيل الدخول
class AuthResult {
  final bool success;
  final String? error;
  final String? uid;
  final String? email;
  final String? role;

  AuthResult({
    required this.success,
    this.error,
    this.uid,
    this.email,
    this.role,
  });
}
