class AssetReportRowModel {
  final int no;

  /// NOMENKLATUR / GOLONGAN
  final String rfidTagId;

  /// CATEGORY = GOLONGAN
  final String? categoryName;

  /// SUB CATEGORY = KELOMPOK
  final String? subCategoryName;

  /// TYPE = SUB KELOMPOK
  final String? typeName;

  /// NAMA BARANG
  final String assetName;

  /// USER / PENANGGUNG JAWAB
  final String? assignmentName;

  /// KONDISI
  final String? condition;

  /// KONTAMINASI
  final int? contaminationLevel;

  /// BERBAHAYA
  final bool isDangerous;

  /// JUMLAH
  final int total;

  const AssetReportRowModel({
    required this.no,
    required this.rfidTagId,
    required this.assetName,
    required this.total,

    this.categoryName,
    this.subCategoryName,
    this.typeName,
    this.assignmentName,
    this.condition,
    this.contaminationLevel,
    this.isDangerous = false,
  });
}