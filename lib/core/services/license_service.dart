// lib/core/services/license_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// Import khusus web (hanya web)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LicenseService {
  static const String _licenseFileName = 'license.lic';
  
  /// Prioritas: Cek file license di storage dulu, baru fallback ke asset
  /// 
  /// Returns:
  ///   - Map<String, dynamic> jika license ditemukan (production)
  ///   - null jika tidak ditemukan (demo mode)
  static Future<Map<String, dynamic>?> getLicenseConfig() async {
    // 1. Coba baca dari file di storage (production license) - Mobile/Desktop
    final fileConfig = await _readFromStorage();
    if (fileConfig != null) {
      debugPrint('✅ License found in storage (PRODUCTION MODE)');
      return fileConfig;
    }
    
    // 2. Web: cek localStorage
    if (kIsWeb) {
      final webConfig = _readFromWebLocalStorage();
      if (webConfig != null) {
        debugPrint('✅ License found in localStorage (PRODUCTION MODE)');
        return webConfig;
      }
    }
    
    debugPrint('⚠️ No license found, using DEMO mode');
    return null;
  }
  
  /// Baca file license dari storage (Android/iOS/Desktop)
  static Future<Map<String, dynamic>?> _readFromStorage() async {
    // Jika web, skip (pakai localStorage)
    if (kIsWeb) return null;
    
    try {
      Directory directory;
      
      if (Platform.isAndroid || Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationSupportDirectory();
      }
      
      final file = File('${directory.path}/$_licenseFileName');
      
      if (!await file.exists()) {
        return null;
      }
      
      final content = await file.readAsString();
      final config = jsonDecode(content);
      
      // Validasi minimal: harus ada supabase_url dan anon_key
      if (config['supabase_url'] == null || config['supabase_anon_key'] == null) {
        debugPrint('⚠️ License file invalid: missing required fields');
        return null;
      }
      
      return Map<String, dynamic>.from(config);
      
    } catch (e) {
      debugPrint('❌ Error reading license from storage: $e');
      return null;
    }
  }
  
  /// Simpan license ke storage (dipanggil saat upgrade)
  static Future<bool> saveLicense(Map<String, dynamic> license) async {
    try {
      // Web: simpan ke localStorage
      if (kIsWeb) {
        _saveLicenseToWebLocalStorage(license);
        return true;
      }
      
      // Mobile/Desktop: simpan ke file
      Directory directory;
      
      if (Platform.isAndroid || Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationSupportDirectory();
      }
      
      final file = File('${directory.path}/$_licenseFileName');
      await file.writeAsString(jsonEncode(license));
      
      debugPrint('✅ License saved to: ${file.path}');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error saving license: $e');
      return false;
    }
  }
  
  /// Hapus license (reset ke demo mode)
  static Future<bool> deleteLicense() async {
    try {
      // Web: hapus dari localStorage
      if (kIsWeb) {
        _deleteLicenseFromWebLocalStorage();
        return true;
      }
      
      // Mobile/Desktop: hapus file
      Directory directory;
      
      if (Platform.isAndroid || Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationSupportDirectory();
      }
      
      final file = File('${directory.path}/$_licenseFileName');
      
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ License deleted, back to DEMO mode');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Error deleting license: $e');
      return false;
    }
  }
  
  /// Cek apakah license ada (tanpa baca isi)
  static Future<bool> isLicenseExists() async {
    try {
      // Web: cek localStorage
      if (kIsWeb) {
        final license = html.window.localStorage['rsmss_license'];
        return license != null;
      }
      
      // Mobile/Desktop: cek file
      Directory directory;
      
      if (Platform.isAndroid || Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationSupportDirectory();
      }
      
      final file = File('${directory.path}/$_licenseFileName');
      return await file.exists();
      
    } catch (e) {
      return false;
    }
  }
  
  // ==================== WEB SUPPORT (dart:html) ====================
  
  static Map<String, dynamic>? _readFromWebLocalStorage() {
    if (!kIsWeb) return null;
    
    try {
      final licenseJson = html.window.localStorage['rsmss_license'];
      if (licenseJson == null) return null;
      
      final config = jsonDecode(licenseJson);
      
      if (config['supabase_url'] == null || config['supabase_anon_key'] == null) {
        return null;
      }
      
      return Map<String, dynamic>.from(config);
      
    } catch (e) {
      debugPrint('❌ Error reading license from localStorage: $e');
      return null;
    }
  }
  
  static void _saveLicenseToWebLocalStorage(Map<String, dynamic> license) {
    if (!kIsWeb) return;
    html.window.localStorage['rsmss_license'] = jsonEncode(license);
    debugPrint('✅ License saved to localStorage');
  }
  
  static void _deleteLicenseFromWebLocalStorage() {
    if (!kIsWeb) return;
    html.window.localStorage.remove('rsmss_license');
    debugPrint('✅ License removed from localStorage');
  }
}