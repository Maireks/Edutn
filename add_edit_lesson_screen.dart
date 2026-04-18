// ============================================================
// screens/admin/add_edit_lesson_screen.dart - إضافة/تعديل درس
// مع رفع PDF وشريط التقدم
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../models/lesson_model.dart';
import '../../models/subject_model.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';

class AddEditLessonScreen extends StatefulWidget {
  final LessonModel? lesson;
  const AddEditLessonScreen({super.key, this.lesson});

  @override
  State<AddEditLessonScreen> createState() => _AddEditLessonScreenState();
}

class _AddEditLessonScreenState extends State<AddEditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseService();
  final _storage = StorageService();
  final _notifService = NotificationService();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _exercisesCtrl;

  String? _selectedSubjectId;
  List<SubjectModel> _subjects = [];

  File? _pdfFile;
  String? _pdfFileName;
  double _uploadProgress = 0;
  bool _isUploading = false;
  bool _isSaving = false;
  bool _isPublished = true;

  bool get _isEditing => widget.lesson != null;
  String? get _existingPdfUrl => widget.lesson?.pdfUrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.lesson?.title ?? '');
    _descCtrl = TextEditingController(text: widget.lesson?.description ?? '');
    _exercisesCtrl = TextEditingController(text: widget.lesson?.solvedExercises ?? '');
    _selectedSubjectId = widget.lesson?.subjectId;
    _isPublished = widget.lesson?.isPublished ?? true;
    _loadSubjects();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _exercisesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    _service.getAllSubjectsStream().listen((subjects) {
      if (mounted) setState(() => _subjects = subjects);
    });
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadPDF() async {
    if (_pdfFile == null || _selectedSubjectId == null) return null;

    setState(() { _isUploading = true; _uploadProgress = 0; });

    final result = await _storage.uploadPDF(
      file: _pdfFile!,
      subjectId: _selectedSubjectId!,
      onProgress: (p) => setState(() => _uploadProgress = p),
    );

    setState(() => _isUploading = false);

    if (result.success) return result.url;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error ?? 'فشل رفع الملف', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
    );
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المادة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? pdfUrl = _existingPdfUrl;
      String? pdfName = widget.lesson?.pdfName;

      // رفع PDF إذا تم اختياره
      if (_pdfFile != null) {
        pdfUrl = await _uploadPDF();
        pdfName = _pdfFileName;
      }

      if (_isEditing) {
        final updated = widget.lesson!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          subjectId: _selectedSubjectId!,
          solvedExercises: _exercisesCtrl.text.trim(),
          pdfUrl: pdfUrl,
          pdfName: pdfName,
          isPublished: _isPublished,
        );
        await _service.updateLesson(updated);
      } else {
        final lesson = LessonModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          subjectId: _selectedSubjectId!,
          solvedExercises: _exercisesCtrl.text.trim(),
          pdfUrl: pdfUrl,
          pdfName: pdfName,
          isPublished: _isPublished,
        );
        await _service.addLesson(lesson);

        // إرسال إشعار درس جديد
        final subject = _subjects.firstWhere(
          (s) => s.id == _selectedSubjectId,
          orElse: () => SubjectModel(id: '', name: '', levelId: '', branch: '', academicYear: '', category: ''),
        );
        await _notifService.sendNewLessonNotification(
          lessonTitle: _titleCtrl.text.trim(),
          subjectName: subject.name,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تعديل الدرس ✅' : 'تم إضافة الدرس ✅',
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
        title: Text(_isEditing ? 'تعديل الدرس' : 'إضافة درس جديد'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isUploading) ? null : _save,
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionLabel('📝 بيانات الدرس'),
            const SizedBox(height: 12),

            // عنوان الدرس
            TextFormField(
              controller: _titleCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'عنوان الدرس *',
                hintText: 'مثال: الدوال العددية',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 14),

            // المادة
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              decoration: const InputDecoration(
                labelText: 'المادة الدراسية *',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              items: _subjects.map((s) => DropdownMenuItem(
                value: s.id,
                child: Text('${s.iconEmoji ?? ''} ${s.name} - ${s.academicYear}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedSubjectId = v),
              validator: (v) => v == null ? 'اختر المادة' : null,
            ),
            const SizedBox(height: 14),

            // الوصف
            TextFormField(
              controller: _descCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'وصف الدرس',
                hintText: 'اكتب وصفاً تفصيلياً للدرس...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            // التمارين المحلولة
            TextFormField(
              controller: _exercisesCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'التمارين المحلولة',
                hintText: 'اكتب التمارين المحلولة هنا...',
                prefixIcon: Icon(Icons.edit_note_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('📄 ملف PDF'),
            const SizedBox(height: 12),

            // حالة PDF الحالي
            if (_existingPdfUrl != null && _pdfFile == null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.lesson?.pdfName ?? 'ملف PDF موجود',
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickPDF,
                      child: const Text('تغيير', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              ),
            ] else if (_pdfFile != null) ...[
              // ملف تم اختياره
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_pdfFileName ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() { _pdfFile = null; _pdfFileName = null; }),
                        ),
                      ],
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: 10),
                      LinearPercentIndicator(
                        lineHeight: 8,
                        percent: _uploadProgress,
                        progressColor: AppTheme.primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'جاري الرفع... ${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primaryColor),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // زر اختيار PDF
              OutlinedButton.icon(
                onPressed: _pickPDF,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.upload_file),
                label: const Text(
                  'اختر ملف PDF (اختياري)',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // نشر الدرس
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('نشر الدرس', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                  ),
                  Switch(
                    value: _isPublished,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() => _isPublished = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: (_isSaving || _isUploading) ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: (_isSaving || _isUploading)
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                _isEditing ? 'تعديل الدرس' : 'نشر الدرس',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 16),
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
