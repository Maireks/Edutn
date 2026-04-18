// ============================================================
// screens/admin/reports_screen.dart - إدارة البلاغات
// ============================================================

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _service = FirebaseService();
  late TabController _tabCtrl;

  final List<Map<String, String>> _tabs = [
    {'label': 'الكل', 'status': 'all'},
    {'label': '⏳ جديد', 'status': AppConstants.reportPending},
    {'label': '🔍 مراجعة', 'status': AppConstants.reportReviewed},
    {'label': '✅ محلول', 'status': AppConstants.reportResolved},
    {'label': '❌ مرفوض', 'status': AppConstants.reportRejected},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البلاغات'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _tabs.map((t) => _buildReportsList(t['status']!)).toList(),
      ),
    );
  }

  Widget _buildReportsList(String status) {
    final stream = status == 'all'
        ? _service.getReportsStream()
        : _service.getReportsByStatus(status);

    return StreamBuilder<List<ReportModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚩', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  status == 'all' ? 'لا توجد بلاغات' : 'لا توجد بلاغات في هذه الحالة',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (_, i) => _buildReportCard(reports[i]),
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final statusColor = _statusColor(report.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    report.statusAr,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
                const Spacer(),
                Text(
                  report.formattedDate,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // نوع البلاغ
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 16, color: AppTheme.accentColor),
                const SizedBox(width: 6),
                Text(
                  report.type,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // الرسالة
            if (report.message.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.message,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // مرسل البلاغ
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(report.studentName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.article_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'درس: ${report.lessonId.substring(0, 8)}...',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // أزرار تحديث الحالة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _statusButton(report, AppConstants.reportReviewed, '🔍 مراجعة', Colors.orange),
                  const SizedBox(width: 6),
                  _statusButton(report, AppConstants.reportResolved, '✅ حل', Colors.green),
                  const SizedBox(width: 6),
                  _statusButton(report, AppConstants.reportRejected, '❌ رفض', Colors.grey),
                  const SizedBox(width: 6),
                  _deleteButton(report),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(ReportModel report, String status, String label, Color color) {
    final isActive = report.status == status;
    return GestureDetector(
      onTap: isActive ? null : () => _service.updateReportStatus(report.id, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _deleteButton(ReportModel report) {
    return GestureDetector(
      onTap: () => _confirmDelete(report),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.accentColor, size: 18),
      ),
    );
  }

  void _confirmDelete(ReportModel report) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف البلاغ', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل تريد حذف هذا البلاغ؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteReport(report.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
