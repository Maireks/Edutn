// ============================================================
// screens/lesson_details_screen.dart — تفاصيل الدرس الكاملة
// PDF + تقييم + تعليقات + بلاغات
// ============================================================
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lesson_model.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/device_service.dart';
import '../widgets/comment_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/star_rating_display.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import 'pdf_viewer_screen.dart';

class LessonDetailsScreen extends StatefulWidget {
  final LessonModel lesson;
  final String subjectName;

  const LessonDetailsScreen({
    super.key,
    required this.lesson,
    required this.subjectName,
  });

  @override
  State<LessonDetailsScreen> createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _service = FirebaseService();
  final _device  = DeviceService();

  late TabController _tabCtrl;
  String _deviceId = '';
  double _userRating = 0;
  bool   _ratingSubmitted = false;
  bool   _isSubmittingComment = false;

  final _commentCtrl = TextEditingController();
  final _nameCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _deviceId = await _device.getDeviceId();
    final saved = await _device.getSavedStudentName();
    if (saved.isNotEmpty && mounted) {
      setState(() => _nameCtrl.text = saved);
    }
    await _service.incrementViewCount(widget.lesson.id);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _commentCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 195,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHero(),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              tabs: const [
                Tab(text: '📖 الدرس'),
                Tab(text: '💬 التعليقات'),
                Tab(text: '⭐ التقييم'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _LessonTab(lesson: widget.lesson, onPdfTap: _openPdf, onReportTap: _showReportSheet),
            _CommentsTab(
              lesson: widget.lesson,
              service: _service,
              nameCtrl: _nameCtrl,
              commentCtrl: _commentCtrl,
              isSubmitting: _isSubmittingComment,
              onSubmit: _submitComment,
            ),
            _RatingTab(
              lesson: widget.lesson,
              userRating: _userRating,
              submitted: _ratingSubmitted,
              onRatingChanged: (r) => setState(() => _userRating = r),
              onSubmit: _submitRating,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero رأس الصفحة ─────────────────────────────────────
  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primaryColor],
        ),
      ),
      padding: const EdgeInsets.only(top: 78, right: 20, left: 20, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subjectName.isNotEmpty)
            Text(widget.subjectName,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(
            widget.lesson.title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _chip(Icons.star, '${widget.lesson.averageRating.toStringAsFixed(1)} (${widget.lesson.ratingCount})'),
              _chip(Icons.visibility_outlined, '${widget.lesson.viewCount}'),
              if (widget.lesson.formattedDate.isNotEmpty)
                _chip(Icons.calendar_today_outlined, widget.lesson.formattedDate),
              if (widget.lesson.pdfUrl != null && widget.lesson.pdfUrl!.isNotEmpty)
                _chip(Icons.picture_as_pdf, 'PDF'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11, color: Colors.white)),
      ]),
    );
  }

  // ─── فتح PDF ─────────────────────────────────────────────
  void _openPdf() {
    final url = widget.lesson.pdfUrl;
    if (url == null || url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PDFViewerScreen(
          url: url,
          title: widget.lesson.pdfName ?? widget.lesson.title,
        ),
      ),
    );
  }

  // ─── إرسال تعليق ─────────────────────────────────────────
  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmittingComment = true);

    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await _device.saveStudentName(name);

    await _service.addComment(CommentModel(
      id: '',
      lessonId: widget.lesson.id,
      studentName: name.isEmpty ? 'طالب مجهول' : name,
      deviceId: _deviceId,
      comment: text,
    ));

    _commentCtrl.clear();
    setState(() => _isSubmittingComment = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم إرسال تعليقك ✅',
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    }
  }

  // ─── إرسال تقييم ─────────────────────────────────────────
  Future<void> _submitRating() async {
    if (_userRating == 0) return;
    await _service.addOrUpdateRating(RatingModel(
      id: '',
      lessonId: widget.lesson.id,
      studentName: _nameCtrl.text.trim().isEmpty
          ? 'طالب'
          : _nameCtrl.text.trim(),
      deviceId: _deviceId,
      stars: _userRating.round(),
    ));
    setState(() => _ratingSubmitted = true);
  }

  // ─── حوار البلاغ ─────────────────────────────────────────
  void _showReportSheet() {
    String? selectedType;
    final msgCtrl  = TextEditingController();
    final nameCtrl = TextEditingController(text: _nameCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 20, right: 20, left: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('🚩 إبلاغ عن مشكلة',
                  style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'نوع المشكلة *'),
                items: AppConstants.reportTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t,
                              style: const TextStyle(fontFamily: 'Cairo')),
                        ))
                    .toList(),
                onChanged: (v) => setModal(() => selectedType = v),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'اسمك (اختياري)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل المشكلة',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: selectedType == null
                      ? null
                      : () async {
                          await _service.addReport(ReportModel(
                            id: '',
                            lessonId: widget.lesson.id,
                            studentName: nameCtrl.text.trim().isEmpty
                                ? 'مجهول'
                                : nameCtrl.text.trim(),
                            deviceId: _deviceId,
                            type: selectedType!,
                            message: msgCtrl.text.trim(),
                          ));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إرسال البلاغ. شكراً! ✅',
                                    style: TextStyle(fontFamily: 'Cairo')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('إرسال البلاغ',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// تبويب الدرس
// ──────────────────────────────────────────────────────────
class _LessonTab extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onPdfTap;
  final VoidCallback onReportTap;

  const _LessonTab(
      {required this.lesson,
      required this.onPdfTap,
      required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // الوصف
        _SectionCard(
          emoji: '📝',
          title: 'وصف الدرس',
          child: Text(
            lesson.description.isEmpty
                ? 'لا يوجد وصف لهذا الدرس.'
                : lesson.description,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 14, height: 1.8),
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(height: 14),

        // التمارين المحلولة
        if (lesson.solvedExercises.isNotEmpty) ...[
          _SectionCard(
            emoji: '✏️',
            title: 'التمارين المحلولة',
            child: SelectableText(
              lesson.solvedExercises,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, height: 1.9),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 14),
        ],

        // زر PDF
        if (lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty)
          _PdfButtons(lesson: lesson, onPdfTap: onPdfTap),

        const SizedBox(height: 12),

        // زر البلاغ
        OutlinedButton.icon(
          onPressed: onReportTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentColor,
            side: const BorderSide(color: AppTheme.accentColor),
            minimumSize: const Size(double.infinity, 46),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.flag_outlined, size: 18),
          label: const Text('الإبلاغ عن مشكلة',
              style: TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget child;

  const _SectionCard(
      {required this.emoji, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ]),
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _PdfButtons extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onPdfTap;

  const _PdfButtons({required this.lesson, required this.onPdfTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // قراءة في التطبيق
      Expanded(
        child: ElevatedButton.icon(
          onPressed: onPdfTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 46),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: const Text('قراءة PDF',
              style: TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(width: 8),
      // تنزيل خارجي
      ElevatedButton.icon(
        onPressed: () => launchUrl(Uri.parse(lesson.pdfUrl!),
            mode: LaunchMode.externalApplication),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.download, size: 18),
        label: const Text('تنزيل',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ──────────────────────────────────────────────────────────
// تبويب التعليقات
// ──────────────────────────────────────────────────────────
class _CommentsTab extends StatelessWidget {
  final LessonModel lesson;
  final FirebaseService service;
  final TextEditingController nameCtrl;
  final TextEditingController commentCtrl;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _CommentsTab({
    required this.lesson,
    required this.service,
    required this.nameCtrl,
    required this.commentCtrl,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // نموذج الكتابة
      Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        color: Theme.of(context).cardColor,
        child: Column(children: [
          TextField(
            controller: nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'اسمك (اختياري)',
              prefixIcon: Icon(Icons.person_outline),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: TextField(
                controller: commentCtrl,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'اكتب تعليقك هنا...',
                  prefixIcon: Icon(Icons.comment_outlined),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSubmitting
                ? const SizedBox(
                    width: 36, height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send,
                        color: AppTheme.primaryColor),
                  ),
          ]),
        ]),
      ),
      // القائمة
      Expanded(
        child: StreamBuilder<List<CommentModel>>(
          stream: service.getCommentsStream(lesson.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(itemCount: 3);
            }
            final comments = snap.data ?? [];
            if (comments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💬', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 10),
                    Text('كن أول من يعلّق!',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            color: Colors.grey)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comments.length,
              itemBuilder: (_, i) => CommentTile(comment: comments[i]),
            );
          },
        ),
      ),
    ]);
  }
}

// ──────────────────────────────────────────────────────────
// تبويب التقييم
// ──────────────────────────────────────────────────────────
class _RatingTab extends StatelessWidget {
  final LessonModel lesson;
  final double userRating;
  final bool submitted;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSubmit;

  const _RatingTab({
    required this.lesson,
    required this.userRating,
    required this.submitted,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // التقييم الحالي
      Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(
              lesson.averageRating.toStringAsFixed(1),
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.goldColor,
                  height: 1.0),
            ),
            const SizedBox(height: 8),
            StarRatingDisplay(
              rating: lesson.averageRating,
              ratingCount: lesson.ratingCount,
              starSize: 26,
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),

      // تقييم المستخدم
      Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Text('قيّم هذا الدرس',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            StarRatingInput(
              initialRating: userRating,
              onRatingChanged: onRatingChanged,
              starSize: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel(userRating),
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppTheme.goldColor,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (submitted)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('شكراً على تقييمك! 🎉',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: userRating > 0 ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text('أرسل تقييمك',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }

  String _ratingLabel(double r) {
    if (r == 0) return 'اختر تقييمك';
    if (r == 1) return 'ضعيف جداً 😞';
    if (r == 2) return 'ضعيف 😕';
    if (r == 3) return 'مقبول 😐';
    if (r == 4) return 'جيد 😊';
    return 'ممتاز! 🌟';
  }
}
