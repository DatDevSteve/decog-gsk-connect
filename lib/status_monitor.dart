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
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
  static Future<void> _checkAndNavigate() async {
    try {
      // Query without .single() to handle empty results
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

      // Handle empty table
      if (response.isEmpty) {
        debugPrint('⚠️ No data in sensor_live table - showing sensor disconnected state');
        String targetScreen = 'sensor_disconnected';

        if (_currentScreen != targetScreen) {
          if (_isFirstCheck) {
            debugPrint('📍 Initial screen set to: $targetScreen (no data available)');
            _currentScreen = targetScreen;
            _isFirstCheck = false;
          } else {
            debugPrint('🔄 Status changed: $_currentScreen -> $targetScreen (no data)');
            _currentScreen = targetScreen;
            _navigateToScreen(targetScreen);
          }
        } else if (_isFirstCheck) {
          _isFirstCheck = false;
        }
        return;
      }

      // Get the first (most recent) record
      final data = response.first;
      final String timestampStr = data['timestamp'] as String;

      // Parse as UTC timestamp (Supabase stores in UTC)
      final DateTime lastUpdateUTC = DateTime.parse(timestampStr).toUtc();

      // Get current time in UTC for accurate comparison
      final DateTime nowUTC = DateTime.now().toUtc();

      final bool sensorOnline = data['sensor_online'] ?? false;

      final String status = (data['status'] as String? ?? 'NORMAL').toUpperCase();

      // Calculate the difference in seconds
      final int secondsSinceLastUpdate = nowUTC.difference(lastUpdateUTC).inSeconds;
      final bool isOnline = secondsSinceLastUpdate <= timeoutThreshold;

      // Convert to local time for display purposes
      final DateTime lastUpdateLocal = lastUpdateUTC.toLocal();
      final DateTime nowLocal = nowUTC.toLocal();

      String targetScreen;

      // Determine which screen should be showing
      if (!isOnline) {
        // Data is older than 30 seconds - device is offline
        if (!sensorOnline) {
          targetScreen = "sensor_disconnected";
          debugPrint('⚠️ Sensor marked offline and data is stale');
        } else {
          targetScreen = 'disconnected';
          debugPrint('⚠️ Base station offline - last update ${secondsSinceLastUpdate}s ago');
        }
      } else if (status == 'HIGH') {
        targetScreen = 'leak';
      } else {
        targetScreen = 'connected';
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
          debugPrint('   Time diff: ${secondsSinceLastUpdate}s ago (threshold: ${timeoutThreshold}s)');
          debugPrint('   Sensor online flag: $sensorOnline');
          debugPrint('   Status: $status');
          _currentScreen = targetScreen;
          _navigateToScreen(targetScreen);
        }
      } else {
        // After first check, disable the flag
        if (_isFirstCheck) {
          _isFirstCheck = false;
        }
        debugPrint('✅ Status unchanged: $targetScreen (${secondsSinceLastUpdate}s ago, status: $status, sensor_online: $sensorOnline)');
      }
    } on SocketException catch (e) {
      debugPrint('❌ Network error: $e');
      _handleError('sensor_disconnected', 'Network connection failed');
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error: $e');
      _handleError('sensor_disconnected', 'Request timeout');
    } catch (error) {
      debugPrint('❌ Status check error: $error');
      _handleError('sensor_disconnected', error.toString());
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
