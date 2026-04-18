// ============================================================
// widgets/pull_to_refresh.dart - سحب للتحديث
// ============================================================
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      strokeWidth: 2.5,
      displacement: 48,
      child: child,
    );
  }
}
