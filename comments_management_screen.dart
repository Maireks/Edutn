// ============================================================
// screens/admin/comments_management_screen.dart
// إدارة التعليقات للأدمن - قبول / رفض / حذف
// ============================================================
import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/comment_tile.dart';

class CommentsManagementScreen extends StatefulWidget {
  const CommentsManagementScreen({super.key});

  @override
  State<CommentsManagementScreen> createState() =>
      _CommentsManagementScreenState();
}

class _CommentsManagementScreenState
    extends State<CommentsManagementScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _service = FirebaseService();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
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
        title: const Text('إدارة التعليقات'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '✅ المعتمدة'),
            Tab(text: '⏳ بانتظار الموافقة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildCommentsList(approved: true),
          _buildCommentsList(approved: false),
        ],
      ),
    );
  }

  Widget _buildCommentsList({required bool approved}) {
    return StreamBuilder<List<CommentModel>>(
      stream: _service.getAllCommentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allComments = snapshot.data ?? [];
        final filtered =
            allComments.where((c) => c.isApproved == approved).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  approved ? '✅' : '⏳',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  approved ? 'لا توجد تعليقات معتمدة' : 'لا توجد تعليقات بانتظار الموافقة',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final comment = filtered[i];
            return Column(
              children: [
                CommentTile(
                  comment: comment,
                  isAdmin: true,
                  onDelete: () => _confirmDelete(comment),
                ),
                // زر الموافقة للتعليقات المعلقة
                if (!approved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _service.approveComment(comment.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.check,
                                color: Colors.white, size: 16),
                            label: const Text(
                              'اعتماد',
                              style: TextStyle(
                                  fontFamily: 'Cairo', color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmDelete(comment),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('حذف',
                                style: TextStyle(fontFamily: 'Cairo')),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(CommentModel comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف التعليق',
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل تريد حذف هذا التعليق نهائياً؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteComment(comment.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
