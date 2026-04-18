// ============================================================
// screens/lessons_screen.dart - شاشة الدروس
// ============================================================

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/lesson_model.dart';
import '../services/firebase_service.dart';
import '../widgets/lesson_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as custom;
import '../utils/app_theme.dart';
import 'lesson_details_screen.dart';

class LessonsScreen extends StatefulWidget {
  final SubjectModel subject;
  const LessonsScreen({super.key, required this.subject});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // معلومات المادة
          _buildSubjectInfo(),
          // بحث
          _buildSearchBar(),
          // قائمة الدروس
          Expanded(child: _buildLessonsList()),
        ],
      ),
    );
  }

  Widget _buildSubjectInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15)),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _infoBadge('📅 ${widget.subject.academicYear}', AppTheme.primaryColor),
          _infoBadge(
            '${_branchIcon(widget.subject.branch)} ${widget.subject.branch}',
            _branchColor(widget.subject.branch),
          ),
          _infoBadge('🏫 ${widget.subject.category}', Colors.teal),
        ],
      ),
    );
  }

  Widget _infoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في الدروس...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildLessonsList() {
    return StreamBuilder<List<LessonModel>>(
      stream: _service.getLessonsStream(widget.subject.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          return custom.ErrorStateWidget(
            message: 'حدث خطأ في تحميل الدروس',
            onRetry: () => setState(() {}),
          );
        }

        var lessons = snapshot.data ?? [];

        if (_searchQuery.isNotEmpty) {
          lessons = lessons
              .where((l) =>
                  l.title.toLowerCase().contains(_searchQuery) ||
                  l.description.toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (lessons.isEmpty) {
          return EmptyStateWidget(
            icon: '📝',
            title: _searchQuery.isNotEmpty ? 'لا نتائج' : 'لا توجد دروس',
            subtitle: _searchQuery.isNotEmpty
                ? 'لا يوجد درس يطابق "$_searchQuery"'
                : 'لم يتم إضافة دروس بعد',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: lessons.length,
            itemBuilder: (context, i) {
              return LessonCard(
                lesson: lessons[i],
                index: i,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailsScreen(
                      lesson: lessons[i],
                      subjectName: widget.subject.name,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _branchIcon(String branch) {
    const icons = {
      'علوم': '🔬', 'رياضيات': '📐', 'اقتصاد وتصرف': '📊',
      'تقنية': '⚙️', 'إعلامية': '💻', 'آداب': '📚',
    };
    return icons[branch] ?? '📖';
  }

  Color _branchColor(String branch) {
    const colors = {
      'علوم': Color(0xFF2E7D32), 'رياضيات': Color(0xFF1565C0),
      'اقتصاد وتصرف': Color(0xFFE65100), 'تقنية': Color(0xFF6A1B9A),
      'إعلامية': Color(0xFF00838F), 'آداب': Color(0xFFAD1457),
    };
    return colors[branch] ?? AppTheme.primaryColor;
  }
}
