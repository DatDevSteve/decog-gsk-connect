import 'dart:async';
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
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isFirstCheck = true;  // ADD THIS FLAG

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
    _isFirstCheck = true;  // Reset flag when stopping
  }

  // Check status and navigate if needed
  static Future<void> _checkAndNavigate() async {
    try {
      final response = await supabase
          .from('sensor_live')
          .select('timestamp, status, sensor_online')
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      final String timestampStr = response['timestamp'] as String;

      // Parse as UTC timestamp (Supabase stores in UTC)
      final DateTime lastUpdateUTC = DateTime.parse(timestampStr).toUtc();

      // Get current time in UTC for accurate comparison
      final DateTime nowUTC = DateTime.now().toUtc();

      final bool sensorOnline = response['sensor_online'];

      final String status = (response['status'] as String).toUpperCase();

      // Calculate the difference in seconds
      final int secondsSinceLastUpdate = nowUTC.difference(lastUpdateUTC).inSeconds;
      final bool isOnline = secondsSinceLastUpdate <= 20;

      // Convert to local time for display purposes
      final DateTime lastUpdateLocal = lastUpdateUTC.toLocal();
      final DateTime nowLocal = nowUTC.toLocal();

      String targetScreen;

      // Determine which screen should be showing
      if (!isOnline) {
        targetScreen = 'disconnected';
      } else if (status == 'HIGH') {
        targetScreen = 'leak';
      } else {
        targetScreen = 'connected';
      }

      if (!sensorOnline) {
        targetScreen = "sensor_disconnected";
      }

      // Only navigate if we need to switch screens
      if (_currentScreen != targetScreen) {
        // Skip navigation on first check (we're already on correct screen from LoadingSwitch)
        if (_isFirstCheck) {
          debugPrint('📍 Initial screen set to: $targetScreen (skipping navigation)');
          _currentScreen = targetScreen;
          _isFirstCheck = false;
        } else {
          debugPrint('🔄 Status changed: $_currentScreen -> $targetScreen');
          debugPrint('   Last update: $lastUpdateLocal (Local) / $lastUpdateUTC (UTC)');
          debugPrint('   Current time: $nowLocal (Local) / $nowUTC (UTC)');
          debugPrint('   Time diff: ${secondsSinceLastUpdate}s ago');
          debugPrint('   Status: $status');
          _currentScreen = targetScreen;
          _navigateToScreen(targetScreen);
        }
      } else {
        // After first check, disable the flag
        if (_isFirstCheck) {
          _isFirstCheck = false;
        }
        debugPrint('✓ Status unchanged: $targetScreen (${secondsSinceLastUpdate}s ago, status: $status)');
      }
    } catch (error) {
      debugPrint('❌ Status check error: $error');
    }
  }

  // Navigate to the appropriate screen
  static void _navigateToScreen(String screen) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('⚠️ Navigator context is null');
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
