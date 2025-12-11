import 'package:decog_gsk/device_list.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mrqxzkaowylemjpqasdw.supabase.co',
    anonKey: 'sb_publishable_cNRFJ6aCyp7Ry5dqoj8vkg_KN8B-L79',
  );

  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DeviceList()
    );
  }
}
