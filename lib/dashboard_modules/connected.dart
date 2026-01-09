import 'package:decog_gsk/device_list.dart';
import 'dart:async';
import 'package:decog_gsk/diagnosis_page.dart';
import 'package:decog_gsk/switcher_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../status_monitor.dart';
import '../config/supabase_config.dart';

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
    _fetchGasLevel();
    _startGasLevelUpdates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      StatusMonitor.startMonitoring();
    });
  }

  @override
  void dispose() {
    _gasLevelTimer?.cancel();
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

  void _showPowerControlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const PowerControlDialog(),
    );
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
                      onPressed: _showPowerControlDialog,
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

class PowerControlDialog extends StatefulWidget {
  const PowerControlDialog({super.key});

  @override
  State<PowerControlDialog> createState() => _PowerControlDialogState();
}

class _PowerControlDialogState extends State<PowerControlDialog> {
  bool _fanStatus = false;
  bool _valveStatus = false;
  bool _isLoadingStates = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStates();
  }

  Future<void> _fetchCurrentStates() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('sensor_live')
          .select('fan_status, valve_status')
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          _fanStatus = response['fan_status'] ?? false;
          _valveStatus = response['valve_status'] ?? false;
          _isLoadingStates = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching control states: $error');
      if (mounted) {
        setState(() {
          _isLoadingStates = false;
        });
      }
    }
  }

  Future<void> _updateControlState(String field, bool value) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Update both local and cloud databases
      final isUsingLocal = await SupabaseConfig.isUsingLocalHub();
      
      // Update current database (whichever is active)
      await _updateDatabase(Supabase.instance.client, field, value);
      
      // Also update the other database for sync
      try {
        final otherClient = await _getOtherSupabaseClient(isUsingLocal);
        if (otherClient != null) {
          await _updateDatabase(otherClient, field, value);
          debugPrint('✅ Updated both local and cloud databases');
        }
      } catch (e) {
        debugPrint('⚠️ Could not sync to other database: $e');
        // Continue even if other database fails
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${field == 'fan_status' ? 'Fan' : 'Valve'} ${value ? 'ON' : 'OFF'}',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color.fromRGBO(215, 162, 101, 1),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      debugPrint('❌ Error updating $field: $error');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update ${field == 'fan_status' ? 'fan' : 'valve'}',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Revert the switch state on error
        setState(() {
          if (field == 'fan_status') {
            _fanStatus = !value;
          } else {
            _valveStatus = !value;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _updateDatabase(SupabaseClient client, String field, bool value) async {
    try {
      // ✅ FIXED: Always target id=1 directly (no query needed)
      final response = await client
          .from('sensor_live')
          .update({field: value})
          .eq('id', 1);

      debugPrint('✅ $field updated successfully: $value');
      debugPrint('   Rows affected: ${response.data?.length ?? 0}');

    } catch (error) {
      debugPrint('❌ Error updating $field: $error');
      rethrow;
    }
  }

  Future<SupabaseClient?> _getOtherSupabaseClient(bool currentIsLocal) async {
    try {
      // Create a new client for the other database
      final credentials = currentIsLocal
          ? {
              'url': SupabaseConfig.cloudUrl,
              'anonKey': SupabaseConfig.cloudAnonKey,
            }
          : {
              'url': SupabaseConfig.localUrl,
              'anonKey': SupabaseConfig.localAnonKey,
            };

      return SupabaseClient(
        credentials['url']!,
        credentials['anonKey']!,
      );
    } catch (e) {
      debugPrint('Error creating other Supabase client: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(28, 49, 50, 1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(215, 162, 101, 1),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'POWER CONTROL',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(215, 162, 101, 1),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),

            // Loading indicator or controls
            if (_isLoadingStates)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(215, 162, 101, 1),
                ),
              )
            else ...[
              // Fan Control
              _buildControlRow(
                icon: Icons.mode_fan_off_outlined,
                label: 'EXHAUST FAN',
                value: _fanStatus,
                onChanged: _isUpdating
                    ? null
                    : (value) {
                        setState(() {
                          _fanStatus = value;
                        });
                        _updateControlState('fan_status', value);
                      },
              ),

              const SizedBox(height: 24),

              // Valve Control
              _buildControlRow(
                icon: Icons.water_drop_outlined,
                label: 'GAS VALVE',
                value: _valveStatus,
                onChanged: _isUpdating
                    ? null
                    : (value) {
                        setState(() {
                          _valveStatus = value;
                        });
                        _updateControlState('valve_status', value);
                      },
              ),
            ],

            const SizedBox(height: 30),

            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(215, 162, 101, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'CLOSE',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromRGBO(28, 49, 50, 1),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(28, 49, 50, 1),
        border: Border.all(
          color: const Color.fromRGBO(215, 162, 101, 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(215, 162, 101, 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromRGBO(215, 162, 101, 1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Label
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),

          // Switch
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color.fromRGBO(215, 162, 101, 1),
              activeTrackColor: const Color.fromRGBO(215, 162, 101, 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
