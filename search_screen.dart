// ============================================================
// screens/search_screen.dart - شاشة البحث
// ============================================================

import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../services/firebase_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/app_theme.dart';
import 'lesson_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<LessonModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty || query == _lastQuery) return;
    _lastQuery = query.trim();
    setState(() { _isLoading = true; _hasSearched = true; });
    final results = await _service.searchLessons(query.trim());
    if (mounted) setState(() { _results = results; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: theme.iconTheme.color),
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontFamily: 'Cairo', color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'ابحث عن دروس، مواد...',
            hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
            border: InputBorder.none,
            filled: false,
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() { _results = []; _hasSearched = false; _lastQuery = ''; });
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            setState(() {});
            if (v.trim().length >= 2) _search(v);
          },
          onSubmitted: _search,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();

    if (!_hasSearched) {
      return _buildHints();
    }

    if (_results.isEmpty) {
      return EmptyStateWidget(
        icon: '🔍',
        title: 'لا نتائج',
        subtitle: 'لم يتم العثور على دروس تطابق "${_ctrl.text}"',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_results.length} نتيجة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (_, i) => _buildResultTile(_results[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultTile(LessonModel lesson) {
    final query = _ctrl.text.trim().toLowerCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('📖', style: TextStyle(fontSize: 20))),
        ),
        title: _highlightText(lesson.title, query),
        subtitle: Text(
          lesson.description.length > 80
              ? '${lesson.description.substring(0, 80)}...'
              : lesson.description,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
          textDirection: TextDirection.rtl,
          maxLines: 2,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppTheme.goldColor, size: 14),
            Text(
              lesson.averageRating.toStringAsFixed(1),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsScreen(lesson: lesson, subjectName: ''),
          ),
        ),
      ),
    );
  }

  // تمييز نص البحث بالأصفر
  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          textDirection: TextDirection.rtl);
    }
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) {
      return Text(text,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          textDirection: TextDirection.rtl);
    }
    return Text.rich(
      TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx)),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: const TextStyle(
            backgroundColor: AppTheme.goldColor,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length)),
      ]),
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildHints() {
    final suggestions = ['رياضيات', 'فيزياء', 'عربية', 'دوال', 'هندسة', 'فلسفة'];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اقتراحات البحث',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _ctrl.text = s;
                  _search(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '🔍 $s',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
