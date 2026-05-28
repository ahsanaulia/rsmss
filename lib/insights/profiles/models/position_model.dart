// lib/insights/profiles/models/position_model.dart
class PositionModel {
  final String id;
  final String positionName;
  final String? description;
  final int level;
  final String? color;
  final String? iconName;

  PositionModel({
    required this.id,
    required this.positionName,
    this.description,
    required this.level,
    this.color,
    this.iconName,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'].toString(),
      positionName: json['position_name'] ?? '',
      description: json['description'],
      level: json['level'] ?? 1,
      color: json['color'],
      iconName: json['icon_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position_name': positionName,
      'description': description,
      'level': level,
      'color': color,
      'icon_name': iconName,
    };
  }
}