import 'package:decog_gsk/device_list.dart';
import 'dart:async';
import 'package:decog_gsk/diagnosis_page.dart';
import 'package:decog_gsk/switcher_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  Timer? _gasLevelTimer;
  int _gasLevel = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGasLevel(); // Fetch immediately on load
    _startGasLevelUpdates(); // Start periodic updates
  }

  @override
  void dispose() {
    _gasLevelTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  void _startGasLevelUpdates() {
    _gasLevelTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchGasLevel();
    });
  }

  Future<void> _fetchGasLevel() async {
    try {
      final response = await supabase
          .from('sensor_live')
          .select('gas_level')
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          _gasLevel = response['gas_level'] as int;
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching gas level: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: const Color.fromRGBO(215, 162, 101, 1),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'NORMAL',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 30),

            // Gas Level Display
            Column(
              children: [
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color.fromRGBO(215, 162, 101, 1),
                        ),
                      )
                    : Text(
                        '$_gasLevel PPM',
                        style: GoogleFonts.dmSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(215, 162, 101, 1),
                          letterSpacing: 1,
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  'GAS LEVEL',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Power button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(215, 162, 101, 1),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Work in Progress, Coming Soon!',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Color.fromRGBO(215, 162, 101, 1),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Phone/Diagnosis button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(215, 162, 101, 1),
                        width: 3,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiagnosisPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
