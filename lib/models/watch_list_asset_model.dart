import 'package:intl/intl.dart';

class WatchListAssetModel {
  // 1. Data Utama
  final String id;
  final String rfidTagId;
  final String detectorId;
  final int levelContaminated;
  final String movementStatus;
  final DateTime detectedAt;

  // 2. Data Asset
  final String? assetName;
  final String? fotoUrl;
  final String? statusCondition;
  final bool? isDangerous;

  // 3. Data Tipe
  final String? typeName;
  final String? iconName;

  // 4. Data Lokasi Berjenjang
  final String? detectorCode;
  final String? roomName;
  final String? floorAlias;
  final String? buildingName;
  
  // --- TAMBAHAN PENTING ---
  final String? floorMapUrl; // map_image_url dari tabel floors

  // 5. Data Koordinat
  final double xPos;
  final double yPos;

  WatchListAssetModel({
    required this.id,
    required this.rfidTagId,
    required this.detectorId,
    required this.levelContaminated,
    required this.movementStatus,
    required this.detectedAt,
    this.assetName,
    this.fotoUrl,
    this.statusCondition,
    this.isDangerous,
    this.typeName,
    this.iconName,
    this.detectorCode,
    this.roomName,
    this.floorAlias,
    this.buildingName,
    this.floorMapUrl, // Inisialisasi
    required this.xPos,
    required this.yPos,
  });

  String get locationFullPath => "$buildingName > $floorAlias > $roomName";
  String get formattedTime => DateFormat('HH:mm:ss').format(detectedAt.toLocal());
  String get coordinateLabel => "X: ${xPos.toStringAsFixed(2)}, Y: ${yPos.toStringAsFixed(2)}";

  factory WatchListAssetModel.fromManualJoin({
    required Map<String, dynamic> movement,
    required Map<String, dynamic> asset,
    required Map<String, dynamic>? type,
    required Map<String, dynamic>? detector,
    required Map<String, dynamic>? room,
    required Map<String, dynamic>? floor,
    required Map<String, dynamic>? building,
  }) {
    return WatchListAssetModel(
      id: movement['id']?.toString() ?? '',
      rfidTagId: movement['rfid_tag_id']?.toString() ?? '',
      detectorId: movement['detector_id']?.toString() ?? '',
      levelContaminated: movement['level_contaminated'] ?? 0,
      movementStatus: movement['movement_status'] ?? '-',
      detectedAt: DateTime.parse(movement['detected_at'] ?? DateTime.now().toIso8601String()),
      assetName: asset['asset_name'],
      fotoUrl: asset['foto_url'],
      statusCondition: asset['status_condition'],
      isDangerous: asset['is_dangerous'],
      typeName: type?['type_name'],
      iconName: type?['icon_name'],
      detectorCode: detector?['detector_code'],
      roomName: room?['room_name'],
      floorAlias: floor?['floor_alias'],
      buildingName: building?['building_name'],
      floorMapUrl: floor?['map_image_url'], // Ambil dari kolom map_image_url
      xPos: (room?['x_pos'] ?? 0.0).toDouble(),
      yPos: (room?['y_pos'] ?? 0.0).toDouble(),
    );
  }
}