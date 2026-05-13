import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/asset_initial_provider.dart';
import '../providers/asset_initial_state.dart';

class OpInitialAsset extends ConsumerStatefulWidget {
  const OpInitialAsset({super.key});

  @override
  ConsumerState<OpInitialAsset> createState() => _OpInitialAssetState();
}

class _OpInitialAssetState extends ConsumerState<OpInitialAsset> {
  final ImagePicker _picker = ImagePicker();
  final ScreenshotController _qrScreenshotController = ScreenshotController();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null) {
        ref.read(assetInitialStateProvider.notifier).updatePhoto(File(picked.path));
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  Future<Uint8List?> _captureQrWidget(String qrData, String rfidTag, String assetName, String typeName, DateTime date) async {
    try {
      return await _qrScreenshotController.captureFromWidget(
        Material(
          child: Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "QR CODE ASSET",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF01579B),
                  ),
                ),
                const SizedBox(height: 20),
                QrImageView(data: qrData, size: 200, backgroundColor: Colors.white),
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
                      _buildInfoRow("Kode Asset", rfidTag),
                      const SizedBox(height: 8),
                      _buildInfoRow("Nama Asset", assetName),
                      const SizedBox(height: 8),
                      _buildInfoRow("Tipe Asset", typeName),
                      const SizedBox(height: 8),
                      _buildInfoRow("Tanggal Awal", "${date.day}/${date.month}/${date.year}"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "RSMSS IoT - Asset Management System",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
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

  Future<void> _printToThermal(String qrData, String rfidTag, String assetName, String typeName, DateTime date) async {
    try {
      final imageBytes = await _captureQrWidget(qrData, rfidTag, assetName, typeName, date);
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

  Future<void> _saveAsPdf(String qrData, String rfidTag, String assetName, String typeName, DateTime date) async {
  try {
    final imageBytes = await _captureQrWidget(qrData, rfidTag, assetName, typeName, date);
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
                  "ASSET QR CODE",
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
                      pw.Row(children: [pw.Text("Kode Asset: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(rfidTag)]),
                      pw.SizedBox(height: 8),
                      pw.Row(children: [pw.Text("Nama Asset: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(assetName)]),
                      pw.SizedBox(height: 8),
                      pw.Row(children: [pw.Text("Tipe Asset: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(typeName)]),
                      pw.SizedBox(height: 8),
                      pw.Row(children: [pw.Text("Tanggal Awal: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text("${date.day}/${date.month}/${date.year}")]),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text("RSMSS IoT - Asset Management System", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/asset_qr_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "asset_qr_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    
    _showSuccess("PDF saved and ready to share");
  } catch (e) {
    debugPrint("PDF error: $e");
    _showError("Failed to save PDF");
  }
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetInitialStateProvider);
    final notifier = ref.read(assetInitialStateProvider.notifier);
    final isSmall = MediaQuery.of(context).size.width < 380;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(state.errorMessage!);
        notifier.clearError();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          state.isSaved ? "Asset Successfully Saved" : "Asset Initial",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        actions: [
          if (state.isSaved)
            IconButton(
              onPressed: notifier.resetToForm,
              icon: const Icon(Icons.add_box_rounded),
              tooltip: "Register New Asset",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF01579B)))
              : state.isSaved
                  ? _buildResultScreen(state, notifier)
                  : _buildFormScreen(state, notifier, isSmall),
        ),
      ),
    );
  }

  Widget _buildFormScreen(AssetInitialState state, AssetInitialNotifier notifier, bool isSmall) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        _buildGlassCard(
          child: Column(
            children: [
              _buildPhotoSection(notifier, state),
              const SizedBox(height: 22),
              _buildTextField(
                label: "Asset Name",
                icon: Icons.inventory_2_outlined,
                value: state.assetName,
                onChanged: notifier.updateAssetName,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Asset name required" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "RFID Tag (Kode Asset)",
                icon: Icons.qr_code_scanner,
                value: state.rfidTag,
                onChanged: notifier.updateRfidTag,
                validator: (v) => (v == null || v.trim().isEmpty) ? "RFID Tag required" : null,
              ),
              const SizedBox(height: 16),
              _buildTypeDropdown(notifier, state),
              const SizedBox(height: 16),
              _buildRoomDropdown(notifier, state),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth < 500) {
                    return Column(
                      children: [
                        _buildConditionDropdown(notifier, state),
                        const SizedBox(height: 16),
                        _buildContaminationDropdown(notifier, state),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildConditionDropdown(notifier, state)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContaminationDropdown(notifier, state)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: state.isDangerous,
                activeColor: const Color(0xFF01579B),
                tileColor: Colors.white.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Text("Dangerous Asset", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: isSmall ? 13 : 14)),
                subtitle: Text("Need special handling", style: GoogleFonts.poppins(fontSize: 11)),
                onChanged: notifier.toggleDangerous,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Handling Instruction",
                icon: Icons.health_and_safety_outlined,
                value: state.handlingInstruction ?? '',
                onChanged: notifier.updateHandlingInstruction,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Maintenance Pattern",
                icon: Icons.build_circle_outlined,
                value: state.maintenancePattern ?? '',
                onChanged: notifier.updateMaintenancePattern,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Inspection Day",
                icon: Icons.calendar_month_outlined,
                value: state.inspectionDayOfMonth ?? '',
                onChanged: notifier.updateInspectionDay,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Description",
                icon: Icons.description_outlined,
                value: state.description ?? '',
                onChanged: notifier.updateDescription,
                maxLines: 4,
              ),
              if (state.qrPreviewData != null) ...[
                const SizedBox(height: 24),
                _buildGlassCard(
                  child: Column(
                    children: [
                      Text("QR CODE PREVIEW", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF01579B))),
                      const SizedBox(height: 12),
                      QrImageView(data: state.qrPreviewData!, size: 150, backgroundColor: Colors.white),
                      const SizedBox(height: 8),
                      Text("RFID: ${state.rfidTag}", style: GoogleFonts.poppins(fontSize: 10)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state.isSaving ? null : () async { await notifier.saveAsset(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01579B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: state.isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(state.isSaving ? "Saving..." : "Save Asset", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen(AssetInitialState state, AssetInitialNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildGlassCard(
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text("ASSET SUCCESSFULLY REGISTERED", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF01579B))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: QrImageView(data: state.finalQrData, size: 200, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Kode Asset", state.rfidTag),
                  const SizedBox(height: 12),
                  _buildInfoRow("Nama Asset", state.assetName),
                  const SizedBox(height: 12),
                  _buildInfoRow("Tipe Asset", state.selectedTypeName ?? '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow("Ruangan", state.selectedRoomName ?? '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow("Tanggal Awal", "${state.savedDate?.day}/${state.savedDate?.month}/${state.savedDate?.year}"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printToThermal(state.finalQrData, state.rfidTag, state.assetName, state.selectedTypeName ?? '-', state.savedDate ?? DateTime.now()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.print_rounded, color: Colors.white),
                    label: Text("Print", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveAsPdf(state.finalQrData, state.rfidTag, state.assetName, state.selectedTypeName ?? '-', state.savedDate ?? DateTime.now()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                    label: Text("Save as PDF", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: notifier.resetToForm,
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF01579B), side: const BorderSide(color: Color(0xFF01579B)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_box_rounded),
                label: Text("Register New Asset", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AssetInitialNotifier notifier, AssetInitialState state) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white.withValues(alpha: 0.35)),
        child: state.photo != null
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(state.photo!, fit: BoxFit.cover))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.camera_alt_rounded, size: 50, color: Colors.blueGrey.shade400),
                const SizedBox(height: 10),
                Text("Take Asset Photo", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ]),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildTypeDropdown(AssetInitialNotifier notifier, AssetInitialState state) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: state.selectedTypeId,
      decoration: _inputDecoration("Asset Type", Icons.category_outlined),
      items: state.assetTypes.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['type_name'] ?? '-', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
      onChanged: (v) {
        if (v == null) return;
        final selected = state.assetTypes.firstWhere((e) => e['id'].toString() == v);
        notifier.selectAssetType(v, selected['type_name'] ?? '');
      },
      validator: (v) => v == null ? "Select asset type" : null,
    );
  }

  Widget _buildRoomDropdown(AssetInitialNotifier notifier, AssetInitialState state) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: state.selectedRoomId,
      decoration: _inputDecoration("Room", Icons.room_outlined),
      items: state.rooms.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['room_name'] ?? '-', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
      onChanged: (v) {
        if (v == null) return;
        final selected = state.rooms.firstWhere((e) => e['id'].toString() == v);
        notifier.selectRoom(v, selected['room_name'] ?? '');
      },
      validator: (v) => v == null ? "Select room" : null,
    );
  }

  Widget _buildConditionDropdown(AssetInitialNotifier notifier, AssetInitialState state) {
    return DropdownButtonFormField<String>(
      value: state.condition,
      decoration: _inputDecoration("Condition", Icons.verified_outlined),
      items: ["Good", "Fair", "Broken", "Maintenance"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
      onChanged: (v) => v != null ? notifier.updateCondition(v) : null,
    );
  }

  Widget _buildContaminationDropdown(AssetInitialNotifier notifier, AssetInitialState state) {
    return DropdownButtonFormField<int>(
      value: state.contaminationLevel,
      decoration: _inputDecoration("Contamination", Icons.coronavirus_outlined),
      items: List.generate(6, (i) => i).map((e) => DropdownMenuItem(value: e, child: Text("Level $e", style: GoogleFonts.poppins(fontSize: 13)))).toList(),
      onChanged: (v) => v != null ? notifier.updateContaminationLevel(v) : null,
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF01579B)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF01579B), width: 1.4)),
    );
  }
}