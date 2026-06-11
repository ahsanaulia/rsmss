import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rsmss/main.dart' as app;

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _restartApp() {
    // Restart aplikasi dengan memanggil runApp ulang
    app.main();
  }

  Future<void> _processQrCode(String qrData) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse QR data sebagai JSON
      final Map<String, dynamic> qrConfig = jsonDecode(qrData);

      // Validasi field yang diperlukan
      if (!qrConfig.containsKey('supabase_url')) {
        throw Exception('QR Code tidak valid: field "supabase_url" tidak ditemukan');
      }
      if (!qrConfig.containsKey('supabase_anon_key')) {
        throw Exception('QR Code tidak valid: field "supabase_anon_key" tidak ditemukan');
      }

      // Simpan ke SecureStorage dengan key 'rsmss_config'
      await _storage.write(key: 'rsmss_config', value: qrData);

      if (!mounted) return;

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfigurasi tenant berhasil disimpan. Aplikasi akan di-restart.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Tunggu sebentar agar snackbar terlihat, lalu restart
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        _restartApp();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses QR: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Tenant'),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _scannerController.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && !_isProcessing) {
                  _scannerController.stop();
                  _processQrCode(rawValue);
                  break;
                }
              }
            },
          ),
          // Overlay guide
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Arahkan kamera ke QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tombol flashlight
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.flashlight_on, color: Colors.white, size: 30),
                onPressed: () {
                  _scannerController.toggleTorch();
                },
              ),
            ),
          ),
          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Memproses QR Code...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}