import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseConfig {
  // Cloud Supabase credentials
  static const String cloudUrl = 'https://mrqxzkaowylemjpqasdw.supabase.co';
  static const String cloudAnonKey = 'sb_publishable_cNRFJ6aCyp7Ry5dqoj8vkg_KN8B-L79';

  // Raspberry Pi (Local Hub) credentials via Tailscale
  static const String localUrl = 'http://100.111.59.127:8000';
  static const String localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzY2MDgyNjAwLCJleHAiOjE5MjM4NDkwMDB9.yb7AUzinWDW754uzbUmWDJyJ_H2ZAg_dXeDFiCwxUVQ';

  // Preference key
  static const String _prefKey = 'use_decog_hub';

  // Callback for auto-switch notifications
  static void Function(String serverType)? onAutoSwitch;

  // Get current hub preference
  static Future<bool> isUsingLocalHub() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
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

  // Check network connectivity to a specific host
  static Future<bool> canReachServer(String url) async {
    try {
      // Test the /rest/v1/ endpoint (Supabase REST API)
      final testUrl = url.endsWith('/') ? '${url}rest/v1/' : '$url/rest/v1/';

      final response = await http.head(
        Uri.parse(testUrl),
        headers: {
          'apikey': url.contains('supabase.co') ? cloudAnonKey : localAnonKey,
        },
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw TimeoutException('Server timeout'),
      );

      // Accept any 2xx, 3xx, 401, or 404 (server is reachable)
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('   Server test failed: $e');
      return false;
    }
  }

  // Test database connection with timeout
  static Future<bool> _testConnection(bool isLocal) async {
    try {
      debugPrint('🔍 Testing connection to ${isLocal ? "Local" : "Cloud"} database...');

      final response = await Supabase.instance.client
          .from('sensor_live')
          .select('timestamp')
          .eq('id', 1)  // ✅ Use specific row for consistency
          .single()
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      debugPrint('✅ Database connection test successful');
      debugPrint('   Retrieved timestamp: ${response['timestamp']}');
      return true;
    } catch (e) {
      debugPrint('❌ Database connection test failed: $e');

      if (e.toString().contains('401')) {
        debugPrint('   💡 Hint: Authentication error - check your anon key');
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('timeout')) {
        debugPrint('   💡 Hint: Network/DNS error - check connection or Tailscale');
      }

      debugPrint('⚠️ Continuing with initialization despite connection test failure');
      return false;
    }
  }


  // Initialize or reinitialize Supabase with auto-switch ALWAYS enabled
  static Future<void> initializeSupabase({bool forceReinit = false}) async {
    try {
      bool useLocal = await isUsingLocalHub();

      final credentials = await getCurrentCredentials();

      if (forceReinit) {
        await Supabase.instance.dispose();
        debugPrint('🔄 Supabase client disposed');
      }

      await Supabase.initialize(
        url: credentials['url']!,
        anonKey: credentials['anonKey']!,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      debugPrint('✅ Supabase initialized successfully');
      debugPrint('📡 Using ${useLocal ? "Local Hub (Raspberry Pi)" : "Cloud Server"}');
      debugPrint('🌐 URL: ${credentials['url']}');

      // Test actual database connection (not HTTP HEAD)
      await _testConnection(useLocal);

    } catch (e) {
      debugPrint('❌ Supabase initialization error: $e');
      rethrow;
    }
  }


  // Switch between hub and cloud manually
  static Future<void> switchHub(bool useLocal) async {
    debugPrint('🔄 Manually switching to ${useLocal ? "Local Hub" : "Cloud Server"}...');
    await setUseLocalHub(false);
    await initializeSupabase(forceReinit: true);  // ✅ No pre-checks
  }

  // Get connection status
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final useLocal = await isUsingLocalHub();
    final cloudReachable = await canReachServer(cloudUrl);  // ✅ FIXED
    final localReachable = await canReachServer(localUrl);  // ✅ FIXED

    return {
      'current': useLocal ? 'local' : 'cloud',
      'cloudReachable': cloudReachable,
      'localReachable': localReachable,
    };
  }
}
