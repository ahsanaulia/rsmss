class FloorModel {
  final String id;
  final int floorNumber;
  final String floorAlias;
  final String? mapImageUrl;

  final String? buildingId;
  final String? buildingName;

  const FloorModel({
    required this.id,
    required this.floorNumber,
    required this.floorAlias,
    this.mapImageUrl,
    this.buildingId,
    this.buildingName,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    final buildingRaw = json['buildings'];

    return FloorModel(
      id: json['id']?.toString() ?? '',

      floorNumber: json['floor_number'] is int
          ? json['floor_number']
          : int.tryParse(json['floor_number']?.toString() ?? '') ?? 0,

      floorAlias: json['floor_alias']?.toString() ?? '-',

      mapImageUrl: json['map_image_url']?.toString(),

      buildingId: json['building_id']?.toString(),

      buildingName: buildingRaw is Map
          ? buildingRaw['building_name']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_number': floorNumber,
      'floor_alias': floorAlias,
      'map_image_url': mapImageUrl,
      'building_id': buildingId,
      'building_name': buildingName,
    };
  }

  /// 🔥 untuk UI dropdown (reusable, tanpa logic berat)
  String get label {
    final b = buildingName ?? 'Gedung';
    return '$b - $floorAlias';
  }
}