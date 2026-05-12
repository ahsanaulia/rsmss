// File:
// lib/services/asset_pdf_export_service.dart

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/asset_report_mode.dart';
import '../models/asset_report_row_model.dart';

class AssetPdfExportService {
  Future<Uint8List> generate({
    required List<AssetReportRowModel> rows,
    required AssetReportMode mode,
    String hospitalName = 'RS MODERN DIGITAL',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            _buildHeader(
              hospitalName: hospitalName,
              mode: mode,
              total: rows.length,
            ),

            pw.SizedBox(height: 20),

            _buildTable(
              rows: rows,
              mode: mode,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader({
    required String hospitalName,
    required AssetReportMode mode,
    required int total,
  }) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          hospitalName,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          'ASSET REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Text(
          'Mode : ${_modeText(mode)}',
        ),

        pw.Text(
          'Total Data : $total',
        ),

        pw.Text(
          'Generated : ${DateTime.now()}',
        ),
      ],
    );
  }

  pw.Widget _buildTable({
    required List<AssetReportRowModel> rows,
    required AssetReportMode mode,
  }) {
    final headers = _headers(mode);

    final data = rows.map((e) {
      return _cells(e, mode);
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(
        fontSize: 8,
      ),
      cellAlignment:
          pw.Alignment.centerLeft,
      headerDecoration:
          const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
    );
  }

  List<String> _headers(
    AssetReportMode mode,
  ) {
    switch (mode) {
      case AssetReportMode.asset:
        return [
          'No',
          'Golongan',
          'Nama Barang',
          'Penanggung Jawab',
        ];

      case AssetReportMode.category:
        return [
          'No',
          'Golongan',
          'Category',
          'Jumlah',
        ];

      case AssetReportMode.subCategory:
        return [
          'No',
          'Golongan',
          'Category',
          'Sub Category',
          'Jumlah',
        ];

      case AssetReportMode.type:
        return [
          'No',
          'Golongan',
          'Category',
          'Sub Category',
          'Type',
          'Jumlah',
        ];

      case AssetReportMode.condition:
        return [
          'No',
          'Golongan',
          'Condition',
          'Jumlah',
        ];

      case AssetReportMode.contamination:
        return [
          'No',
          'Golongan',
          'Nama Barang',
          'Contamination',
        ];

      case AssetReportMode.dangerous:
        return [
          'No',
          'Golongan',
          'Nama Barang',
          'Dangerous',
        ];

      case AssetReportMode.assignment:
        return [
          'No',
          'Golongan',
          'PIC Asset',
          'Jumlah',
        ];
    }
  }

  List<String> _cells(
    AssetReportRowModel row,
    AssetReportMode mode,
  ) {
    switch (mode) {
      case AssetReportMode.asset:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.assetName,
          row.assignmentName ?? '-',
        ];

      case AssetReportMode.category:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.categoryName ?? '-',
          row.total.toString(),
        ];

      case AssetReportMode.subCategory:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.categoryName ?? '-',
          row.subCategoryName ?? '-',
          row.total.toString(),
        ];

      case AssetReportMode.type:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.categoryName ?? '-',
          row.subCategoryName ?? '-',
          row.typeName ?? '-',
          row.total.toString(),
        ];

      case AssetReportMode.condition:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.condition ?? '-',
          row.total.toString(),
        ];

      case AssetReportMode.contamination:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.assetName,
          row.contaminationLevel
                  ?.toString() ??
              '-',
        ];

      case AssetReportMode.dangerous:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.assetName,
          row.isDangerous
              ? 'YES'
              : 'NO',
        ];

      case AssetReportMode.assignment:
        return [
          row.no.toString(),
          row.rfidTagId,
          row.assignmentName ?? '-',
          row.total.toString(),
        ];
    }
  }

  String _modeText(
    AssetReportMode mode,
  ) {
    return mode.name.toUpperCase();
  }
}