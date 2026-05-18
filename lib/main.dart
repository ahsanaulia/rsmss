
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rsmss/core/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // ✅ SUDAH ADA
import 'package:intl/date_symbol_data_local.dart'; 

// Pastikan path import ini sesuai dengan struktur folder Anda
import 'package:rsmss/views/main_screen.dart';

void main() async {
  // Menjamin inisialisasi framework Flutter selesai sebelum memanggil plugin native
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Storage Aman (untuk menyimpan lisensi production nanti)
  const storage = FlutterSecureStorage();

   await initializeDateFormatting('id_ID', null);  
  
  // 2. Variabel penampung konfigurasi
  Map<String, dynamic> config;
  
  try {
    // Cek apakah user pernah meng-import file lisensi sendiri di memori internal
    String? localConfig = await storage.read(key: 'rsmss_config');
    
    if (localConfig != null) {
      // Jika ada lisensi production hasil import
      config = jsonDecode(localConfig);
    } else {
      // Jika instalasi baru/demo, baca file dari assets/config/rsmss.config
      final String response = await rootBundle.loadString('assets/config/rsmss.config');
      config = jsonDecode(response);
    }

    // 3. Jalankan Supabase secara Dinamis berdasarkan isi config
    await Supabase.initialize(
      url: config['supabase_url'],
      anonKey: config['supabase_anon_key'],
    );
    await setupServiceLocator();
    
  } catch (e) {
    // Logika error jika file config tidak ditemukan atau format salah
    debugPrint("Error Initializing Configuration: $e");
  }

  // 🔴 PERUBAHAN HANYA DI SINI 🔴
  // Bungkus RSMSSApp dengan ProviderScope
  runApp(
    const ProviderScope(  // ← TAMBAHKAN INI
      child: RSMSSApp(),
    ),
  );
}

class RSMSSApp extends StatelessWidget {
  const RSMSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RSMSS IoT',
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const MainScreen(),
    );
  }
}