import 'package:decog_gsk/dashboard_modules/connected.dart';
import 'package:decog_gsk/dashboard_modules/leak.dart';
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
    // Wrap navigation call in addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceStatus();
    });
  }

  Future<void> _checkDeviceStatus() async {
    try {
      // Fetch the latest timestamp and status from sensor_live table
      final response = await supabase
          .from("sensor_live")
          .select('timestamp, status')
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      if (!mounted) return;

      // Parse the timestamp from the database
      final String timestampStr = response['timestamp'] as String;
      final DateTime lastUpdate = DateTime.parse(timestampStr);

      // Get the status value
      final String status = (response['status'] as String).toUpperCase();

      // Get current time
      final DateTime now = DateTime.now();

      // Calculate the difference in seconds
      final int secondsSinceLastUpdate = now.difference(lastUpdate).inSeconds;

      debugPrint('Last update was $secondsSinceLastUpdate seconds ago');
      debugPrint('Last timestamp: $lastUpdate');
      debugPrint('Current time: $now');
      debugPrint('Status: $status');

      // Check if device is online (less than 20 seconds since last update)
      final bool isOnline = secondsSinceLastUpdate <= 20;

      // CORRECTED LOGIC: Check offline first, then status
      if (!isOnline) {
        // Device is offline - navigate to DisconnectedDev
        debugPrint('Navigating to: DisconnectedDev (offline)');
        _navigateToDisconnected();
      } else if (status == 'HIGH') {
        // Gas leak detected - navigate to LeakScreen
        debugPrint('Navigating to: LeakScreen (HIGH status)');
        _navigateToLeak();
      } else {
        // Status is LOW or NORMAL - navigate to DashboardScreen (connected)
        debugPrint('Navigating to: DashboardScreen (NORMAL/LOW status)');
        _navigateToDashboard();
      }
    } catch (error) {
      // Handle errors (network issues, database errors, etc.)
      debugPrint('Error checking device status: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking device status: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to disconnected screen on error
      _navigateToDisconnected();
    }
  }


  void _navigateToDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DashboardScreen(),
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
            DisconnectedDev(),
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
            DeviceLeak(),
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
