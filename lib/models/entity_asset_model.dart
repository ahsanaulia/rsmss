class AssetEntityModel {
  final String entityId;
  final String assetId;
  final String entityType;

  final String? rfidTagId;
  final String name;
  final String? fotoUrl;

  final String? categoryName;
  final String? markerColor;

  final String? statusCondition;
  final int levelContaminated;
  final bool isDangerous;
  final String? handlingInstruction;

  final DateTime? lastDetectedAt;
  final String? lastMovementStatus;
  final DateTime? updatedAt;
  final String trackingStatus;

  final String? detectorCode;

  final String? roomId;
  final String roomName;

  final double? xPos;
  final double? yPos;

  final String? floorId;
  final String? floorAlias;
  final String? mapImageUrl;

  final String? buildingId;

  final double? roomXMin;
  final double? roomYMin;
  final double? roomXMax;
  final double? roomYMax;

  AssetEntityModel({
    required this.entityId,
    required this.assetId,
    required this.entityType,
    required this.name,
    required this.trackingStatus,
    this.rfidTagId,
    this.fotoUrl,
    this.categoryName,
    this.markerColor,
    this.statusCondition,
    required this.levelContaminated,
    required this.isDangerous,
    this.handlingInstruction,
    this.lastDetectedAt,
    this.lastMovementStatus,
    this.updatedAt,
    this.detectorCode,
    this.roomId,
    required this.roomName,
    this.xPos,
    this.yPos,
    this.floorId,
    this.floorAlias,
    this.mapImageUrl,
    this.buildingId,
    this.roomXMin,
    this.roomYMin,
    this.roomXMax,
    this.roomYMax,
  });

  factory AssetEntityModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) =>
        v == null ? null : (v as num).toDouble();

    return AssetEntityModel(
      entityId: json['entity_id']?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? '',
      entityType: json['entity_type'] ?? 'asset',

      name: json['asset_name'] ?? '-',

      rfidTagId: json['rfid_tag_id'],
      fotoUrl: json['foto_url'],

      categoryName: json['category_name'],
      markerColor: json['marker_color'],

      statusCondition: json['status_condition'],
      levelContaminated: json['level_contaminated'] ?? 0,
      isDangerous: json['is_dangerous'] ?? false,
      handlingInstruction: json['handling_instruction'],

      lastDetectedAt: json['last_detected_at'] != null
          ? DateTime.tryParse(json['last_detected_at'])
          : null,

      lastMovementStatus: json['last_movement_status'],

      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,

      trackingStatus: json['tracking_status'] ?? 'UNKNOWN',

      detectorCode: json['detector_code'],

      roomId: json['room_id'],
      roomName: json['room_name'] ?? 'UNKNOWN',

      xPos: _toDouble(json['x_pos']),
      yPos: _toDouble(json['y_pos']),

      floorId: json['floor_id'],
      floorAlias: json['floor_alias'],
      mapImageUrl: json['map_image_url'],

      buildingId: json['building_id'],

      roomXMin: _toDouble(json['room_x_min']),
      roomYMin: _toDouble(json['room_y_min']),
      roomXMax: _toDouble(json['room_x_max']),
      roomYMax: _toDouble(json['room_y_max']),
    );
  }
}