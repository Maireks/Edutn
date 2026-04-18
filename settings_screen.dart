// ============================================================
// screens/settings_screen.dart - إعدادات التطبيق
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _sectionHeader('المظهر'),
          _tile(
            context,
            icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            iconColor: AppTheme.primaryColor,
            title: 'الوضع الليلي',
            subtitle: themeProvider.isDarkMode ? 'مفعّل' : 'معطّل',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeColor: AppTheme.primaryColor,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          const Divider(height: 1),
          _sectionHeader('التطبيق'),
          _tile(
            context,
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: 'عن التطبيق',
            subtitle: 'EduTN v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _tile(
            context,
            icon: Icons.contact_support_outlined,
            iconColor: Colors.teal,
            title: 'تواصل معنا',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            ),
          ),
          _tile(
            context,
            icon: Icons.admin_panel_settings_outlined,
            iconColor: AppTheme.accentColor,
            title: 'دخول الأدمن',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
          ),
          const Divider(height: 1),
          _sectionHeader('المعلومات'),
          _tile(
            context,
            icon: Icons.school_outlined,
            iconColor: Colors.green,
            title: 'منصة EduTN',
            subtitle: 'منصة تعليمية مجانية للطلاب التونسيين',
          ),
          _tile(
            context,
            icon: Icons.flag_outlined,
            iconColor: Colors.red,
            title: 'تونس 🇹🇳',
            subtitle: 'مصنوع بـ ❤️ في تونس',
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'EduTN © 2024 — جميع الحقوق محفوظة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color iconColor = Colors.grey,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14) : null),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EduTN',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🎓', style: TextStyle(fontSize: 40)),
      children: const [
        Text(
          'منصة EduTN هي منصة تعليمية مجانية للطلاب التونسيين توفر دروساً، تمارين محلولة، وملفات PDF للمراجعة.',
          style: TextStyle(fontFamily: 'Cairo'),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}


// ============================================================
// screens/contact_us_screen.dart - التواصل معنا
// ============================================================

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // بطاقة الترحيب
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('📬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text(
                    'نحن هنا لمساعدتك',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تواصل معنا لأي استفسار أو اقتراح أو مشكلة تقنية',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withOpacity(0.85), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _contactItem(
            icon: '📧', title: 'البريد الإلكتروني',
            subtitle: 'contact@edtn.tn',
            onTap: () => _launch('mailto:contact@edtn.tn'),
          ),
          _contactItem(
            icon: '📱', title: 'واتساب',
            subtitle: '+216 XX XXX XXX',
            onTap: () => _launch('https://wa.me/21600000000'),
          ),
          _contactItem(
            icon: '🌐', title: 'الموقع الإلكتروني',
            subtitle: 'www.edtn.tn',
            onTap: () => _launch('https://edtn.tn'),
          ),
          _contactItem(
            icon: '📘', title: 'فيسبوك',
            subtitle: 'EduTN Tunisia',
            onTap: () => _launch('https://facebook.com/edtn'),
          ),
          _contactItem(
            icon: '📷', title: 'إنستغرام',
            subtitle: '@edtn_tn',
            onTap: () => _launch('https://instagram.com/edtn_tn'),
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primaryColor)),
        trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
