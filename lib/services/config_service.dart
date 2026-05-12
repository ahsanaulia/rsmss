import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigService {
  static const _storage = FlutterSecureStorage();
  static const _configKey = 'rsmss_config';

  static Future<Map<String, dynamic>> getConfig() async {
    String? localConfig = await _storage.read(key: _configKey);
    
    if (localConfig != null) {
      return jsonDecode(localConfig);
    } else {
      final String response = await rootBundle.loadString('assets/config/rsmss.config');
      return jsonDecode(response);
    }
  }

  // Fungsi untuk menyimpan config baru saat user import file
  static Future<void> saveConfig(Map<String, dynamic> config) async {
    await _storage.write(key: _configKey, value: jsonEncode(config));
  }
}