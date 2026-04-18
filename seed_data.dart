// ============================================================
// scripts/seed_data.dart
// سكريبت لإدخال بيانات تجريبية في Firestore
// شغّله مرة واحدة فقط عند بدء المشروع
// ============================================================
//
// طريقة التشغيل:
//   1. أضف هذا الملف مؤقتاً
//   2. استدعِ seedAll() من main() أو من زر في التطبيق
//   3. بعد الإدخال، احذف أو عطّل هذا الملف
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    print('🌱 بدء إدخال البيانات التجريبية...');
    await _seedLevels();
    await _seedSubjects();
    await _seedLessons();
    print('✅ تم إدخال جميع البيانات التجريبية بنجاح!');
  }

  // ─── المستويات الدراسية ────────────────────────────────────
  static Future<void> _seedLevels() async {
    final levels = [
      {
        'id': 'level_7',
        'name': 'السنة السابعة',
        'iconEmoji': '📗',
        'colorHex': '#43A047',
        'order': 1,
      },
      {
        'id': 'level_8',
        'name': 'السنة الثامنة',
        'iconEmoji': '📘',
        'colorHex': '#1E88E5',
        'order': 2,
      },
      {
        'id': 'level_9',
        'name': 'السنة التاسعة',
        'iconEmoji': '📙',
        'colorHex': '#FB8C00',
        'order': 3,
      },
      {
        'id': 'level_s1',
        'name': 'السنة الأولى ثانوي',
        'iconEmoji': '📕',
        'colorHex': '#E53935',
        'order': 4,
      },
      {
        'id': 'level_s2',
        'name': 'السنة الثانية ثانوي',
        'iconEmoji': '📓',
        'colorHex': '#8E24AA',
        'order': 5,
      },
      {
        'id': 'level_s3',
        'name': 'السنة الثالثة ثانوي',
        'iconEmoji': '📒',
        'colorHex': '#00897B',
        'order': 6,
      },
      {
        'id': 'level_bac',
        'name': 'السنة الرابعة (باكالوريا)',
        'iconEmoji': '🎓',
        'colorHex': '#2E7D32',
        'order': 7,
      },
    ];

    for (final level in levels) {
      final id = level.remove('id') as String;
      await _db.collection('levels').doc(id).set(level);
      print('  ✅ مستوى: ${level['name']}');
    }
  }

  // ─── المواد الدراسية ───────────────────────────────────────
  static Future<void> _seedSubjects() async {
    final subjects = [
      // ── السنة التاسعة ──
      {
        'id': 'math_9',
        'name': 'الرياضيات',
        'levelId': 'level_9',
        'branch': 'علوم',
        'academicYear': 'السنة التاسعة',
        'category': 'إعدادي',
        'iconEmoji': '📐',
        'colorHex': '#1565C0',
        'order': 1,
      },
      {
        'id': 'arabic_9',
        'name': 'اللغة العربية',
        'levelId': 'level_9',
        'branch': 'آداب',
        'academicYear': 'السنة التاسعة',
        'category': 'إعدادي',
        'iconEmoji': '📚',
        'colorHex': '#AD1457',
        'order': 2,
      },
      {
        'id': 'science_9',
        'name': 'علوم الحياة والأرض',
        'levelId': 'level_9',
        'branch': 'علوم',
        'academicYear': 'السنة التاسعة',
        'category': 'إعدادي',
        'iconEmoji': '🔬',
        'colorHex': '#2E7D32',
        'order': 3,
      },
      {
        'id': 'physics_9',
        'name': 'الفيزياء والكيمياء',
        'levelId': 'level_9',
        'branch': 'علوم',
        'academicYear': 'السنة التاسعة',
        'category': 'إعدادي',
        'iconEmoji': '⚗️',
        'colorHex': '#6A1B9A',
        'order': 4,
      },
      // ── باكالوريا علوم ──
      {
        'id': 'math_bac_sciences',
        'name': 'الرياضيات',
        'levelId': 'level_bac',
        'branch': 'علوم',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '📐',
        'colorHex': '#1565C0',
        'order': 1,
      },
      {
        'id': 'physics_bac',
        'name': 'الفيزياء',
        'levelId': 'level_bac',
        'branch': 'علوم',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '⚡',
        'colorHex': '#E65100',
        'order': 2,
      },
      {
        'id': 'biology_bac',
        'name': 'علوم الحياة والأرض',
        'levelId': 'level_bac',
        'branch': 'علوم',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '🌿',
        'colorHex': '#2E7D32',
        'order': 3,
      },
      // ── باكالوريا اقتصاد ──
      {
        'id': 'econ_bac',
        'name': 'الاقتصاد والتصرف',
        'levelId': 'level_bac',
        'branch': 'اقتصاد وتصرف',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '📊',
        'colorHex': '#E65100',
        'order': 1,
      },
      {
        'id': 'math_bac_econ',
        'name': 'الرياضيات',
        'levelId': 'level_bac',
        'branch': 'اقتصاد وتصرف',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '📐',
        'colorHex': '#1565C0',
        'order': 2,
      },
      // ── باكالوريا إعلامية ──
      {
        'id': 'info_bac',
        'name': 'الإعلامية',
        'levelId': 'level_bac',
        'branch': 'إعلامية',
        'academicYear': 'السنة الرابعة (باكالوريا)',
        'category': 'ثانوي',
        'iconEmoji': '💻',
        'colorHex': '#00838F',
        'order': 1,
      },
    ];

    for (final subject in subjects) {
      final id = subject.remove('id') as String;
      await _db.collection('subjects').doc(id).set(subject);
      print('  ✅ مادة: ${subject['name']} - ${subject['academicYear']}');
    }
  }

  // ─── الدروس ────────────────────────────────────────────────
  static Future<void> _seedLessons() async {
    final lessons = [
      {
        'id': 'lesson_functions_intro',
        'title': 'الدوال العددية - مقدمة',
        'description':
            'في هذا الدرس نتعرف على مفهوم الدالة العددية وتعريفها الرياضي وأنواعها الأساسية. '
            'سنتناول مجال التعريف وطريقة حسابه لأنواع مختلفة من الدوال.',
        'subjectId': 'math_9',
        'solvedExercises':
            '📝 تمرين 1:\nأوجد مجال تعريف الدالة f حيث:\nf(x) = 1/(x-3)\n'
            '✅ الحل: الشرط هو x-3 ≠ 0 أي x ≠ 3\n'
            'إذن: Df = ℝ\\{3}\n\n'
            '📝 تمرين 2:\nأوجد مجال تعريف: g(x) = √(2x-4)\n'
            '✅ الحل: الشرط 2x-4 ≥ 0، إذن x ≥ 2\n'
            'Dg = [2, +∞[',
        'pdfUrl': null,
        'isPublished': true,
        'viewCount': 0,
        'averageRating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_limits',
        'title': 'النهايات - التعريف والحساب',
        'description':
            'درس شامل في حساب نهايات الدوال عند نقطة أو عند اللانهاية. '
            'نتناول قواعد الحساب والحالات المتعينة وطرق رفعها.',
        'subjectId': 'math_bac_sciences',
        'solvedExercises':
            '📝 تمرين 1:\nاحسب: lim(x→2) (x²-4)/(x-2)\n'
            '✅ الحل: بالتحليل: (x²-4) = (x-2)(x+2)\n'
            'النهاية = lim(x→2) (x+2) = 4\n\n'
            '📝 تمرين 2:\nاحسب: lim(x→+∞) (3x²+2x)/(x²-1)\n'
            '✅ الحل: نقسم على x²\nالنهاية = 3/1 = 3',
        'pdfUrl': null,
        'isPublished': true,
        'viewCount': 0,
        'averageRating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_derivatives',
        'title': 'الاشتقاق وقواعده',
        'description':
            'درس متكامل في حساب مشتقة الدوال. نتناول تعريف المشتقة، قواعد الاشتقاق، '
            'مشتقات الدوال الأساسية وتطبيقاتها في دراسة تغيرات الدوال.',
        'subjectId': 'math_bac_sciences',
        'solvedExercises':
            '📝 قواعد الاشتقاق:\n'
            '• (u+v)\' = u\' + v\'\n'
            '• (u×v)\' = u\'v + uv\'\n'
            '• (u/v)\' = (u\'v - uv\')/v²\n\n'
            '📝 تمرين:\nاشتق f(x) = x³ - 2x² + 5x - 1\n'
            '✅ f\'(x) = 3x² - 4x + 5',
        'pdfUrl': null,
        'isPublished': true,
        'viewCount': 0,
        'averageRating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_python_intro',
        'title': 'مقدمة في برمجة Python',
        'description':
            'تعرف على لغة البرمجة Python وأساسياتها. نتناول المتغيرات، أنواع البيانات، '
            'الشروط، الحلقات، والدوال في لغة Python.',
        'subjectId': 'info_bac',
        'solvedExercises':
            '📝 مثال 1 - المتغيرات:\n'
            'name = "أحمد"\n'
            'age = 18\n'
            'print(f"مرحبا {name}, عمرك {age}")\n\n'
            '📝 مثال 2 - الحلقات:\n'
            'for i in range(1, 6):\n'
            '    print(i)\n'
            '# النتيجة: 1 2 3 4 5',
        'pdfUrl': null,
        'isPublished': true,
        'viewCount': 0,
        'averageRating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_supply_demand',
        'title': 'العرض والطلب في السوق',
        'description':
            'درس في أساسيات الاقتصاد: قانونا العرض والطلب، محددات كل منهما، '
            'سعر التوازن وكيفية تحقيقه في السوق الحرة.',
        'subjectId': 'econ_bac',
        'solvedExercises':
            '📝 تعريفات أساسية:\n'
            '• الطلب: الكميات التي يرغب المستهلكون شراؤها عند أسعار مختلفة\n'
            '• العرض: الكميات التي يرغب المنتجون بيعها عند أسعار مختلفة\n\n'
            '📝 قانون الطلب:\n'
            'عندما يرتفع السعر → ينخفض الطلب (علاقة عكسية)\n\n'
            '📝 قانون العرض:\n'
            'عندما يرتفع السعر → يرتفع العرض (علاقة طردية)',
        'pdfUrl': null,
        'isPublished': true,
        'viewCount': 0,
        'averageRating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final lesson in lessons) {
      final id = lesson.remove('id') as String;
      await _db.collection('lessons').doc(id).set(lesson);
      print('  ✅ درس: ${lesson['title']}');
    }
  }
}
