// ============================================================
// services/firebase_service.dart - خدمة Firebase الرئيسية
// جميع عمليات قراءة وكتابة وحذف من Firestore
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level_model.dart';
import '../models/subject_model.dart';
import '../models/lesson_model.dart';
import '../models/models.dart';
import '../utils/app_constants.dart';

class FirebaseService {
  // نسخة واحدة من الخدمة (Singleton)
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // مرجع Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // LEVELS - المستويات الدراسية
  // ==========================================

  // جلب جميع المستويات كـ Stream (يتحدث تلقائياً)
  Stream<List<LevelModel>> getLevelsStream() {
    return _db
        .collection(AppConstants.colLevels)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LevelModel.fromFirestore(doc)).toList());
  }

  // جلب مستوى واحد
  Future<LevelModel?> getLevelById(String levelId) async {
    final doc = await _db.collection(AppConstants.colLevels).doc(levelId).get();
    if (doc.exists) return LevelModel.fromFirestore(doc);
    return null;
  }

  // إضافة مستوى جديد
  Future<String> addLevel(LevelModel level) async {
    final docRef = await _db
        .collection(AppConstants.colLevels)
        .add(level.toFirestore());
    return docRef.id;
  }

  // تعديل مستوى
  Future<void> updateLevel(LevelModel level) async {
    await _db
        .collection(AppConstants.colLevels)
        .doc(level.id)
        .update(level.toFirestore());
  }

  // حذف مستوى
  Future<void> deleteLevel(String levelId) async {
    await _db.collection(AppConstants.colLevels).doc(levelId).delete();
  }

  // ==========================================
  // SUBJECTS - المواد الدراسية
  // ==========================================

  // جلب مواد مستوى معين
  Stream<List<SubjectModel>> getSubjectsStream(String levelId) {
    return _db
        .collection(AppConstants.colSubjects)
        .where('levelId', isEqualTo: levelId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectModel.fromFirestore(doc))
            .toList());
  }

  // جلب مواد بفرع معين
  Stream<List<SubjectModel>> getSubjectsByBranch(String branch) {
    return _db
        .collection(AppConstants.colSubjects)
        .where('branch', isEqualTo: branch)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectModel.fromFirestore(doc))
            .toList());
  }

  // جلب جميع المواد (للأدمن)
  Stream<List<SubjectModel>> getAllSubjectsStream() {
    return _db
        .collection(AppConstants.colSubjects)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectModel.fromFirestore(doc))
            .toList());
  }

  // جلب مادة واحدة
  Future<SubjectModel?> getSubjectById(String subjectId) async {
    final doc =
        await _db.collection(AppConstants.colSubjects).doc(subjectId).get();
    if (doc.exists) return SubjectModel.fromFirestore(doc);
    return null;
  }

  // إضافة مادة
  Future<String> addSubject(SubjectModel subject) async {
    final docRef = await _db
        .collection(AppConstants.colSubjects)
        .add(subject.toFirestore());
    return docRef.id;
  }

  // تعديل مادة
  Future<void> updateSubject(SubjectModel subject) async {
    await _db
        .collection(AppConstants.colSubjects)
        .doc(subject.id)
        .update(subject.toFirestore());
  }

  // حذف مادة
  Future<void> deleteSubject(String subjectId) async {
    await _db.collection(AppConstants.colSubjects).doc(subjectId).delete();
  }

  // ==========================================
  // LESSONS - الدروس
  // ==========================================

  // جلب دروس مادة معينة
  Stream<List<LessonModel>> getLessonsStream(String subjectId) {
    return _db
        .collection(AppConstants.colLessons)
        .where('subjectId', isEqualTo: subjectId)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LessonModel.fromFirestore(doc)).toList());
  }

  // جلب جميع الدروس (للأدمن)
  Stream<List<LessonModel>> getAllLessonsStream() {
    return _db
        .collection(AppConstants.colLessons)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LessonModel.fromFirestore(doc)).toList());
  }

  // جلب درس واحد
  Future<LessonModel?> getLessonById(String lessonId) async {
    final doc =
        await _db.collection(AppConstants.colLessons).doc(lessonId).get();
    if (doc.exists) return LessonModel.fromFirestore(doc);
    return null;
  }

  // البحث في الدروس
  Future<List<LessonModel>> searchLessons(String query) async {
    // Firestore لا يدعم البحث النصي الكامل مباشرة
    // نجلب الكل ونفلتر محلياً (للمشاريع الصغيرة)
    final snapshot = await _db
        .collection(AppConstants.colLessons)
        .where('isPublished', isEqualTo: true)
        .get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => LessonModel.fromFirestore(doc))
        .where((lesson) =>
            lesson.title.toLowerCase().contains(lowerQuery) ||
            lesson.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // إضافة درس
  Future<String> addLesson(LessonModel lesson) async {
    final docRef = await _db
        .collection(AppConstants.colLessons)
        .add(lesson.toFirestore());
    return docRef.id;
  }

  // تعديل درس
  Future<void> updateLesson(LessonModel lesson) async {
    await _db
        .collection(AppConstants.colLessons)
        .doc(lesson.id)
        .update(lesson.toFirestore());
  }

  // حذف درس
  Future<void> deleteLesson(String lessonId) async {
    await _db.collection(AppConstants.colLessons).doc(lessonId).delete();
  }

  // زيادة عداد المشاهدات
  Future<void> incrementViewCount(String lessonId) async {
    await _db.collection(AppConstants.colLessons).doc(lessonId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // ==========================================
  // RATINGS - التقييمات
  // ==========================================

  // جلب تقييمات درس معين
  Stream<List<RatingModel>> getRatingsStream(String lessonId) {
    return _db
        .collection(AppConstants.colRatings)
        .where('lessonId', isEqualTo: lessonId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList());
  }

  // إضافة أو تعديل تقييم
  Future<void> addOrUpdateRating(RatingModel rating) async {
    // التحقق من وجود تقييم سابق من نفس الجهاز
    final existing = await _db
        .collection(AppConstants.colRatings)
        .where('lessonId', isEqualTo: rating.lessonId)
        .where('deviceId', isEqualTo: rating.deviceId)
        .get();

    if (existing.docs.isNotEmpty) {
      // تعديل التقييم الموجود
      await _db
          .collection(AppConstants.colRatings)
          .doc(existing.docs.first.id)
          .update({'stars': rating.stars});
    } else {
      // إضافة تقييم جديد
      await _db.collection(AppConstants.colRatings).add(rating.toFirestore());
    }

    // تحديث متوسط التقييم في الدرس
    await _updateLessonRating(rating.lessonId);
  }

  // تحديث متوسط التقييم
  Future<void> _updateLessonRating(String lessonId) async {
    final ratings = await _db
        .collection(AppConstants.colRatings)
        .where('lessonId', isEqualTo: lessonId)
        .get();

    if (ratings.docs.isEmpty) return;

    final total = ratings.docs
        .map((doc) => (doc.data()['stars'] as num).toDouble())
        .reduce((a, b) => a + b);
    final average = total / ratings.docs.length;

    await _db.collection(AppConstants.colLessons).doc(lessonId).update({
      'averageRating': average,
      'ratingCount': ratings.docs.length,
    });
  }

  // ==========================================
  // COMMENTS - التعليقات
  // ==========================================

  // جلب تعليقات درس معين
  Stream<List<CommentModel>> getCommentsStream(String lessonId) {
    return _db
        .collection(AppConstants.colComments)
        .where('lessonId', isEqualTo: lessonId)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // جلب جميع التعليقات (للأدمن)
  Stream<List<CommentModel>> getAllCommentsStream() {
    return _db
        .collection(AppConstants.colComments)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // إضافة تعليق
  Future<void> addComment(CommentModel comment) async {
    await _db.collection(AppConstants.colComments).add(comment.toFirestore());
  }

  // الموافقة على تعليق
  Future<void> approveComment(String commentId) async {
    await _db
        .collection(AppConstants.colComments)
        .doc(commentId)
        .update({'isApproved': true});
  }

  // حذف تعليق
  Future<void> deleteComment(String commentId) async {
    await _db.collection(AppConstants.colComments).doc(commentId).delete();
  }

  // ==========================================
  // REPORTS - البلاغات
  // ==========================================

  // جلب جميع البلاغات
  Stream<List<ReportModel>> getReportsStream() {
    return _db
        .collection(AppConstants.colReports)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  // جلب بلاغات بحالة معينة
  Stream<List<ReportModel>> getReportsByStatus(String status) {
    return _db
        .collection(AppConstants.colReports)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  // إضافة بلاغ
  Future<void> addReport(ReportModel report) async {
    await _db.collection(AppConstants.colReports).add(report.toFirestore());
  }

  // تحديث حالة البلاغ
  Future<void> updateReportStatus(String reportId, String status) async {
    await _db
        .collection(AppConstants.colReports)
        .doc(reportId)
        .update({'status': status});
  }

  // حذف بلاغ
  Future<void> deleteReport(String reportId) async {
    await _db.collection(AppConstants.colReports).doc(reportId).delete();
  }

  // ==========================================
  // ADMINS - المدراء
  // ==========================================

  // التحقق من دور المستخدم
  Future<String?> getAdminRole(String uid) async {
    final doc = await _db.collection(AppConstants.colAdmins).doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  // إضافة مدير جديد
  Future<void> addAdmin(String uid, String email, String role) async {
    await _db.collection(AppConstants.colAdmins).doc(uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // STATISTICS - الإحصائيات
  // ==========================================

  // جلب إحصائيات عامة للوحة التحكم
  Future<Map<String, int>> getDashboardStats() async {
    final results = await Future.wait([
      _db.collection(AppConstants.colLevels).count().get(),
      _db.collection(AppConstants.colSubjects).count().get(),
      _db.collection(AppConstants.colLessons).count().get(),
      _db
          .collection(AppConstants.colReports)
          .where('status', isEqualTo: 'pending')
          .count()
          .get(),
    ]);

    return {
      'levels': results[0].count ?? 0,
      'subjects': results[1].count ?? 0,
      'lessons': results[2].count ?? 0,
      'pendingReports': results[3].count ?? 0,
    };
  }
}
