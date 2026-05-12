import 'package:intl/intl.dart';

class WatchListPeopleModel {
  // 1. Data Utama (people_movements)
  final String id;
  final String rfidTagId;
  final String detectorId;
  final int levelContaminated;
  final String movementStatus;
  final DateTime detectedAt;

  // 2. Data Personil (people)
  final String? fullName;
  final String? fotoUrl;
  final bool? isMale;
  final bool? isChild;

  // 3. Data Kategori (ref_people_categories)
  final String? categoryName;
  final String? markerColor;
  final bool? isInsider;

  // 4. Data Lokasi Berjenjang (detectors -> rooms -> floors -> buildings)
  final String? detectorCode;
  final String? roomName;
  final String? floorAlias;
  final String? buildingName;
  
  // --- TAMBAHAN PENTING ---
  final String? floorMapUrl; // map_image_url dari tabel floors

  // 5. Data Koordinat (DARI TABEL ROOMS)
  final double xPos;
  final double yPos;

  WatchListPeopleModel({
    required this.id,
    required this.rfidTagId,
    required this.detectorId,
    required this.levelContaminated,
    required this.movementStatus,
    required this.detectedAt,
    this.fullName,
    this.fotoUrl,
    this.isMale,
    this.isChild,
    this.categoryName,
    this.markerColor,
    this.isInsider,
    this.detectorCode,
    this.roomName,
    this.floorAlias,
    this.buildingName,
    this.floorMapUrl, // Inisialisasi
    required this.xPos,
    required this.yPos,
  });

  // --- LOGIC LAYER DALAM MODEL ---
  String get locationFullPath => "$buildingName > $floorAlias > $roomName";
  String get floorGroupKey => "$buildingName | $floorAlias";
  String get formattedTime => DateFormat('HH:mm:ss').format(detectedAt.toLocal());
  String get coordinateLabel => "X: ${xPos.toStringAsFixed(2)}, Y: ${yPos.toStringAsFixed(2)}";

  factory WatchListPeopleModel.fromManualJoin({
    required Map<String, dynamic> movement,
    required Map<String, dynamic> people,
    required Map<String, dynamic>? category,
    required Map<String, dynamic>? detector,
    required Map<String, dynamic>? room,
    required Map<String, dynamic>? floor,
    required Map<String, dynamic>? building,
  }) {
    return WatchListPeopleModel(
      id: movement['id']?.toString() ?? '',
      rfidTagId: movement['rfid_tag_id']?.toString() ?? '',
      detectorId: movement['detector_id']?.toString() ?? '',
      levelContaminated: movement['level_contaminated'] ?? 0,
      movementStatus: movement['movement_status'] ?? '-',
      detectedAt: DateTime.parse(movement['detected_at'] ?? DateTime.now().toIso8601String()),
      fullName: people['full_name'],
      fotoUrl: people['foto_url'],
      isMale: people['is_male'],
      isChild: people['is_child'],
      categoryName: category?['category_name'],
      markerColor: category?['marker_color'],
      isInsider: category?['is_insider'],
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