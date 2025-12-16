import 'package:decog_gsk/device_list.dart';
import 'package:decog_gsk/status_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // ADD THIS IMPORT
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Supabase.initialize(
      url: 'https://mrqxzkaowylemjpqasdw.supabase.co',
      anonKey: 'sb_publishable_cNRFJ6aCyp7Ry5dqoj8vkg_KN8B-L79',
    );
    debugPrint('✓ Supabase initialized successfully');
  } catch (e) {
    debugPrint('✗ Supabase initialization error: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: StatusMonitor.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Decog GSK',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const DeviceList(),
    );
  }
}
