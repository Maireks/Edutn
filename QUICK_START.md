# ⚡ EduTN — دليل البدء السريع

## الخطوات الـ 10 لتشغيل المشروع

---

### 1️⃣  إنشاء مشروع Firebase

```
https://console.firebase.google.com → New Project → "edtn-app"
```

### 2️⃣  تفعيل الخدمات الأربع

```
Authentication  → Email/Password ✅
Firestore       → Create database (production mode) ✅
Storage         → Get started ✅
Messaging       → تلقائي ✅
```

### 3️⃣  إضافة تطبيق Android

```
Package:   com.edtn.app
↓ تنزيل: google-services.json
↓ نسخه إلى: android/app/google-services.json
```

### 4️⃣  إضافة تطبيق iOS

```
Bundle ID: com.edtn.app
↓ تنزيل: GoogleService-Info.plist
↓ نسخه إلى: ios/Runner/GoogleService-Info.plist
```

### 5️⃣  توليد firebase_options.dart

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=edtn-app
# هذا يستبدل lib/firebase_options.dart بالقيم الحقيقية
```

### 6️⃣  تثبيت المكتبات

```bash
flutter pub get
cd ios && pod install && cd ..   # iOS فقط
```

### 7️⃣  رفع قواعد الأمان

```bash
firebase login
firebase deploy --only firestore:rules,storage
```

### 8️⃣  إنشاء أول SuperAdmin

**الطريقة الأسهل (Firebase Console):**
```
Authentication → Users → Add User
  Email:    admin@edtn.tn
  Password: Admin@2024!

ثم انسخ الـ UID

Firestore → admins → Add document
  Document ID: [الـ UID]
  email: "admin@edtn.tn"    (string)
  role:  "superAdmin"       (string)
```

### 9️⃣  رفع Cloud Functions (اختياري)

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 🔟  تشغيل التطبيق

```bash
flutter run -d android   # Android
flutter run -d ios       # iOS
```

---

## 🗂️ أول محتوى تجريبي

افتح لوحة التحكم (زر "إدارة" في الشاشة الرئيسية):

1. **أضف مستوى:** السنة التاسعة 📖
2. **أضف مادة:** الرياضيات (branch: علوم)
3. **أضف درس:** الدوال العددية

أو شغّل `SeedData.seedAll()` لإدخال بيانات تجريبية تلقائياً.

---

## 🏗️ ملخص الملفات الحرجة

| الملف | الغرض | يحتاج تعديل؟ |
|-------|--------|--------------|
| `lib/firebase_options.dart` | إعدادات Firebase | ✅ تلقائي بـ flutterfire |
| `android/app/google-services.json` | Android config | ✅ من Console |
| `ios/Runner/GoogleService-Info.plist` | iOS config | ✅ من Console |
| `firestore.rules` | قواعد الأمان | نشر بـ Firebase CLI |
| `functions/index.js` | إرسال إشعارات | نشر بـ Firebase CLI |

---

*EduTN — تعلم • طور نفسك • انجح 🇹🇳*
