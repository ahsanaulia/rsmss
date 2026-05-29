// File: lib/insights/stocks/models/stock_request_model.dart

import 'package:flutter/material.dart';

class StockRequestModel {
  final String id;
  final String requestNumber;
  final String requesterId;
  final String requesterName;
  final String? requesterPosition;
  final String? unitName;
  final String? roomName;
  final String requestedStockName;
  final double requestedQuantity;
  final String unit;
  final String status;
  final DateTime requestDate;
  final DateTime? approvedDate;
  final String? approvedBy;
  final String? rejectionReason;
  final double? approvedQuantity;
  final double? fulfilledQuantity;
  final String? notes;
  

  StockRequestModel({
    required this.id,
    required this.requestNumber,
    required this.requesterId,
    required this.requesterName,
    this.requesterPosition,
    this.unitName,
    this.roomName,
    required this.requestedStockName,
    required this.requestedQuantity,
    required this.unit,
    required this.status,
    required this.requestDate,
    this.approvedDate,
    this.approvedBy,
    this.rejectionReason,
    this.approvedQuantity,
    this.fulfilledQuantity,
    this.notes,
  });

  factory StockRequestModel.fromJson(Map<String, dynamic> json) {
    return StockRequestModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number'] ?? '',
      requesterId: json['requester_id']?.toString() ?? '',
      requesterName: json['requester_name'] ?? '',
      requesterPosition: json['requester_position']?.toString(),
      unitName: json['unit_name']?.toString(),
      roomName: json['room_name']?.toString(),
      requestedStockName: json['requested_stock_name'] ?? '',
      requestedQuantity: (json['requested_quantity'] ?? 0).toDouble(),
      unit: json['requested_unit'] ?? json['unit'] ?? '',
      status: json['status'] ?? 'PENDING',
      requestDate: json['request_date'] != null
          ? DateTime.parse(json['request_date'].toString())
          : DateTime.now(),
      approvedDate: json['approved_date'] != null
          ? DateTime.tryParse(json['approved_date'].toString())
          : null,
      approvedBy: json['approved_by']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      approvedQuantity: (json['approved_quantity'] as num?)?.toDouble(),
      fulfilledQuantity: (json['fulfilled_quantity'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isFulfilled => status == 'FULFILLED';

  Color get statusColor {
    if (isPending) return const Color(0xFFF59E0B);
    if (isApproved) return const Color(0xFF10B981);
    if (isRejected) return const Color(0xFFEF4444);
    if (isFulfilled) return const Color(0xFF3B82F6);
    return Colors.white70;
  }

  String get statusText {
    if (isPending) return 'PENDING';
    if (isApproved) return 'APPROVED';
    if (isRejected) return 'REJECTED';
    if (isFulfilled) return 'FULFILLED';
    return status;
  }
}