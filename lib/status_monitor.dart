import 'dart:async';
import 'dart:io';
import 'package:decog_gsk/dashboard_modules/sensor_disconnected.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_modules/connected.dart';
import 'dashboard_modules/disconnected.dart';
import 'dashboard_modules/leak.dart';

class StatusMonitor {
  static Timer? _statusTimer;
  static String? _currentScreen;
  static final supabase = Supabase.instance.client;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isFirstCheck = true;

  // Timeout threshold in seconds
  static const int timeoutThreshold = 15;

  // Start monitoring
  static void startMonitoring() {
    debugPrint('📡 Status monitoring started');

    // Check immediately
    _checkAndNavigate();

    // Then check every 3 seconds
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkAndNavigate();
    });
  }

  // Stop monitoring
  static void stopMonitoring() {
    debugPrint('📡 Status monitoring stopped');
    _statusTimer?.cancel();
    _statusTimer = null;
    _currentScreen = null;
    _isFirstCheck = true;
  }

  // Check status and navigate if needed
  // Add a flag to prevent concurrent checks
  static bool _isChecking = false;

// Update _checkAndNavigate method:
  static Future<void> _checkAndNavigate() async {
    // Prevent concurrent checks
    if (_isChecking) {
      debugPrint('⏭️ Skipping check - another check is in progress');
      return;
    }

    _isChecking = true;

    try {
      final response = await supabase
          .from('sensor_live')
          .select('timestamp, status, sensor_online')
          .order('timestamp', ascending: false)
          .limit(1)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Database query timeout');
        },
      );

      // ... rest of your existing code ...

    } catch (error) {
      debugPrint('❌ Status check error: $error');
      _handleError('disconnected', error.toString());
    } finally {
      _isChecking = false;  // Always reset the flag
    }
  }


  // Handle errors consistently
  static void _handleError(String targetScreen, String reason) {
    if (_currentScreen != targetScreen) {
      if (_isFirstCheck) {
        debugPrint('📍 Error occurred - showing: $targetScreen ($reason)');
        _currentScreen = targetScreen;
        _isFirstCheck = false;
      } else {
        debugPrint('🔄 Error - switching to: $targetScreen ($reason)');
        _currentScreen = targetScreen;
        _navigateToScreen(targetScreen);
      }
    } else if (_isFirstCheck) {
      _isFirstCheck = false;
    }
  }

  // Navigate to the appropriate screen
  // Replace the _navigateToScreen method (starting at line 158) with this improved version:
  static void _navigateToScreen(String screen) {
    // Use navigatorKey.currentState directly instead of context
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) {
      debugPrint('⚠️ Navigator state is null');
      return;
    }

    Widget targetWidget;

    switch (screen) {
      case 'sensor_disconnected':
        targetWidget = const SensorDisconnected();
        break;
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

    // Use navigatorState directly
    // In status_monitor.dart, update _navigateToScreen:
    navigatorState.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}
