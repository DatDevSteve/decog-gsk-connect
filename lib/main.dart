import 'package:decog_gsk/device_list.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter binding is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: 'https://mrqxzkaowylemjpqasdw.supabase.co',
      anonKey: 'sb_publishable_cNRFJ6aCyp7Ry5dqoj8vkg_KN8B-L79',
    );
    debugPrint('✓ Supabase initialized successfully');
  } catch (e) {
    debugPrint('✗ Supabase initialization error: $e');
    // App will still run, but Supabase features won't work
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
