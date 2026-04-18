// ============================================================
// services/device_service.dart - معرف الجهاز للطلاب
// الطلاب لا يحتاجون حساب - نستخدم معرف الجهاز
// ============================================================

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _deviceId;
  static const String _deviceIdKey = 'device_id';

  // جلب معرف الجهاز الفريد
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString(_deviceIdKey);

    if (savedId != null && savedId.isNotEmpty) {
      _deviceId = savedId;
      return _deviceId!;
    }

    // محاولة الحصول على معرف الجهاز الحقيقي
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        savedId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        savedId = iosInfo.identifierForVendor;
      }
    } catch (_) {}

    // fallback: UUID عشوائي
    savedId ??= const Uuid().v4();

    await prefs.setString(_deviceIdKey, savedId);
    _deviceId = savedId;
    return _deviceId!;
  }

  // جلب اسم الطالب المحفوظ
  Future<String> getSavedStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_name') ?? '';
  }

  // حفظ اسم الطالب
  Future<void> saveStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', name);
  }
}
