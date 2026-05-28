// lib/insights/profiles/services/base_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class BaseService {
  final SupabaseClient _supabase;

  BaseService() : _supabase = Supabase.instance.client;

  // Getter untuk supabase (internal use)
  SupabaseClient get supabase => _supabase;

  // Helper getters untuk tanggal
  String get today {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  String get sevenDaysAgo {
    return DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
  }

  String get firstDayOfMonth {
    return DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String().split('T')[0];
  }

  // 🔥 PERUBAHAN: Method log dengan parameter level untuk indentasi
  void log(String message, [int level = 0]) {
    final indent = '  ' * level;
    print('📦 [Service] $indent$message');
  }

  // 🔥 PERUBAHAN: Method logError dengan parameter level untuk indentasi
  void logError(String message, [dynamic error, StackTrace? stackTrace, int level = 0]) {
    final indent = '  ' * level;
    print('❌ [Service] $indent$message');
    if (error != null) print('   Error: $error');
    if (stackTrace != null) print('   StackTrace: $stackTrace');
  }
}