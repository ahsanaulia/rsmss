// File:
// lib/services/asset_excel_export_service.dart

import 'package:excel/excel.dart';

import '../models/asset_report_mode.dart';
import '../models/asset_report_row_model.dart';

class AssetExcelExportService {
  Excel generate({
    required List<AssetReportRowModel> rows,
    required AssetReportMode mode,
  }) {
    final excel = Excel.createExcel();

    final sheet =
        excel['ASSET_REPORT'];

    sheet.appendRow(
      _headers(mode)
          .map(
            (e) => TextCellValue(e),
          )
          .toList(),
    );

    for (final row in rows) {
      sheet.appendRow(
        _cells(row, mode)
            .map(
              (e) => TextCellValue(e),
            )
            .toList(),
      );
    }

    return excel;
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
}