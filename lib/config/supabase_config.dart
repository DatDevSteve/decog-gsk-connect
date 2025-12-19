import 'dart:io';
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
  static const String localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzY2MDgyNjAwLCJleHAiOjE5MjM4NDkwMDB9.yb7AUzinWDW754uzbUmWDJyJ_H2ZAg_dXeDFiCwxUVQ';

  // Preference keys
  static const String _prefKey = 'use_decog_hub';
  static const String _autoSwitchKey = 'auto_switch_hub';

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

  // Get auto-switch preference
  static Future<bool> getAutoSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSwitchKey) ?? true; // Default to true
  }

  // Save auto-switch preference
  static Future<void> setAutoSwitch(bool autoSwitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSwitchKey, autoSwitch);
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
  static Future<bool> canReachHost(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Initialize or reinitialize Supabase
  static Future<void> initializeSupabase({bool forceReinit = false}) async {
    try {
      bool useLocal = await isUsingLocalHub();
      final autoSwitch = await getAutoSwitch();

      // Auto-switch logic if enabled
      if (autoSwitch) {
        debugPrint('🔄 Auto-switch enabled, checking connectivity...');

        if (!useLocal) {
          // Try cloud first
          final cloudReachable = await canReachHost('mrqxzkaowylemjpqasdw.supabase.co', 443);
          if (!cloudReachable) {
            debugPrint('⚠️ Cloud unreachable, checking local hub...');
            final localReachable = await canReachHost('100.111.59.127', 8000);
            if (localReachable) {
              debugPrint('✅ Local hub reachable, auto-switching...');
              useLocal = true;
              await setUseLocalHub(true);
            } else {
              debugPrint('⚠️ Both cloud and local unreachable');
            }
          }
        } else {
          // Try local first
          final localReachable = await canReachHost('100.111.59.127', 8000);
          if (!localReachable) {
            debugPrint('⚠️ Local hub unreachable, checking cloud...');
            final cloudReachable = await canReachHost('mrqxzkaowylemjpqasdw.supabase.co', 443);
            if (cloudReachable) {
              debugPrint('✅ Cloud reachable, auto-switching...');
              useLocal = false;
              await setUseLocalHub(false);
            } else {
              debugPrint('⚠️ Both local and cloud unreachable');
            }
          }
        }
      }

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

      // Test connection
      await _testConnection(useLocal);
    } catch (e) {
      debugPrint('❌ Supabase initialization error: $e');
      rethrow;
    }
  }

  // Test database connection with timeout
  static Future<bool> _testConnection(bool isLocal) async {
    try {
      debugPrint('🔍 Testing connection to ${isLocal ? "Local" : "Cloud"} database...');

      final response = await Supabase.instance.client
          .from('sensor_live')
          .select('timestamp')
          .limit(1)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      debugPrint('✅ Database connection test successful');
      debugPrint('   Retrieved ${response.length} record(s)');
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

  // Switch between hub and cloud
  static Future<void> switchHub(bool useLocal) async {
    debugPrint('🔄 Switching to ${useLocal ? "Local Hub" : "Cloud Server"}...');
    await setUseLocalHub(useLocal);
    await initializeSupabase(forceReinit: true);
  }

  // Get connection status
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final useLocal = await isUsingLocalHub();
    final cloudReachable = await canReachHost('mrqxzkaowylemjpqasdw.supabase.co', 443);
    final localReachable = await canReachHost('100.111.59.127', 8000);

    return {
      'current': useLocal ? 'local' : 'cloud',
      'cloudReachable': cloudReachable,
      'localReachable': localReachable,
    };
  }
}
