import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Cloud Supabase credentials
  static const String cloudUrl = 'https://mrqxzkaowylemjpqasdw.supabase.co';
  static const String cloudAnonKey = 'sb_publishable_cNRFJ6aCyp7Ry5dqoj8vkg_KN8B-L79';

  // Raspberry Pi (Local Hub) credentials via Tailscale
  // Replace with your actual Raspberry Pi Tailscale IP and credentials
  static const String localUrl = 'http://100.111.59.127:8000';  // Your Tailscale IP
  static const String localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzY2MTQ2NTMwLCJleHAiOjIwODE1MDY1MzB9.zWVf3-iC6j-VTo9YHm_4xGaKvaY4HgmlGBuvC9yO3pQ';

  // Preference key
  static const String _prefKey = 'use_decog_hub';

  // Get current hub preference
  static Future<bool> isUsingLocalHub() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false; // Default to cloud
  }

  // Save hub preference
  static Future<void> setUseLocalHub(bool useLocal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, useLocal);
  }

  // Get current credentials based on preference
  static Future<Map<String, String>> getCurrentCredentials() async {
    final useLocal = await isUsingLocalHub();
    return {
      'url': useLocal ? localUrl : cloudUrl,
      'anonKey': useLocal ? localAnonKey : cloudAnonKey,
    };
  }

  // Initialize or reinitialize Supabase
  static Future<void> initializeSupabase({bool forceReinit = false}) async {
    try {
      final credentials = await getCurrentCredentials();
      final isLocal = await isUsingLocalHub();

      if (forceReinit) {
        // Dispose existing client
        await Supabase.instance.dispose();
        debugPrint('🔄 Supabase client disposed');
      }

      await Supabase.initialize(
        url: credentials['url']!,
        anonKey: credentials['anonKey']!,
      );

      debugPrint('✓ Supabase initialized successfully');
      debugPrint('📡 Using ${isLocal ? "Local Hub (Raspberry Pi)" : "Cloud Server"}');
      debugPrint('🌐 URL: ${credentials['url']}');
    } catch (e) {
      debugPrint('✗ Supabase initialization error: $e');
      rethrow;
    }
  }

  // Switch between hub and cloud
  static Future<void> switchHub(bool useLocal) async {
    debugPrint('🔄 Switching to ${useLocal ? "Local Hub" : "Cloud Server"}...');
    await setUseLocalHub(useLocal);
    await initializeSupabase(forceReinit: true);
  }
}
