import 'package:decog_gsk/dashboard_modules/connected.dart';
import 'package:decog_gsk/dashboard_modules/leak.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_modules/disconnected.dart';
import 'diagnosis_page.dart';

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
      // Fetch device status from Supabase
      final response = await supabase
          .from("sensor_live")
          .select('sensor_online')
          .single();

      if (!mounted) return;

      // Check the status and navigate accordingly
      final bool isConnected = response['sensor_online'] as bool;

      if (isConnected) {
        // Navigate to DeviceDashboard if connected
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DeviceDashboard(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      } else {
        // Navigate to DisconnectedDev if not connected
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DisconnectedDev(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    } catch (error) {
      // Handle errors (network issues, database errors, etc.)
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking device status: $error')),
      );

      // Navigate to error/disconnected screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DisconnectedDev()),
      );
    }
  }  // ← MISSING closing brace was here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 49, 50, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromRGBO(215, 162, 101, 1),
              ),
              width: 60,
              height: 60,
              child: Center(
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
