// class EntityAllModel {
//   final String entityId;
//   final String entityType; // 'person' | 'asset'
//   final String? rfidTagId;
//   final String name;
//   final String? fotoUrl;

//   final String? categoryName;
//   final String? typeName;

//   final int? levelContaminated;
//   final bool? isDangerous;

//   final DateTime? lastDetectedAt;
//   final String? lastMovementStatus;
//   final String? trackingStatus;

//   final String? detectorCode;

//   final String? roomId;
//   final String? roomName;

//   final double? xPos;
//   final double? yPos;

//   // 🔥 NEW: ROOM AREA (BOUNDING BOX)
//   final double? roomXMin;
//   final double? roomYMin;
//   final double? roomXMax;
//   final double? roomYMax;

//   final String? floorId;
//   final int? floorNumber;
//   final String? floorAlias;
//   final String? mapImageUrl;

//   final String? buildingId;
//   final String? markerColor;

//   EntityAllModel({
//     required this.entityId,
//     required this.entityType,
//     required this.name,
//     this.rfidTagId,
//     this.fotoUrl,
//     this.categoryName,
//     this.typeName,
//     this.levelContaminated,
//     this.isDangerous,
//     this.lastDetectedAt,
//     this.lastMovementStatus,
//     this.trackingStatus,
//     this.detectorCode,
//     this.roomId,
//     this.roomName,
//     this.xPos,
//     this.yPos,

//     // 🔥 NEW
//     this.roomXMin,
//     this.roomYMin,
//     this.roomXMax,
//     this.roomYMax,

//     this.floorId,
//     this.floorNumber,
//     this.floorAlias,
//     this.mapImageUrl,
//     this.buildingId,
//     this.markerColor,
//   });

//   // ======================
//   // SAFE PARSER
//   // ======================
//   static String? _asString(dynamic val) {
//     if (val == null) return null;
//     final s = val.toString().trim();
//     return s.isEmpty ? null : s;
//   }

//   static double? _asDouble(dynamic val) {
//     if (val == null) return null;
//     return double.tryParse(val.toString());
//   }

//   static int? _asInt(dynamic val) {
//     if (val == null) return null;
//     return int.tryParse(val.toString());
//   }

//   static DateTime? _asDate(dynamic val) {
//     if (val == null) return null;
//     try {
//       return DateTime.parse(val.toString());
//     } catch (_) {
//       return null;
//     }
//   }

//   factory EntityAllModel.fromJson(Map<String, dynamic> json) {
//     return EntityAllModel(
//       entityId: _asString(json['entity_id']) ?? '',
//       entityType: _asString(json['entity_type']) ?? 'unknown',

//       name: _asString(json['full_name'] ?? json['name']) ?? 'UNKNOWN',

//       rfidTagId: _asString(json['rfid_tag_id']),
//       fotoUrl: json['foto_url'],

//       categoryName: _asString(json['category_name']),
//       typeName: _asString(json['type_name']),

//       levelContaminated: _asInt(json['level_contaminated']),
//       isDangerous: json['is_dangerous'],

//       lastDetectedAt: _asDate(json['last_detected_at']),
//       lastMovementStatus: _asString(json['last_movement_status']),
//       trackingStatus: _asString(json['tracking_status']),

//       detectorCode: _asString(json['detector_code']),

//       roomId: _asString(json['room_id']),
//       roomName: _asString(json['room_name']),

//       xPos: _asDouble(json['x_pos']),
//       yPos: _asDouble(json['y_pos']),

//       // 🔥 NEW (BOUNDING BOX)
//       roomXMin: _asDouble(json['room_x_min']),
//       roomYMin: _asDouble(json['room_y_min']),
//       roomXMax: _asDouble(json['room_x_max']),
//       roomYMax: _asDouble(json['room_y_max']),

//       floorId: _asString(json['floor_id']),
//       floorNumber: _asInt(json['floor_number']),
//       floorAlias: _asString(json['floor_alias']),
//       mapImageUrl: json['map_image_url'],

//       buildingId: _asString(json['building_id']),
//       markerColor: _asString(json['marker_color']),
//     );
//   }

//   bool get isPerson => entityType == 'person';
//   bool get isAsset => entityType == 'asset';
// }

class EntityAllModel {
  final String entityId;
  final String entityType; // 'person' | 'asset'
  final String? rfidTagId;
  final String name;
  final String? fotoUrl;

  // ⛔ JANGAN DIHAPUS (dipakai People)
  final String? categoryName;

  // ⛔ Dipakai Asset
  final String? typeName;

  final int? levelContaminated;
  final bool? isDangerous;

  final DateTime? lastDetectedAt;
  final String? lastMovementStatus;
  final String? trackingStatus;

  final String? detectorCode;

  final String? roomId;
  final String? roomName;

  final double? xPos;
  final double? yPos;

  // 🔥 ROOM AREA (BOUNDING BOX)
  final double? roomXMin;
  final double? roomYMin;
  final double? roomXMax;
  final double? roomYMax;

  final String? floorId;
  final int? floorNumber;
  final String? floorAlias;
  final String? mapImageUrl;

  final String? buildingId;
  final String? markerColor;

  EntityAllModel({
    required this.entityId,
    required this.entityType,
    required this.name,
    this.rfidTagId,
    this.fotoUrl,
    this.categoryName,
    this.typeName,
    this.levelContaminated,
    this.isDangerous,
    this.lastDetectedAt,
    this.lastMovementStatus,
    this.trackingStatus,
    this.detectorCode,
    this.roomId,
    this.roomName,
    this.xPos,
    this.yPos,

    // 🔥 NEW (tetap kompatibel)
    this.roomXMin,
    this.roomYMin,
    this.roomXMax,
    this.roomYMax,

    this.floorId,
    this.floorNumber,
    this.floorAlias,
    this.mapImageUrl,
    this.buildingId,
    this.markerColor,
  });

  // ======================
  // SAFE PARSER (TIDAK DIUBAH KONTRAK)
  // ======================

  static String? _asString(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _asDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int? _asInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }

  static DateTime? _asDate(dynamic val) {
    if (val == null) return null;
    try {
      return DateTime.parse(val.toString());
    } catch (_) {
      return null;
    }
  }

  // ======================
  // FACTORY (BACKWARD SAFE)
  // ======================
  factory EntityAllModel.fromJson(Map<String, dynamic> json) {
    final resolvedEntityId =
        _asString(json['entity_id']) ??
        _asString(json['asset_id']) ??
        _asString(json['person_id']) ??
        _asString(json['rfid_tag_id']) ??
        json.hashCode.toString();

    final resolvedName =
        _asString(json['asset_name']) ??
        _asString(json['full_name']) ??
        _asString(json['name']) ??
        'UNKNOWN';

    return EntityAllModel(
      entityId: resolvedEntityId,
      entityType: _asString(json['entity_type']) ?? 'unknown',

      name: resolvedName,

      rfidTagId: _asString(json['rfid_tag_id']),
      fotoUrl: json['foto_url'],

      // ⛔ People tetap pakai ini
      categoryName: _asString(json['category_name']),

      // ⛔ Asset pakai ini
      typeName: _asString(json['type_name']),

      levelContaminated: _asInt(json['level_contaminated']),
      isDangerous: json['is_dangerous'] is bool
          ? json['is_dangerous']
          : null,

      lastDetectedAt: _asDate(json['last_detected_at']),
      lastMovementStatus: _asString(json['last_movement_status']),
      trackingStatus: _asString(json['tracking_status']),

      detectorCode: _asString(json['detector_code']),

      roomId: _asString(json['room_id']),
      roomName: _asString(json['room_name']),

      xPos: _asDouble(json['x_pos']),
      yPos: _asDouble(json['y_pos']),

      roomXMin: _asDouble(json['room_x_min']),
      roomYMin: _asDouble(json['room_y_min']),
      roomXMax: _asDouble(json['room_x_max']),
      roomYMax: _asDouble(json['room_y_max']),

      floorId: _asString(json['floor_id']),
      floorNumber: _asInt(json['floor_number']),
      floorAlias: _asString(json['floor_alias']),
      mapImageUrl: json['map_image_url'],

      buildingId: _asString(json['building_id']),
      markerColor: _asString(json['marker_color']),
    );
  }

  // ======================
  // DOMAIN HELPERS
  // ======================
  bool get isPerson => entityType == 'person';
  bool get isAsset => entityType == 'asset';
}