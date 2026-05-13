import 'dart:io';

class AssetInputModel {
  final String assetName;
  final String? description;
  final String? handlingInstruction;
  final String? maintenancePattern;
  final int? inspectionDayOfMonth;
  final bool isDangerous;
  final File? photo;
  final String condition;
  final int contaminationLevel;
  final String typeId;
  final String typeName;
  final String roomId;
  final String roomName;
  final String rfidTag;

  AssetInputModel({
    required this.assetName,
    this.description,
    this.handlingInstruction,
    this.maintenancePattern,
    this.inspectionDayOfMonth,
    required this.isDangerous,
    this.photo,
    required this.condition,
    required this.contaminationLevel,
    required this.typeId,
    required this.typeName,
    required this.roomId,
    required this.roomName,
    required this.rfidTag,
  });

  Map<String, dynamic> toJson() => {
    'asset_name': assetName,
    'description': description,
    'handling_instruction': handlingInstruction,
    'maintenance_pattern': maintenancePattern,
    'inspection_day_of_month': inspectionDayOfMonth,
    'is_dangerous': isDangerous,
    'status_condition': condition,
    'level_contaminated': contaminationLevel,
    'type_id': typeId,
    'type_name': typeName,
    'room_id': roomId,
    'room_name': roomName,
    'rfid_tag': rfidTag,
  };
}