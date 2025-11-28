import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  bool showButton = false;
  Color clickBorder = Color.fromRGBO(36, 68, 67, 1);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Color.fromRGBO(28, 49, 50, 1)),
        backgroundColor: Color.fromRGBO(28, 49, 50, 1),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // Added this line
              children: [
                SizedBox(height: screenHeight * 0.1),
                Text(
                  "D E V I C E S",
                  style: GoogleFonts.dmSans(
                    color: Color.fromRGBO(215, 162, 101, 1),
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
                Center(
                  child: InkWell(
                    radius: 100,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Color.fromRGBO(215, 162, 101, 1),
                    onTap: () {
                      setState(() {
                        clickBorder =
                            clickBorder == Color.fromRGBO(36, 68, 67, 1)
                            ? Color.fromRGBO(215, 162, 101, 1)
                            : Color.fromRGBO(36, 68, 67, 1);
                      });
                    },
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: clickBorder, width: 3),
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                      color: Color.fromRGBO(36, 68, 67, 1),
                      child: SizedBox(
                        height: 90,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
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

              ],
            ),
          ),
        ),
      ),
    );
  }
}
