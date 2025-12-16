import 'package:decog_gsk/device_list.dart';
import 'package:decog_gsk/diagnosis_page.dart';
import 'package:decog_gsk/status_monitor.dart';
import 'package:decog_gsk/switcher_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SensorDisconnected extends StatefulWidget {
  const SensorDisconnected({super.key});

  @override
  State<SensorDisconnected> createState() => _SensorDisconnectedState();
}

class _SensorDisconnectedState extends State<SensorDisconnected> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      StatusMonitor.startMonitoring();
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
        title: Text(
          'D A S H B O A R D',
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(215, 162, 101, 1),
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(215, 162, 101, 1),
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DeviceList(),
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
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            const SizedBox(height: 40),

            // Circular device image with gradient background
            Stack(
              alignment: Alignment.center,
              children: [
                // Gradient circle background
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromRGBO(180, 255, 180, 1),
                        const Color.fromRGBO(100, 200, 100, 1).withOpacity(0.6),
                        const Color.fromRGBO(28, 49, 50, 1).withOpacity(0.2),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),

                // Clipped device image
                ClipOval(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(28, 49, 50, 1),
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/device_connected.png',
                        width: 540,
                        height: 780,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.developer_board,
                            size: 100,
                            color: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Status button
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                child: Center(
                  child: Text(
                    'SENSOR DISCONNECTED',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),


            const Spacer(),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Container(
                width: 350,
                //height: 100,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(139, 5, 5, 1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromRGBO(245, 15, 15, 1),
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Text(
                        "Device Disconnected",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 1, 5, 5),
                      child: Text(
                        "Unable to connect with device. Please check station module for low battery or any issues.",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
