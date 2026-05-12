import 'entity_all_model.dart';

class EntityPeopleModel extends EntityAllModel {
  EntityPeopleModel({
    required super.entityId,
    required super.entityType,
    required super.name,
    super.rfidTagId,
    super.fotoUrl,
    super.categoryName,
    required super.levelContaminated,
    super.lastDetectedAt,
    super.lastMovementStatus,
    super.trackingStatus,
    super.detectorCode,
    super.roomId,
    super.roomName,
    super.xPos,
    super.yPos,

    // 🔥 NEW
    super.roomXMin,
    super.roomYMin,
    super.roomXMax,
    super.roomYMax,

    super.floorId,
    super.floorNumber,
    super.floorAlias,
    super.mapImageUrl,
    super.buildingId,
    super.markerColor,
  }) : super(
          typeName: null,
          isDangerous: null,
        );

  factory EntityPeopleModel.fromJson(Map<String, dynamic> json) {
    // ======================
    // SAFE PARSER
    // ======================
    String? asString(dynamic val) {
      if (val == null) return null;
      final s = val.toString().trim();
      return s.isEmpty ? null : s;
    }

    double? asDouble(dynamic val) {
      if (val == null) return null;
      return double.tryParse(val.toString());
    }

    int asInt(dynamic val, {int defaultValue = 0}) {
      if (val == null) return defaultValue;
      return int.tryParse(val.toString()) ?? defaultValue;
    }

    DateTime? asDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    // ======================
    // MAPPING
    // ======================
    return EntityPeopleModel(
      entityId: asString(json['entity_id']) ?? '',
      entityType: asString(json['entity_type']) ?? 'person',

      name: asString(json['full_name'] ?? json['name']) ?? 'UNKNOWN',

      rfidTagId: asString(json['rfid_tag_id']),
      fotoUrl: json['foto_url'],
      categoryName: asString(json['category_name']),

      levelContaminated: asInt(json['level_contaminated']),

      lastDetectedAt: asDate(json['last_detected_at']),
      lastMovementStatus: asString(json['last_movement_status']),
      trackingStatus: asString(json['tracking_status']),

      detectorCode: asString(json['detector_code']),
      roomId: asString(json['room_id']),
      roomName: asString(json['room_name']),

      xPos: asDouble(json['x_pos']),
      yPos: asDouble(json['y_pos']),

      // 🔥 NEW (ROOM AREA)
      roomXMin: asDouble(json['room_x_min']),
      roomYMin: asDouble(json['room_y_min']),
      roomXMax: asDouble(json['room_x_max']),
      roomYMax: asDouble(json['room_y_max']),

      floorId: asString(json['floor_id']),
      floorNumber: asInt(json['floor_number']),
      floorAlias: asString(json['floor_alias']),

      mapImageUrl: json['map_image_url'],
      buildingId: asString(json['building_id']),
      markerColor: asString(json['marker_color']),
    );
  }
}