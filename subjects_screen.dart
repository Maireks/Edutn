// ============================================================
// screens/subjects_screen.dart - شاشة المواد الدراسية
// عرض مواد مستوى معين مع فلتر الفروع
// ============================================================

import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../models/subject_model.dart';
import '../services/firebase_service.dart';
import '../widgets/subject_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as custom;
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import 'lessons_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final LevelModel level;

  const SubjectsScreen({super.key, required this.level});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final FirebaseService _service = FirebaseService();
  String? _selectedBranch; // null = الكل

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.level.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // فلتر الفروع
          _buildBranchFilter(),

          // قائمة المواد
          Expanded(
            child: StreamBuilder<List<SubjectModel>>(
              stream: _service.getSubjectsStream(widget.level.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (snapshot.hasError) {
                  return custom.ErrorStateWidget(
                    message: 'حدث خطأ في تحميل المواد',
                    onRetry: () => setState(() {}),
                  );
                }

                var subjects = snapshot.data ?? [];

                // تصفية حسب الفرع
                if (_selectedBranch != null) {
                  subjects = subjects
                      .where((s) => s.branch == _selectedBranch)
                      .toList();
                }

                if (subjects.isEmpty) {
                  return EmptyStateWidget(
                    icon: '📘',
                    title: 'لا توجد مواد',
                    subtitle: _selectedBranch != null
                        ? 'لا توجد مواد في فرع $_selectedBranch'
                        : 'لم يتم إضافة أي مواد بعد',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: AppTheme.primaryColor,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return SubjectCard(
                        subject: subject,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonsScreen(subject: subject),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // فلتر الفروع الأفقي
  Widget _buildBranchFilter() {
    return Container(
      height: 50,
      color: Theme.of(context).cardColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // زر "الكل"
          _filterChip(null, 'الكل', '📚'),
          // الفروع
          ...AppConstants.tunisianBranches.map(
            (branch) => _filterChip(
              branch,
              branch,
              AppConstants.branchIcons[branch] ?? '📖',
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String? branch, String label, String icon) {
    final isSelected = _selectedBranch == branch;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () => setState(() => _selectedBranch = branch),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.withOpacity(0.4),
            ),
          ),
          child: Text(
            '$icon $label',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
