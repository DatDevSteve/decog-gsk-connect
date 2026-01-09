import 'dart:async';
import 'dart:io';
import 'package:decog_gsk/dashboard_modules/connected.dart';
import 'package:decog_gsk/dashboard_modules/leak.dart';
import 'package:decog_gsk/dashboard_modules/sensor_disconnected.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_modules/disconnected.dart';

class LoadingSwitch extends StatefulWidget {
  const LoadingSwitch({super.key});

  @override
  State<LoadingSwitch> createState() => _LoadingSwitchState();
}

class _LoadingSwitchState extends State<LoadingSwitch> {
  final supabase = Supabase.instance.client;

  // Timeout threshold in seconds (must match status_monitor.dart)
  static const int timeoutThreshold = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceStatus();
    });
  }

  Future<void> _checkDeviceStatus() async {
    try {
      // ✅ FORCE FRESH DATA - Disable cache and explicitly filter by id=1
      final response = await supabase
          .from("sensor_live")
          .select('timestamp, status, sensor_online')
          .eq('id', 1)  // ✅ CRITICAL: Only get row with id=1
          .single()      // ✅ Get single row (not array)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Database query timeout');
        },
      );

      if (!mounted) return;

      // ✅ response is now a Map, not an array
      final String timestampStr = response['timestamp'] as String;
      final DateTime lastUpdateUTC = DateTime.parse(timestampStr).toUtc();
      final DateTime nowUTC = DateTime.now().toUtc();

      final bool sensorOnline = response['sensor_online'] ?? false;
      final String status = (response['status'] as String? ?? 'NORMAL').toUpperCase();

      final int secondsSinceLastUpdate = nowUTC.difference(lastUpdateUTC).inSeconds;

      debugPrint('📊 Initial status check:');
      debugPrint('   Last update: $secondsSinceLastUpdate seconds ago');
      debugPrint('   Last timestamp (UTC): $lastUpdateUTC');
      debugPrint('   Current time (UTC): $nowUTC');
      debugPrint('   Timeout threshold: ${timeoutThreshold}s');
      debugPrint('   Sensor online flag: $sensorOnline');
      debugPrint('   Status: $status');
      debugPrint('🔍 RAW DEBUG:');
      debugPrint('   Raw timestamp string: "$timestampStr"');
      debugPrint('   Parsed UTC: $lastUpdateUTC');
      debugPrint('   Current UTC: $nowUTC');
      debugPrint('   Difference: $secondsSinceLastUpdate seconds');
      debugPrint('   Threshold: $timeoutThreshold seconds');

      final bool baseStationOnline = secondsSinceLastUpdate <= timeoutThreshold;

      if (!baseStationOnline) {
        debugPrint('➡️ Navigating to: DisconnectedDev (base station offline - ${secondsSinceLastUpdate}s ago)');
        _navigateToDisconnected();
      } else if (!sensorOnline) {
        debugPrint('➡️ Navigating to: SensorDisconnected (sensor board offline, base online)');
        _navigateToSensorDisconnected();
      } else if (status == 'HIGH') {
        debugPrint('➡️ Navigating to: LeakScreen (HIGH status detected)');
        _navigateToLeak();
      } else {
        debugPrint('➡️ Navigating to: DashboardScreen (all systems normal)');
        _navigateToDashboard();
      }
    } on PostgrestException catch (error) {
      debugPrint('❌ Supabase error: ${error.message}');
      if (!mounted) return;
      _navigateToDisconnected();
    } on SocketException catch (error) {
      debugPrint('❌ Network error checking device status: $error');
      if (!mounted) return;
      _navigateToDisconnected();
    } on TimeoutException catch (error) {
      debugPrint('❌ Timeout error checking device status: $error');
      if (!mounted) return;
      _navigateToDisconnected();
    } catch (error) {
      debugPrint('❌ Error checking device status: $error');
      if (!mounted) return;
      _navigateToDisconnected();
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToDisconnected() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const DisconnectedDev(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLeak() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const DeviceLeak(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToSensorDisconnected() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const SensorDisconnected(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(215, 162, 101, 1),
              ),
              width: 60,
              height: 60,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: Color.fromRGBO(28, 49, 50, 1),
                  strokeWidth: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
