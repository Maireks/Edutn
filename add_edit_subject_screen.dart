// ============================================================
// screens/admin/add_edit_subject_screen.dart - إضافة/تعديل مادة
// ============================================================

import 'package:flutter/material.dart';
import '../../models/level_model.dart';
import '../../models/subject_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final SubjectModel? subject;
  const AddEditSubjectScreen({super.key, this.subject});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseService();

  late TextEditingController _nameCtrl;
  String? _selectedLevelId;
  String _selectedBranch = AppConstants.tunisianBranches.first;
  String _selectedAcademicYear = AppConstants.academicYears.first;
  String _selectedCategory = AppConstants.categories.first;
  String _selectedIcon = '📘';
  String _selectedColor = '#1565C0';
  int _order = 0;
  bool _isSaving = false;

  List<LevelModel> _levels = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.subject != null;
    _nameCtrl = TextEditingController(text: widget.subject?.name ?? '');
    _selectedLevelId = widget.subject?.levelId;
    _selectedBranch = widget.subject?.branch ?? AppConstants.tunisianBranches.first;
    _selectedAcademicYear = widget.subject?.academicYear ?? AppConstants.academicYears.first;
    _selectedCategory = widget.subject?.category ?? AppConstants.categories.first;
    _selectedIcon = widget.subject?.iconEmoji ?? '📘';
    _selectedColor = widget.subject?.colorHex ?? '#1565C0';
    _order = widget.subject?.order ?? 0;
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    _service.getLevelsStream().listen((levels) {
      if (mounted) setState(() => _levels = levels);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLevelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المستوى', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.subject!.copyWith(
          name: _nameCtrl.text.trim(),
          levelId: _selectedLevelId!,
          branch: _selectedBranch,
          academicYear: _selectedAcademicYear,
          category: _selectedCategory,
          iconEmoji: _selectedIcon,
          colorHex: _selectedColor,
          order: _order,
        );
        await _service.updateSubject(updated);
      } else {
        final subject = SubjectModel(
          id: '',
          name: _nameCtrl.text.trim(),
          levelId: _selectedLevelId!,
          branch: _selectedBranch,
          academicYear: _selectedAcademicYear,
          category: _selectedCategory,
          iconEmoji: _selectedIcon,
          colorHex: _selectedColor,
          order: _order,
        );
        await _service.addSubject(subject);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تعديل المادة ✅' : 'تم إضافة المادة ✅',
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل المادة' : 'إضافة مادة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionLabel('بيانات المادة'),
            const SizedBox(height: 10),

            // اسم المادة
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المادة *',
                hintText: 'مثال: الرياضيات',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 14),

            // اختيار المستوى
            DropdownButtonFormField<String>(
              value: _selectedLevelId,
              decoration: const InputDecoration(
                labelText: 'المستوى الدراسي *',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
              items: _levels.map((l) => DropdownMenuItem(
                value: l.id,
                child: Text('${l.iconEmoji ?? ''} ${l.name}', style: const TextStyle(fontFamily: 'Cairo')),
              )).toList(),
              onChanged: (v) => setState(() => _selectedLevelId = v),
              validator: (v) => v == null ? 'اختر المستوى' : null,
            ),
            const SizedBox(height: 14),

            // الفرع
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              decoration: const InputDecoration(
                labelText: 'الفرع *',
                prefixIcon: Icon(Icons.account_tree_outlined),
              ),
              items: AppConstants.tunisianBranches.map((b) => DropdownMenuItem(
                value: b,
                child: Text('${AppConstants.branchIcons[b] ?? ''} $b', style: const TextStyle(fontFamily: 'Cairo')),
              )).toList(),
              onChanged: (v) => setState(() => _selectedBranch = v!),
            ),
            const SizedBox(height: 14),

            // السنة الدراسية
            DropdownButtonFormField<String>(
              value: _selectedAcademicYear,
              decoration: const InputDecoration(
                labelText: 'السنة الدراسية *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              items: AppConstants.academicYears.map((y) => DropdownMenuItem(
                value: y,
                child: Text(y, style: const TextStyle(fontFamily: 'Cairo')),
              )).toList(),
              onChanged: (v) => setState(() => _selectedAcademicYear = v!),
            ),
            const SizedBox(height: 14),

            // الفئة
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'الفئة *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.categories.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: const TextStyle(fontFamily: 'Cairo')),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 14),

            // الترتيب
            TextFormField(
              initialValue: _order.toString(),
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'الترتيب',
                prefixIcon: Icon(Icons.sort),
              ),
              onChanged: (v) => _order = int.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 24),

            _sectionLabel('المظهر'),
            const SizedBox(height: 10),

            // اختيار الأيقونة
            const Text('الأيقونة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['📘', '📗', '📙', '📕', '📓', '📔', '🔬', '📐',
                         '📊', '💻', '⚙️', '🧪', '📏', '🗒️', '🎯', '🧮'].map((icon) {
                final sel = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryColor.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppTheme.primaryColor : Colors.transparent, width: 2),
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                _isEditing ? 'تعديل المادة' : 'إضافة المادة',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
    );
  }
}
