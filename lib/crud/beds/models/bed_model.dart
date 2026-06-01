// File: lib/crud/beds/models/bed_model.dart


import 'package:flutter/material.dart';

class BedModel {
  final String id;
  final String roomId;
  final String roomName;
  final String bedNumber;
  final String assetId;
  final String assetName;
  final String status;
  final String? patientId;
  final String? patientName;
  final DateTime? admittedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BedModel({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.bedNumber,
    required this.assetId,
    required this.assetName,
    required this.status,
    this.patientId,
    this.patientName,
    this.admittedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BedModel.fromJson(Map<String, dynamic> json) {
  return BedModel(
    id: json['id']?.toString() ?? '',
    roomId: json['room_id']?.toString() ?? '',
    roomName: json['rooms']?['room_name']?.toString() ?? 'Unknown',
    bedNumber: json['bed_number']?.toString() ?? '',
    assetId: json['asset_id']?.toString() ?? '',
    assetName: json['assets']?['asset_name']?.toString() ?? 'Unknown',
    status: json['status']?.toString() ?? 'EMPTY',
    patientId: json['patient_id']?.toString(),
    patientName: null,  // ← SEMENTARA NULL, AMBIL DARI TERPISAH
    admittedAt: json['admitted_at'] != null
        ? DateTime.tryParse(json['admitted_at'].toString())
        : null,
    notes: json['notes']?.toString(),
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'bed_number': bedNumber,
      'asset_id': assetId,
      'status': status,
      'patient_id': patientId,
      'admitted_at': admittedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  BedModel copyWith({
    String? roomId,
    String? bedNumber,
    String? assetId,
    String? status,
    String? patientId,
    DateTime? admittedAt,
    String? notes,
  }) {
    return BedModel(
      id: id,
      roomId: roomId ?? this.roomId,
      roomName: roomName,
      bedNumber: bedNumber ?? this.bedNumber,
      assetId: assetId ?? this.assetId,
      assetName: assetName,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName,
      admittedAt: admittedAt ?? this.admittedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get isOccupied => status == 'OCCUPIED';
  bool get isEmpty => status == 'EMPTY';
  bool get isMaintenance => status == 'MAINTENANCE';

  String get statusLabel {
    switch (status) {
      case 'OCCUPIED': return 'Terisi';
      case 'EMPTY': return 'Kosong';
      case 'MAINTENANCE': return 'Perawatan';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'OCCUPIED': return const Color(0xFFEF4444);
      case 'EMPTY': return const Color(0xFF10B981);
      case 'MAINTENANCE': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }
}