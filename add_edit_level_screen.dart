// ============================================================
// screens/admin/add_edit_level_screen.dart - إضافة/تعديل مستوى
// ============================================================

import 'package:flutter/material.dart';
import '../../models/level_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';

class AddEditLevelScreen extends StatefulWidget {
  final LevelModel? level; // null = إضافة جديدة

  const AddEditLevelScreen({super.key, this.level});

  @override
  State<AddEditLevelScreen> createState() => _AddEditLevelScreenState();
}

class _AddEditLevelScreenState extends State<AddEditLevelScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _service = FirebaseService();

  late TextEditingController _nameCtrl;
  String _selectedIcon = '📚';
  String _selectedColor = '#1565C0';
  int _order = 0;
  bool _isSaving = false;

  bool get _isEditing => widget.level != null;

  final List<String> _icons = [
    '📚', '📖', '🎓', '🏫', '📝', '✏️', '🔬', '📐',
    '📊', '💻', '⚙️', '🧪', '🔭', '📏', '🗺️', '🌍',
  ];

  final List<Map<String, String>> _colors = [
    {'label': 'أزرق', 'value': '#1565C0'},
    {'label': 'أخضر', 'value': '#2E7D32'},
    {'label': 'أحمر', 'value': '#C62828'},
    {'label': 'برتقالي', 'value': '#E65100'},
    {'label': 'بنفسجي', 'value': '#6A1B9A'},
    {'label': 'فيروزي', 'value': '#00838F'},
    {'label': 'وردي', 'value': '#AD1457'},
    {'label': 'رمادي', 'value': '#37474F'},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.level?.name ?? '');
    _selectedIcon = widget.level?.iconEmoji ?? '📚';
    _selectedColor = widget.level?.colorHex ?? '#1565C0';
    _order = widget.level?.order ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updated = widget.level!.copyWith(
          name: _nameCtrl.text.trim(),
          iconEmoji: _selectedIcon,
          colorHex: _selectedColor,
          order: _order,
        );
        await _service.updateLevel(updated);
      } else {
        final newLevel = LevelModel(
          id: '',
          name: _nameCtrl.text.trim(),
          iconEmoji: _selectedIcon,
          colorHex: _selectedColor,
          order: _order,
        );
        await _service.addLevel(newLevel);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'تم تعديل المستوى ✅' : 'تم إضافة المستوى ✅',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
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
        title: Text(_isEditing ? 'تعديل المستوى' : 'إضافة مستوى'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // معاينة
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: _hexToColor(_selectedColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _hexToColor(_selectedColor), width: 2),
                ),
                child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 48))),
              ),
            ),
            const SizedBox(height: 24),

            // اسم المستوى
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المستوى *',
                hintText: 'مثال: السنة التاسعة',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 20),

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

            // اختيار الأيقونة
            const Text('اختر أيقونة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // اختيار اللون
            const Text('اختر اللون', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _colors.map((colorMap) {
                final color = _hexToColor(colorMap['value']!);
                final isSelected = _selectedColor == colorMap['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorMap['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
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
                _isEditing ? 'تعديل المستوى' : 'إضافة المستوى',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
