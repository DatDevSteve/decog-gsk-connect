import 'package:decog_gsk/diagnosis_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../device_list.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 49, 50, 1),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromRGBO(215, 162, 101, 1),
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DASHBOARD',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(215, 162, 101, 1),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Circular device image with gradient background
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
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/device_disconnected.png',
                    width: 120,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
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
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Status label
            Text(
              'STATUS',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
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
                        color: Colors.white.withOpacity(0.4),
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
                        // Handle power button action
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
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.phone_in_talk,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Handle phone/diagnosis action
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom indicator line
            Container(
              width: 120,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
