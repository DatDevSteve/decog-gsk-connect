import 'package:decog_gsk/dashboard_modules/threshold_slider_widget.dart';
import 'package:decog_gsk/switcher_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'device_list.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  @override
  Widget build(BuildContext context) {
    const bg = Color.fromRGBO(28, 49, 50, 1);
    const gold = Color.fromRGBO(215, 162, 101, 1);
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: bg,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              // Wrap navigation in addPostFrameCallback
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          LoadingSwitch(),
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
                }
              });
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 23),
          ),
        ),
        centerTitle: true,
        title: Text(
          "S E T T I N G S",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          ThresholdSliderWidget()
        ],),
      ),
    );
  }
}
