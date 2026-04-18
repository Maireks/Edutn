// ============================================================
// lib/scripts/create_admin.dart
// سكريبت إنشاء حساب SuperAdmin
//
// الاستخدام:
//   استدعِ CreateAdminHelper.createSuperAdmin() مرة واحدة فقط
//   من زر مؤقت في التطبيق أو من DevTools
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAdminHelper {
  static Future<void> createSuperAdmin({
    required String email,
    required String password,
  }) async {
    try {
      print('🔧 إنشاء حساب SuperAdmin...');

      // 1. إنشاء حساب في Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      print('✅ تم إنشاء الحساب: $uid');

      // 2. إضافة دور superAdmin في Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(uid)
          .set({
        'email': email,
        'role': 'superAdmin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إضافة صلاحية superAdmin');
      print('');
      print('══════════════════════════════');
      print('   بيانات الدخول:');
      print('   البريد: $email');
      print('   كلمة المرور: $password');
      print('   الدور: superAdmin');
      print('══════════════════════════════');

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ البريد مستخدم مسبقاً، جارٍ إضافة الصلاحية فقط...');
        // إضافة الصلاحية للمستخدم الموجود
        await _grantSuperAdminByEmail(email);
      } else {
        print('❌ خطأ: ${e.message}');
        rethrow;
      }
    }
  }

  static Future<void> _grantSuperAdminByEmail(String email) async {
    // جلب UID بالبريد الإلكتروني غير ممكن من العميل
    // استخدم Firebase Console بدلاً من ذلك
    print(
      '💡 افتح Firebase Console → Firestore → admins\n'
      '   أضف وثيقة بـ UID الخاص بـ $email\n'
      '   وأضف حقل: role = "superAdmin"',
    );
  }
}

// ─── مثال على الاستخدام ────────────────────────────────
// في صفحة مؤقتة أو في initState:
//
// ElevatedButton(
//   onPressed: () => CreateAdminHelper.createSuperAdmin(
//     email: 'admin@edtn.tn',
//     password: 'EduTN@Admin2024!',
//   ),
//   child: Text('إنشاء SuperAdmin'),
// )
