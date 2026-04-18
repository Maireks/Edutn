// ============================================================
// screens/pdf_viewer_screen.dart - عارض PDF داخل التطبيق
// ============================================================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/app_theme.dart';

class PDFViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  double _downloadProgress = 0;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'edtn_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      // تنزيل الملف مع تتبع التقدم
      await Dio().download(
        widget.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (mounted) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل تحميل الملف: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      // شريط التنقل بين الصفحات
      bottomNavigationBar: (!_isLoading && _error == null && _totalPages > 1)
          ? _buildPageNavBar()
          : null,
    );
  }

  Widget _buildBody() {
    // حالة التحميل
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📄', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'جاري تحميل الملف...',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearPercentIndicator(
                lineHeight: 8,
                percent: _downloadProgress,
                progressColor: AppTheme.primaryLight,
                backgroundColor: Colors.white.withOpacity(0.2),
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_downloadProgress * 100).toInt()}%',
              style: const TextStyle(
                  fontFamily: 'Cairo', color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // حالة الخطأ
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❌', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'فشل تحميل الملف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                    fontFamily: 'Cairo', color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                    _downloadProgress = 0;
                  });
                  _downloadPDF();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      );
    }

    // عرض PDF
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        if (mounted) {
          setState(() {
            _totalPages = pages ?? 0;
            _currentPage = 1;
          });
        }
      },
      onViewCreated: (controller) {
        _pdfController = controller;
      },
      onPageChanged: (page, total) {
        if (mounted) {
          setState(() {
            _currentPage = (page ?? 0) + 1;
            _totalPages = total ?? 0;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _error = error.toString());
        }
      },
    );
  }

  Widget _buildPageNavBar() {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // الصفحة الأولى
          _navBtn(Icons.first_page, 'الأول', () {
            _pdfController?.setPage(0);
          }),
          // السابقة
          _navBtn(Icons.chevron_right, 'السابق', () {
            if (_currentPage > 1) _pdfController?.setPage(_currentPage - 2);
          }),
          // رقم الصفحة
          Text(
            '$_currentPage / $_totalPages',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          // التالية
          _navBtn(Icons.chevron_left, 'التالي', () {
            if (_currentPage < _totalPages) {
              _pdfController?.setPage(_currentPage);
            }
          }),
          // الأخيرة
          _navBtn(Icons.last_page, 'الأخير', () {
            _pdfController?.setPage(_totalPages - 1);
          }),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white70),
        splashRadius: 24,
      ),
    );
  }
}
