// ============================================================
// screens/admin/notification_send_screen.dart
// إرسال إشعارات دفع للطلاب من لوحة التحكم
// ============================================================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class NotificationSendScreen extends StatefulWidget {
  const NotificationSendScreen({super.key});

  @override
  State<NotificationSendScreen> createState() =>
      _NotificationSendScreenState();
}

class _NotificationSendScreenState
    extends State<NotificationSendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      // حفظ الإشعار في Firestore - تُرسله Cloud Function تلقائياً
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'type': 'manual',
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });

      if (mounted) {
        _titleCtrl.clear();
        _bodyCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ تم إرسال الإشعار بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e',
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال إشعار'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // بطاقة المعاينة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('🎓', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'EduTN',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'الآن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _titleCtrl.text.isEmpty ? 'عنوان الإشعار' : _titleCtrl.text,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: _titleCtrl.text.isEmpty
                          ? Colors.white38
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bodyCtrl.text.isEmpty ? 'نص الإشعار' : _bodyCtrl.text,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: _bodyCtrl.text.isEmpty
                          ? Colors.white38
                          : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // عنوان الإشعار
            TextFormField(
              controller: _titleCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'عنوان الإشعار *',
                hintText: 'مثال: درس جديد في الرياضيات',
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 14),

            // نص الإشعار
            TextFormField(
              controller: _bodyCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'نص الإشعار *',
                hintText: 'اكتب محتوى الإشعار هنا...',
                prefixIcon: Icon(Icons.message_outlined),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 28),

            // زر الإرسال
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text(
                  'إرسال الإشعار لجميع الطلاب',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                '⚠️ سيُرسل هذا الإشعار لجميع مستخدمي التطبيق',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // سجل الإشعارات السابقة
            const Text(
              'الإشعارات السابقة',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _buildNotificationHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text('لا توجد إشعارات سابقة',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppTheme.primaryColor, size: 20),
              ),
              title: Text(
                d['title'] ?? '',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                d['body'] ?? '',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (d['sent'] == true ? Colors.green : Colors.orange)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d['sent'] == true ? 'أُرسل' : 'في الانتظار',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: d['sent'] == true ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
