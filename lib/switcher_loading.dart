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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceStatus();
    });
  }

  Future<void> _checkDeviceStatus() async {
    try {
      // Query without .single() to handle empty results
      final response = await supabase
          .from("sensor_live")
          .select('timestamp, status, sensor_online')
          .order('timestamp', ascending: false)
          .limit(1)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Database query timeout');
        },
      );

      if (!mounted) return;

      // Handle empty table
      if (response.isEmpty) {
        debugPrint('⚠️ No data in sensor_live table');
        _navigateToSensorDisconnected();
        return;
      }

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

      debugPrint('Last update was $secondsSinceLastUpdate seconds ago');
      debugPrint('Last timestamp (UTC): $lastUpdateUTC');
      debugPrint('Current time (UTC): $nowUTC');
      debugPrint('Sensor online: $sensorOnline');
      debugPrint('Status: $status');

      final bool isOnline = secondsSinceLastUpdate <= 20;

      if (!isOnline) {
        if (!sensorOnline) {
          debugPrint('Navigating to: SensorDisconnected (sensor offline)');
          _navigateToSensorDisconnected();
        } else {
          debugPrint('Navigating to: DisconnectedDev (base station offline)');
          _navigateToDisconnected();
        }
      } else if (status == 'HIGH') {
        debugPrint('Navigating to: LeakScreen (HIGH status)');
        _navigateToLeak();
      } else {
        debugPrint('Navigating to: DashboardScreen (NORMAL/LOW status)');
        _navigateToDashboard();
      }
    } on SocketException catch (error) {
      debugPrint('Network error checking device status: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error: Check your internet connection or Tailscale'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      _navigateToSensorDisconnected();
    } on TimeoutException catch (error) {
      debugPrint('Timeout error checking device status: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection timeout: Database is not responding'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      _navigateToSensorDisconnected();
    } catch (error) {
      debugPrint('Error checking device status: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      _navigateToSensorDisconnected();
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
