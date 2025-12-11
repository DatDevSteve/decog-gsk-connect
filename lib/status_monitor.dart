import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard_modules/connected.dart';
import '../dashboard_modules/disconnected.dart';
import '../dashboard_modules/leak.dart';

class StatusMonitor {
  static Timer? _statusTimer;
  static String? _currentScreen;
  static final supabase = Supabase.instance.client;

  // Start monitoring
  static void startMonitoring(BuildContext context) {
    debugPrint('📡 Status monitoring started');

    // Check immediately
    _checkAndNavigate(context);

    // Then check every 3 seconds
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkAndNavigate(context);
    });
  }

  // Stop monitoring
  static void stopMonitoring() {
    debugPrint('📡 Status monitoring stopped');
    _statusTimer?.cancel();
    _statusTimer = null;
    _currentScreen = null;
  }

  // Check status and navigate if needed
  static Future<void> _checkAndNavigate(BuildContext context) async {
    try {
      final response = await supabase
          .from('sensor_live')
          .select('timestamp, status')
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      if (!context.mounted) return;

      final String timestampStr = response['timestamp'] as String;
      final DateTime lastUpdate = DateTime.parse(timestampStr);
      final String status = (response['status'] as String).toUpperCase();
      final DateTime now = DateTime.now();
      final int secondsSinceLastUpdate = now.difference(lastUpdate).inSeconds;
      final bool isOnline = secondsSinceLastUpdate <= 20;

      String targetScreen;

      // Determine which screen should be showing
      if (!isOnline) {
        targetScreen = 'disconnected';
      } else if (status == 'HIGH') {
        targetScreen = 'leak';
      } else {
        targetScreen = 'connected';
      }

      // Only navigate if we need to switch screens
      if (_currentScreen != targetScreen) {
        debugPrint('🔄 Status changed: $_currentScreen -> $targetScreen');
        _currentScreen = targetScreen;
        _navigateToScreen(context, targetScreen);
      } else {
        debugPrint('✓ Status unchanged: $targetScreen (${secondsSinceLastUpdate}s ago)');
      }
    } catch (error) {
      debugPrint('❌ Status check error: $error');
    }
  }

  // Navigate to the appropriate screen
  static void _navigateToScreen(BuildContext context, String screen) {
    if (!context.mounted) return;

    Widget targetWidget;

    switch (screen) {
      case 'leak':
        targetWidget = const DeviceLeak();
        break;
      case 'disconnected':
        targetWidget = const DisconnectedDev();
        break;
      case 'connected':
      default:
        targetWidget = const DashboardScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
