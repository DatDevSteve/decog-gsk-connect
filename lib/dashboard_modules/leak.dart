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
                    const begin = Offset(-1.0,0.0);
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
    );
  }
}
