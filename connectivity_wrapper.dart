// ============================================================
// widgets/connectivity_wrapper.dart
// يلفّ أي شاشة ويظهر رسالة عند انقطاع الإنترنت
// ============================================================
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_theme.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _listenToChanges();
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() => _isConnected = result != ConnectivityResult.none);
    }
  }

  void _listenToChanges() {
    Connectivity().onConnectivityChanged.listen((result) {
      final connected = result != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _isConnected = connected;
          _showBanner = !connected;
        });

        // إخفاء البانر تلقائياً عند استعادة الاتصال
        if (connected && _showBanner) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showBanner = false);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // بانر الاتصال
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: _showBanner ? 0 : -60,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: _isConnected ? Colors.green[700] : Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isConnected
                          ? 'تم استعادة الاتصال ✅'
                          : 'لا يوجد اتصال بالإنترنت',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
