import 'package:decog_gsk/config/supabase_config.dart';  // ADD THIS
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
  bool useDecogHub = false;  // ADD THIS
  bool isLoading = true;     // ADD THIS
  Color clickBorder = const Color.fromRGBO(36, 68, 67, 1);

  @override
  void initState() {
    super.initState();
    StatusMonitor.stopMonitoring();
    _loadHubPreference();  // ADD THIS
  }

  // Load saved hub preference
  Future<void> _loadHubPreference() async {
    final isLocal = await SupabaseConfig.isUsingLocalHub();
    setState(() {
      useDecogHub = isLocal;
      isLoading = false;
    });
  }

  // Toggle hub preference
  Future<void> _toggleHub(bool value) async {
    setState(() {
      isLoading = true;
    });

    try {
      await SupabaseConfig.switchHub(value);

      if (mounted) {
        setState(() {
          useDecogHub = value;
          isLoading = false;
        });

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '✓ Switched to Decog Hub (Local Server)'
                  : '✓ Switched to Cloud Server',
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
              SizedBox(height: screenHeight * 0.15),

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

              const SizedBox(height: 30),

              // DECOG HUB SWITCH - NEW ADDITION
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(36, 68, 67, 1),
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
                        child: Text(
                          "Use Decog Hub",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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
