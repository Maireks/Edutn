// ============================================================
// screens/admin/admin_dashboard.dart — لوحة التحكم الكاملة
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../home_screen.dart';
import 'add_edit_level_screen.dart';
import 'add_edit_subject_screen.dart';
import 'add_edit_lesson_screen.dart';
import 'reports_screen.dart';
import 'comments_management_screen.dart';
import 'notification_send_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined,  activeIcon: Icons.dashboard,  label: 'الرئيسية'),
    _NavItem(icon: Icons.layers_outlined,     activeIcon: Icons.layers,     label: 'المستويات'),
    _NavItem(icon: Icons.book_outlined,       activeIcon: Icons.book,       label: 'المواد'),
    _NavItem(icon: Icons.article_outlined,    activeIcon: Icons.article,    label: 'الدروس'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.primaryDark,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎓', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              const Text(
                'لوحة التحكم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          actions: [
            // زر الإشعارات
            IconButton(
              tooltip: 'إرسال إشعار',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSendScreen()),
              ),
            ),
            // زر تسجيل الخروج
            IconButton(
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmSignOut(context, auth),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            _DashboardHome(),
            _LevelsManagement(),
            _SubjectsManagement(),
            _LessonsManagement(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 12)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: selected
                              ? AppTheme.primaryLight
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected
                              ? AppTheme.primaryLight
                              : Colors.white38,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? AppTheme.primaryLight
                                : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('تسجيل الخروج',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          ],
        ),
        content: const Text(
          'هل تريد تسجيل الخروج من لوحة التحكم؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor),
            child: const Text('خروج',
                style: TextStyle(
                    fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}

// ──────────────────────────────────────────────────────────
// الصفحة الرئيسية
// ──────────────────────────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب
          _WelcomeCard(auth: auth),
          const SizedBox(height: 20),

          // بطاقات الإحصائيات
          const Text(
            'الإحصائيات',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _StatsGrid(),
          const SizedBox(height: 20),

          // الإجراءات السريعة
          const Text(
            'الإجراءات السريعة',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _QuickActions(),
        ],
      ),
    );
  }
}

// ─── بطاقة الترحيب ────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  final AuthProvider auth;
  const _WelcomeCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _roleEmoji(auth.adminRole),
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً بك 👋',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white70,
                      fontSize: 12),
                ),
                Text(
                  auth.user?.email?.split('@').first ?? 'مدير',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleLabel(auth.adminRole),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleEmoji(String? role) {
    switch (role) {
      case 'superAdmin': return '👑';
      case 'admin':      return '🛡️';
      case 'editor':     return '✏️';
      default:           return '👤';
    }
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'superAdmin': return 'مدير عام';
      case 'admin':      return 'مدير';
      case 'editor':     return 'محرر';
      default:           return 'مستخدم';
    }
  }
}

// ─── شبكة الإحصائيات ──────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: FirebaseService().getDashboardStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 130,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final s = snapshot.data!;
        final cards = [
          _StatData('📚', 'المستويات',  s['levels']!,       AppTheme.primaryColor),
          _StatData('📘', 'المواد',     s['subjects']!,     const Color(0xFF2E7D32)),
          _StatData('📝', 'الدروس',    s['lessons']!,      const Color(0xFFE65100)),
          _StatData('🚩', 'بلاغات',   s['pendingReports']!, AppTheme.accentColor),
        ];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => _StatCard(data: cards[i]),
        );
      },
    );
  }
}

class _StatData {
  final String emoji;
  final String label;
  final int value;
  final Color color;
  const _StatData(this.emoji, this.label, this.value, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.value}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                  height: 1.0,
                ),
              ),
              Text(
                data.label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── الإجراءات السريعة ────────────────────────────────────
class _QuickActions extends StatelessWidget {
  _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('➕ إضافة مستوى',      AppTheme.primaryColor,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditLevelScreen()))),
      _ActionData('➕ إضافة مادة',       const Color(0xFF2E7D32),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditSubjectScreen()))),
      _ActionData('➕ إضافة درس',        const Color(0xFFE65100),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditLessonScreen()))),
      _ActionData('🚩 إدارة البلاغات',  AppTheme.accentColor,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
      _ActionData('💬 إدارة التعليقات', const Color(0xFF1565C0),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentsManagementScreen()))),
      _ActionData('🔔 إرسال إشعار',     const Color(0xFF6A1B9A),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSendScreen()))),
    ];

    return Column(
      children: actions.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ActionButton(data: a),
      )).toList(),
    );
  }
}

class _ActionData {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.label, this.color, this.onTap);
}

class _ActionButton extends StatelessWidget {
  final _ActionData data;
  const _ActionButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: data.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: data.color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          data.label,
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// إدارة المستويات
// ──────────────────────────────────────────────────────────
class _LevelsManagement extends StatelessWidget {
  const _LevelsManagement();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseService().getLevelsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final levels = snapshot.data!;
          if (levels.isEmpty) {
            return _emptyState('📚', 'لا توجد مستويات',
                'اضغط + لإضافة مستوى جديد');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            itemBuilder: (_, i) {
              final l = levels[i];
              return _AdminListTile(
                emoji: l.iconEmoji ?? '📚',
                title: l.name,
                subtitle: 'الترتيب: ${l.order}',
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditLevelScreen(level: l)),
                ),
                onDelete: () => _confirmDelete(
                  context,
                  'حذف المستوى "${l.name}"',
                  () => FirebaseService().deleteLevel(l.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditLevelScreen()),
        ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// إدارة المواد
// ──────────────────────────────────────────────────────────
class _SubjectsManagement extends StatefulWidget {
  const _SubjectsManagement();

  @override
  State<_SubjectsManagement> createState() => _SubjectsManagementState();
}

class _SubjectsManagementState extends State<_SubjectsManagement> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'بحث في المواد...',
                hintStyle: const TextStyle(
                    fontFamily: 'Cairo', color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseService().getAllSubjectsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var subjects = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  subjects = subjects
                      .where((s) =>
                          s.name.toLowerCase().contains(_searchQuery) ||
                          s.branch.toLowerCase().contains(_searchQuery))
                      .toList();
                }
                if (subjects.isEmpty) {
                  return _emptyState('📘', 'لا توجد مواد',
                      'اضغط + لإضافة مادة جديدة');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (_, i) {
                    final s = subjects[i];
                    return _AdminListTile(
                      emoji: s.iconEmoji ?? '📘',
                      title: s.name,
                      subtitle: '${s.branch} | ${s.academicYear}',
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddEditSubjectScreen(subject: s)),
                      ),
                      onDelete: () => _confirmDelete(
                        context,
                        'حذف المادة "${s.name}"',
                        () => FirebaseService().deleteSubject(s.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditSubjectScreen()),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// إدارة الدروس
// ──────────────────────────────────────────────────────────
class _LessonsManagement extends StatefulWidget {
  const _LessonsManagement();

  @override
  State<_LessonsManagement> createState() => _LessonsManagementState();
}

class _LessonsManagementState extends State<_LessonsManagement> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'بحث في الدروس...',
                hintStyle: const TextStyle(
                    fontFamily: 'Cairo', color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseService().getAllLessonsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var lessons = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  lessons = lessons
                      .where((l) =>
                          l.title.toLowerCase().contains(_searchQuery))
                      .toList();
                }
                if (lessons.isEmpty) {
                  return _emptyState('📝', 'لا توجد دروس',
                      'اضغط + لإضافة درس جديد');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (_, i) {
                    final l = lessons[i];
                    return _AdminListTile(
                      emoji: '📖',
                      title: l.title,
                      subtitle: l.formattedDate,
                      badge: l.isPublished ? null : 'مخفي',
                      badgeColor: Colors.orange,
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddEditLessonScreen(lesson: l)),
                      ),
                      onDelete: () => _confirmDelete(
                        context,
                        'حذف الدرس "${l.title}"',
                        () => FirebaseService().deleteLesson(l.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditLessonScreen()),
        ),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// مكونات مشتركة
// ──────────────────────────────────────────────────────────
class _AdminListTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? badge;
  final Color? badgeColor;

  const _AdminListTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 22))),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? Colors.grey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9,
                    color: badgeColor ?? Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.primaryColor, size: 20),
              onPressed: onEdit,
              constraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.accentColor, size: 20),
              onPressed: onDelete,
              constraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _emptyState(String emoji, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey)),
      ],
    ),
  );
}

void _confirmDelete(
  BuildContext context,
  String message,
  Future<void> Function() onConfirm,
) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: AppTheme.accentColor),
        SizedBox(width: 8),
        Text('تأكيد الحذف',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
      ]),
      content: Text(
        '$message\n\nلا يمكن التراجع عن هذه العملية.',
        style: const TextStyle(fontFamily: 'Cairo', height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء',
              style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await onConfirm();
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor),
          icon: const Icon(Icons.delete, color: Colors.white, size: 16),
          label: const Text('حذف نهائياً',
              style: TextStyle(
                  fontFamily: 'Cairo', color: Colors.white)),
        ),
      ],
    ),
  );
}
