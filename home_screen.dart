// ============================================================
// screens/home_screen.dart — الشاشة الرئيسية (نسخة نهائية)
// ============================================================
import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../services/firebase_service.dart';
import '../widgets/level_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart' as custom_err;
import '../widgets/connectivity_wrapper.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import 'subjects_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _service = FirebaseService();
  late TabController _tabCtrl;

  static const _tabs = [
    ('all',    'الكل',    '📚'),
    ('ثانوي',  'ثانوي',  '🎓'),
    ('إعدادي', 'إعدادي', '📖'),
    ('تحضيري', 'تحضيري', '🏫'),
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
    return ConnectivityWrapper(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 155,
              pinned: true,
              floating: false,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _Header(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _TabBar(controller: _tabCtrl),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: _tabs
                .map((t) => _LevelsList(filter: t.$1, service: _service))
                .toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
          backgroundColor: AppTheme.accentColor,
          icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
          label: const Text('إدارة',
              style: TextStyle(
                  fontFamily: 'Cairo', color: Colors.white,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primaryColor],
        ),
      ),
      padding: const EdgeInsets.only(top: 56, right: 20, left: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                  child: Text('🎓', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EduTN',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 22,
                      fontWeight: FontWeight.w800, color: Colors.white)),
              Text('منصة التعليم التونسية',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                      color: Colors.white60)),
            ]),
          ]),
          const SizedBox(height: 14),
          const Text('اختر مستواك الدراسي',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 17,
                  fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  static const _tabs = [
    ('all',    'الكل',    '📚'),
    ('ثانوي',  'ثانوي',  '🎓'),
    ('إعدادي', 'إعدادي', '📖'),
    ('تحضيري', 'تحضيري', '🏫'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        tabs: _tabs
            .map((t) => Tab(text: '${t.$3} ${t.$2}'))
            .toList(),
      ),
    );
  }
}

class _LevelsList extends StatelessWidget {
  final String filter;
  final FirebaseService service;
  const _LevelsList({required this.filter, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LevelModel>>(
      stream: service.getLevelsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snap.hasError) {
          return custom_err.ErrorStateWidget(
            message: 'تعذّر تحميل المستويات',
            onRetry: () {},
          );
        }

        var levels = snap.data ?? [];
        if (filter != 'all') {
          levels = levels.where((l) => l.name.contains(filter)).toList();
        }

        if (levels.isEmpty) {
          return EmptyStateWidget(
            icon: '📚',
            title: 'لا توجد مستويات',
            subtitle: filter == 'all'
                ? 'لم يتم إضافة أي مستويات بعد'
                : 'لا توجد مستويات في هذا القسم',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: levels.length,
            itemBuilder: (_, i) => LevelCard(
              level: levels[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SubjectsScreen(level: levels[i])),
              ),
            ),
          ),
        );
      },
    );
  }
}
