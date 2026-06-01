// lib/features/people/widgets/qr_code_dialog.dart

import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class QrCodeDialog extends StatelessWidget {
  final String rfidTagId;
  final String fullName;
  final String categoryName;
  final VoidCallback onClose;

  const QrCodeDialog({
    super.key,
    required this.rfidTagId,
    required this.fullName,
    required this.categoryName,
    required this.onClose,
  });

  String get qrData {
    final data = {
      'rfid_tag_id': rfidTagId,
      'full_name': fullName,
      'category': categoryName,
    };
    return jsonEncode(data);
  }

  Future<Uint8List?> _captureQrWidget() async {
    final screenshotController = ScreenshotController();
    
    try {
      return await screenshotController.captureFromWidget(
        Material(
          child: Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TANDA PENGENAL PENGUNJUNG",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF01579B),
                  ),
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: qrData,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("RFID Tag", rfidTagId),
                      const SizedBox(height: 8),
                      _buildInfoRow("Nama Lengkap", fullName),
                      const SizedBox(height: 8),
                      _buildInfoRow("Kategori", categoryName),
                      const SizedBox(height: 8),
                      _buildInfoRow("Tanggal Registrasi", _formatDate(DateTime.now())),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "HOIP 5.0 - Hospital Operational Intelligence Platform",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "Berlaku selama berkunjung di Rumah Sakit",
                  style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error capture QR: $e");
      return null;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          ":",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _printToThermal() async {
    try {
      final imageBytes = await _captureQrWidget();
      if (imageBytes == null) return;

      final connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        _showError("Bluetooth printer not connected");
        return;
      }

      await PrintBluetoothThermal.writeBytes(imageBytes);
      _showSuccess("Print sent to printer");
    } catch (e) {
      debugPrint("Print error: $e");
      _showError("Failed to print");
    }
  }

  Future<void> _saveAsPdf() async {
    try {
      final imageBytes = await _captureQrWidget();
      if (imageBytes == null) return;

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "TANDA PENGENAL PENGUNJUNG",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Image(pw.MemoryImage(imageBytes), width: 200, height: 200),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [pw.Text("RFID Tag: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(rfidTagId)]),
                        pw.SizedBox(height: 8),
                        pw.Row(children: [pw.Text("Nama Lengkap: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(fullName)]),
                        pw.SizedBox(height: 8),
                        pw.Row(children: [pw.Text("Kategori: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(categoryName)]),
                        pw.SizedBox(height: 8),
                        pw.Row(children: [pw.Text("Tanggal Registrasi: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_formatDate(DateTime.now()))]),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text("HOIP 5.0 - Hospital Operational Intelligence Platform", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  pw.Text("Berlaku selama berkunjung di Rumah Sakit", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "tanda_pengenal_${rfidTagId}_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      
      _showSuccess("PDF saved and ready to share");
    } catch (e) {
      debugPrint("PDF error: $e");
      _showError("Failed to save PDF");
    }
  }

  void _showError(String msg) {
    debugPrint("Error: $msg");
  }

  void _showSuccess(String msg) {
    debugPrint("Success: $msg");
  }

  void _closeDialog(BuildContext context) {
    Navigator.of(context).pop();  // Tutup dialog
    onClose();                    // Panggil callback
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'REGISTRASI BERHASIL',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF01579B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fullName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'RFID: $rfidTagId',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _closeDialog(context),  // ← Perbaiki di sini
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'TUTUP',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveAsPdf();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF siap dicetak / disimpan'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01579B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'PDF CETAK',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}