// ============================================================
// functions/index.js - Firebase Cloud Functions
// إرسال إشعارات FCM تلقائياً عند إضافة درس جديد
// ============================================================

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ─── إرسال إشعار عند إنشاء وثيقة في /notifications ───────
exports.sendPushNotification = functions.firestore
  .document('notifications/{notifId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // تجنب الإرسال المزدوج
    if (data.sent === true) return null;

    const message = {
      notification: {
        title: data.title || 'EduTN',
        body: data.body || '',
      },
      data: {
        type: data.type || 'general',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      // إرسال لجميع المشتركين في الموضوع
      topic: 'all_students',
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent:', response);

      // تحديث حالة الإرسال
      await snap.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });
      return response;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      await snap.ref.update({ sent: false, error: error.message });
      return null;
    }
  });

// ─── إرسال إشعار عند إضافة درس جديد ─────────────────────
exports.onNewLesson = functions.firestore
  .document('lessons/{lessonId}')
  .onCreate(async (snap, context) => {
    const lesson = snap.data();

    // لا ترسل إشعاراً للدروس غير المنشورة
    if (!lesson.isPublished) return null;

    // جلب اسم المادة
    let subjectName = 'مادة دراسية';
    try {
      const subjectDoc = await admin.firestore()
        .collection('subjects')
        .doc(lesson.subjectId)
        .get();
      if (subjectDoc.exists) {
        subjectName = subjectDoc.data().name;
      }
    } catch (e) {
      console.error('Could not fetch subject name:', e);
    }

    const message = {
      notification: {
        title: `📚 درس جديد: ${lesson.title}`,
        body: `تم إضافة درس جديد في مادة ${subjectName}`,
      },
      data: {
        type: 'new_lesson',
        lessonId: context.params.lessonId,
        subjectId: lesson.subjectId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: 'all_students',
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('✅ New lesson notification sent:', response);
      return response;
    } catch (error) {
      console.error('❌ Error:', error);
      return null;
    }
  });

// ─── تنظيف الدروس المحذوفة من البلاغات ──────────────────
exports.onLessonDeleted = functions.firestore
  .document('lessons/{lessonId}')
  .onDelete(async (snap, context) => {
    const lessonId = context.params.lessonId;
    const db = admin.firestore();

    // حذف كل التقييمات المرتبطة
    const ratingsQuery = await db.collection('ratings')
      .where('lessonId', '==', lessonId).get();
    const ratingDeletes = ratingsQuery.docs.map(d => d.ref.delete());

    // حذف كل التعليقات المرتبطة
    const commentsQuery = await db.collection('comments')
      .where('lessonId', '==', lessonId).get();
    const commentDeletes = commentsQuery.docs.map(d => d.ref.delete());

    // حذف كل البلاغات المرتبطة
    const reportsQuery = await db.collection('reports')
      .where('lessonId', '==', lessonId).get();
    const reportDeletes = reportsQuery.docs.map(d => d.ref.delete());

    await Promise.all([...ratingDeletes, ...commentDeletes, ...reportDeletes]);
    console.log(`✅ Cleaned up data for deleted lesson: ${lessonId}`);
    return null;
  });
