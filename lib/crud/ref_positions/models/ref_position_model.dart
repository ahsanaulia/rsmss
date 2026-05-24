import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefPositionModel extends Equatable {
  final String? id;
  final String positionName;
  final String? description;

  const RefPositionModel({
    this.id,
    required this.positionName,
    this.description,
  });

  factory RefPositionModel.empty() {
    return const RefPositionModel(
      positionName: '',
    );
  }

  factory RefPositionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefPositionModel.fromJson: $json');

    return RefPositionModel(
      id: json['id'] as String?,
      positionName: json['position_name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'position_name': positionName.trim(),
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }

  RefPositionModel copyWith({
    String? id,
    String? positionName,
    String? description,
  }) {
    return RefPositionModel(
      id: id ?? this.id,
      positionName: positionName ?? this.positionName,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        positionName,
        description,
      ];
}