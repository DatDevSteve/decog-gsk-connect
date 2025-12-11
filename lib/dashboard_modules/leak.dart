import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../device_list.dart';

class DeviceLeak extends StatelessWidget {
  const DeviceLeak({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color.fromRGBO(28, 49, 50, 1);
    const gold = Color.fromRGBO(215, 162, 101, 1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: bg,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DeviceList(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
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
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 23),
          ),
        ),
        centerTitle: true,
        title: Text(
          "D  A  S  H  B  O  A  R  D",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: gold,
          ),
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
                        'lib/assets/device_leak.png',
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
                width: 200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(139, 5, 5, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(245, 15, 15, 1),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'LEAK',
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
                width: 370,
                height: 110,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(139, 5, 5, 1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(245, 15, 15, 1),
                    width: 3,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 275,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 6, 5, 1),
                            child: Text(
                              "Gas Leakage Detected!",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 6, 20, 5),
                            child: Text(
                              "Gas flow has been stopped for your safety.",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromRGBO(245, 15, 15, 1),
                          width: 3,
                        ),
                      ),
                      child: Center(child: Text("!", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),)),
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
