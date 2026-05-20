// ============================================================
// PAGE: Asset Report Page (ADMIN - WEB)
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan laporan aset dari view v_asset_report
// 2. Filter berdasarkan: Tipe Aset, Kondisi, Status Ketersediaan, Inspeksi Terlewat
// 3. Export ke PDF dan Print
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../providers/asset_report_providers.dart';
import '../models/asset_report_model.dart';

class AssetReportPage extends ConsumerStatefulWidget {
  const AssetReportPage({super.key});

  @override
  ConsumerState<AssetReportPage> createState() => _AssetReportPageState();
}

class _AssetReportPageState extends ConsumerState<AssetReportPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetReportProvider);
    final notifier = ref.read(assetReportProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER
          // ==================================================
          _buildHeader(state, notifier),

          // ==================================================
          // FILTER BAR
          // ==================================================
          _buildFilterBar(state, notifier),

          // ==================================================
          // BODY (List atau Loading/Error/Empty)
          // ==================================================
          Expanded(child: _buildBody(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildHeader(AssetReportState state, AssetReportNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF01579B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Color(0xFF01579B),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Aset',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01579B),
                  ),
                ),
                Text(
                  'Total: ${state.assets.length} aset',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Print & PDF
          if (!state.isLoading && state.assets.isNotEmpty)
            Row(
              children: [
                IconButton(
                  onPressed: () => _printReport(state.assets),
                  icon: const Icon(Icons.print, color: Color(0xFF01579B)),
                  tooltip: 'Print',
                ),
                IconButton(
                  onPressed: () => _saveAsPdf(state.assets),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  tooltip: 'Save as PDF',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AssetReportState state, AssetReportNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Wrap(
  spacing: 12,
  runSpacing: 12,
  alignment: WrapAlignment.start,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    // Filter Tipe Aset
    SizedBox(
      width: 180,
      child: DropdownButtonFormField<String?>(
        value: state.selectedTypeId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Tipe Aset',
          labelStyle: GoogleFonts.poppins(fontSize: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Semua Tipe')),
          ...state.assetTypes.map((type) => DropdownMenuItem(
            value: type['id'].toString(),
            child: Text(
              type['type_name'] ?? '-',
              style: GoogleFonts.poppins(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ],
        onChanged: (value) {
          print('🔴 DROPDOWN TIPE - value: $value');
          notifier.updateTypeFilter(value);
        },
      ),
    ),
    
    // Filter Kondisi Aset
    SizedBox(
      width: 150,
      child: DropdownButtonFormField<String?>(
        value: state.selectedStatusCondition,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Kondisi',
          labelStyle: GoogleFonts.poppins(fontSize: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Semua Kondisi')),
          ...state.statusConditions.map((condition) => DropdownMenuItem(
            value: condition,
            child: Text(
              _getStatusConditionLabel(condition),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          )),
        ],
        onChanged: (value) {
          print('🔴 DROPDOWN KONDISI - value: $value');
          notifier.updateStatusConditionFilter(value);
        },
      ),
    ),
    
    // Filter Status Ketersediaan
Container(
  width: 160,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String?>(
      value: state.selectedAvailabilityStatus,
      isExpanded: true,
      hint: const Text('Semua Status'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Semua Status')),
        ...state.availabilityStatusOptions.map((status) => DropdownMenuItem(
          value: status,
          child: Text(status),
        )),
      ],
      onChanged: (value) {
        print('🔴 DROPDOWN STATUS - value: $value');
        notifier.updateAvailabilityStatusFilter(value);
      },
    ),
  ),
),
    
    // Filter Inspeksi Terlewat
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: state.onlyOverdueInspection,
          onChanged: (value) {
            print('🔴 CHECKBOX INSPEKSI - value: $value');
            notifier.updateOverdueInspectionFilter(value ?? false);
          },
          activeColor: const Color(0xFF01579B),
        ),
        Text(
          'Inspeksi Terlewat',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    ),
    
    // Tombol Reset Filter (SELALU TAMPIL - TIDAK PAKAI if)
    TextButton.icon(
      onPressed: () {
        print('🔴 RESET FILTERS button pressed');
        notifier.resetFilters();
      },
      icon: const Icon(Icons.clear_all, size: 16),
      label: Text(
        'Reset Filter',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
    ),
  ],
),
    );
  }

  bool _isFilterActive(AssetReportState state) {
    return state.selectedTypeId != null ||
        state.selectedStatusCondition != null ||
        state.selectedAvailabilityStatus != null ||
        state.onlyOverdueInspection;
  }

  Widget _buildBody(AssetReportState state, AssetReportNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF01579B)),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: GoogleFonts.poppins(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.loadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01579B),
              ),
              child: Text('Coba Lagi', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    if (state.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data aset',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.loadReport,
      color: const Color(0xFF01579B),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: _buildDataTable(state.assets),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<AssetReport> assets) {
    return DataTable(
      columnSpacing: 12,
      horizontalMargin: 16,
      headingRowColor: WidgetStateProperty.resolveWith(
        (states) => const Color(0xFF01579B).withValues(alpha: 0.1),
      ),
      headingTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: const Color(0xFF01579B),
      ),
      dataTextStyle: GoogleFonts.poppins(fontSize: 11),
      columns: const [
        DataColumn(label: Text('No')),
        DataColumn(label: Text('Tipe Aset')),
        DataColumn(label: Text('Kode Asset')),
        DataColumn(label: Text('Nama Asset')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Pemakai')),
        DataColumn(label: Text('Kondisi')),
        DataColumn(label: Text('Kontaminasi')),
        DataColumn(label: Text('Bahaya')),
        DataColumn(label: Text('Lokasi')),
        DataColumn(label: Text('Terakhir Inspeksi')),
        DataColumn(label: Text('Inspeksi Oleh')),
        DataColumn(label: Text('Hasil')),
        DataColumn(label: Text('Inspeksi Berikutnya')),
        DataColumn(label: Text('Status Inspeksi')),
        DataColumn(label: Text('Perawatan')),
        DataColumn(label: Text('Aktif')),
        DataColumn(label: Text('Terdaftar')),
        DataColumn(label: Text('Tanggal Daftar')),
      ],
      rows: assets.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final asset = entry.value;
        return DataRow(
          cells: [
            DataCell(Text('$index')),
            DataCell(Text(asset.typeName ?? '-')),
            DataCell(Text(asset.rfidTagId)),
            DataCell(Text(asset.assetName)),
            DataCell(_buildStatusChip(asset.availabilityStatus)),
            DataCell(Text(asset.currentUserName ?? '-')),
            DataCell(_buildConditionChip(asset.statusCondition)),
            DataCell(Text('${asset.levelContaminated}')),
            DataCell(Text(asset.isDangerousLabel)),
            DataCell(Text(asset.lastRoomName ?? '-')),
            DataCell(Text(asset.formattedLastInspectionAt)),
            DataCell(Text(asset.lastInspectorName ?? '-')),
            DataCell(Text(asset.lastInspectionResult ?? '-')),
            DataCell(Text(asset.formattedNextInspectionAt)),
            DataCell(_buildInspectionStatusChip(asset.inspectionStatus)),
            DataCell(Text(asset.maintenancePattern ?? '-')),
            DataCell(Text(asset.isActiveLabel)),
            DataCell(Text(asset.registeredByName ?? '-')),
            DataCell(Text(asset.formattedRegisteredAt)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Tersedia':
        color = Colors.green;
        break;
      case 'Digunakan':
        color = Colors.blue;
        break;
      case 'Rusak':
        color = Colors.red;
        break;
      case 'Perawatan':
        color = Colors.orange;
        break;
      case 'Tidak Aktif':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    Color color;
    switch (condition.toLowerCase()) {
      case 'good':
        color = Colors.green;
        break;
      case 'fair':
        color = Colors.orange;
        break;
      case 'damage':
        color = Colors.deepOrange;
        break;
      case 'critical':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInspectionStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Terlewat':
        color = Colors.red;
        break;
      case 'Sesuai Jadwal':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusConditionLabel(String condition) {
    switch (condition.toLowerCase()) {
      case 'good':
        return 'Baik';
      case 'fair':
        return 'Cukup';
      case 'damage':
        return 'Rusak';
      case 'critical':
        return 'Kritis';
      default:
        return condition;
    }
  }

  // ==========================================================
  // PRINT & PDF
  // ==========================================================

  Future<void> _printReport(List<AssetReport> assets) async {
    final pdf = await _generatePdf(assets);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Aset.pdf',
    );
  }

  Future<void> _saveAsPdf(List<AssetReport> assets) async {
    final pdf = await _generatePdf(assets);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'Laporan_Aset_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
    );
  }

  Future<pw.Document> _generatePdf(List<AssetReport> assets) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN ASET',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Dicetak: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),
                ],
              ),
            ),
            // Tabel dengan header manual
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header Row (manual, tanpa headerRow parameter)
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _pdfCell('No', isHeader: true),
                    _pdfCell('Tipe Aset', isHeader: true),
                    _pdfCell('Kode Asset', isHeader: true),
                    _pdfCell('Nama Asset', isHeader: true),
                    _pdfCell('Status', isHeader: true),
                    _pdfCell('Pemakai', isHeader: true),
                    _pdfCell('Kondisi', isHeader: true),
                    _pdfCell('Kontaminasi', isHeader: true),
                    _pdfCell('Lokasi', isHeader: true),
                    _pdfCell('Terakhir Inspeksi', isHeader: true),
                    _pdfCell('Hasil', isHeader: true),
                    _pdfCell('Status Inspeksi', isHeader: true),
                  ],
                ),
                // Data Rows
                ...assets.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final asset = entry.value;
                  return pw.TableRow(
                    children: [
                      _pdfCell('$index'),
                      _pdfCell(asset.typeName ?? '-'),
                      _pdfCell(asset.rfidTagId),
                      _pdfCell(asset.assetName),
                      _pdfCell(asset.availabilityStatus),
                      _pdfCell(asset.currentUserName ?? '-'),
                      _pdfCell(_getStatusConditionLabel(asset.statusCondition)),
                      _pdfCell('${asset.levelContaminated}'),
                      _pdfCell(asset.lastRoomName ?? '-'),
                      _pdfCell(asset.formattedLastInspectionAt),
                      _pdfCell(asset.lastInspectionResult ?? '-'),
                      _pdfCell(asset.inspectionStatus),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
