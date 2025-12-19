import 'package:decog_gsk/config/supabase_config.dart';
import 'package:decog_gsk/status_monitor.dart';
import 'package:decog_gsk/switcher_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  bool showButton = false;
  bool useDecogHub = false;
  bool isLoading = true;
  Color clickBorder = const Color.fromRGBO(36, 68, 67, 1);
  Map<String, dynamic>? connectionStatus;

  @override
  void initState() {
    super.initState();
    StatusMonitor.stopMonitoring();

    // Set up auto-switch callback

    _loadPreferences();
  }

  @override
  void dispose() {
    // Clean up callback
    SupabaseConfig.onAutoSwitch = null;
    super.dispose();
  }


  // Load saved preferences and check connection
  Future<void> _loadPreferences() async {
    final isLocal = await SupabaseConfig.isUsingLocalHub();
    final status = await SupabaseConfig.getConnectionStatus();

    setState(() {
      useDecogHub = isLocal;
      connectionStatus = status;
      isLoading = false;
    });
  }

  // Toggle hub preference manually
  Future<void> _toggleHub(bool value) async {
    setState(() {
      isLoading = true;
    });

    try {
      await SupabaseConfig.switchHub(value);
      final status = await SupabaseConfig.getConnectionStatus();

      if (mounted) {
        setState(() {
          useDecogHub = value;
          connectionStatus = status;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '✓ Switched to Decog Hub'
                  : '✓ Switched to Decog Cloud',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color.fromRGBO(215, 162, 101, 1),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✗ Failed to switch: $e',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
          ),
        ));
      }
    }
  }

  // Refresh connection status
  Future<void> _refreshStatus() async {
    setState(() {
      isLoading = true;
    });

    final status = await SupabaseConfig.getConnectionStatus();

    setState(() {
      connectionStatus = status;
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
      ),
      backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Text(
                "D E V I C E S",
                style: GoogleFonts.dmSans(
                  color: const Color.fromRGBO(215, 162, 101, 1),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "View the list of connected devices",
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: screenHeight * 0.1),

              // Device Card
              Center(
                child: InkWell(
                  radius: 100,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: const Color.fromRGBO(215, 162, 101, 1),
                  onTap: () {
                    setState(() {
                      showButton = !showButton;
                      clickBorder = clickBorder == const Color.fromRGBO(36, 68, 67, 1)
                          ? const Color.fromRGBO(215, 162, 101, 1)
                          : const Color.fromRGBO(36, 68, 67, 1);
                    });
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: clickBorder, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: const Color.fromRGBO(36, 68, 67, 1),
                    child: SizedBox(
                      height: 90,
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.memory,
                              size: 50,
                              color: Color.fromRGBO(215, 162, 101, 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 20, 20, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gas Sensor System",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  "Decog GSK001",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Manual Hub Override Toggle
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.hub,
                        color: Color.fromRGBO(215, 162, 101, 1),
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Use Decog Hub",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Only for Local GSK Setups",
                              style: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromRGBO(215, 162, 101, 1),
                          ),
                        )
                      else
                        Switch(
                          value: useDecogHub,
                          onChanged: _toggleHub,
                          activeColor: const Color.fromRGBO(215, 162, 101, 1),
                          activeTrackColor: const Color.fromRGBO(215, 162, 101, 0.5),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade700,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: showButton
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const LoadingSwitch(),
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
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(215, 162, 101, 1),
        child: const Icon(
          Icons.arrow_forward,
          color: Color.fromRGBO(28, 49, 50, 1),
          size: 30,
        ),
      )
          : null,
    );
  }
}
