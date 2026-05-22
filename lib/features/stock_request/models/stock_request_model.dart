// lib/features/stock_request/models/stock_request_model.dart
import 'package:equatable/equatable.dart';

class StockRequestModel extends Equatable {
  final String? id;
  final String requestNumber;
  final String requesterId;
  final String requesterName;
  final String? roomId;
  final String? roomName;
  final String? purpose;
  final DateTime requestDate;
  final String? notes;
  
  // Detail permintaan
  final String requestedStockId;
  final String requestedStockName;
  final double requestedQuantity;
  final String requestedUnit;
  final String? requestedBatch;
  
  // Approval
  final String? approvedBy;
  final DateTime? approvedDate;
  final double? approvedQuantity;
  final String? approvedStockId;
  final String? approvedStockName;
  final String? approvalNotes;
  
  // Status
  final String status;
  
  // Fulfillment
  final double fulfilledQuantity;
  
  // Rejection
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? rejectionType;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockRequestModel({
    this.id,
    required this.requestNumber,
    required this.requesterId,
    required this.requesterName,
    this.roomId,
    this.roomName,
    this.purpose,
    required this.requestDate,
    this.notes,
    required this.requestedStockId,
    required this.requestedStockName,
    required this.requestedQuantity,
    required this.requestedUnit,
    this.requestedBatch,
    this.approvedBy,
    this.approvedDate,
    this.approvedQuantity,
    this.approvedStockId,
    this.approvedStockName,
    this.approvalNotes,
    required this.status,
    required this.fulfilledQuantity,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.rejectionType,
    this.createdAt,
    this.updatedAt,
  });

  factory StockRequestModel.fromJson(Map<String, dynamic> json) {
    return StockRequestModel(
      id: json['id'] as String?,
      requestNumber: json['request_number'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      requesterName: json['requester_name'] as String? ?? '',
      roomId: json['room_id'] as String?,
      roomName: json['rooms'] != null 
          ? (json['rooms'] as Map)['room_name'] as String?
          : null,
      purpose: json['purpose'] as String?,
      requestDate: json['request_date'] != null
          ? DateTime.parse(json['request_date'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      requestedStockId: json['requested_stock_id'] as String? ?? '',
      requestedStockName: json['requested_stock_name'] as String? ?? '',
      requestedQuantity: (json['requested_quantity'] as num?)?.toDouble() ?? 0,
      requestedUnit: json['requested_unit'] as String? ?? '',
      requestedBatch: json['requested_batch'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'] as String)
          : null,
      approvedQuantity: (json['approved_quantity'] as num?)?.toDouble(),
      approvedStockId: json['approved_stock_id'] as String?,
      approvedStockName: json['approved_stock_name'] as String?,
      approvalNotes: json['approval_notes'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      fulfilledQuantity: (json['fulfilled_quantity'] as num?)?.toDouble() ?? 0,
      rejectedBy: json['rejected_by'] as String?,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      rejectionType: json['rejection_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'request_number': requestNumber,
      'requester_id': requesterId,
      'requester_name': requesterName,
      if (roomId != null) 'room_id': roomId,
      if (purpose != null) 'purpose': purpose,
      'request_date': requestDate.toIso8601String(),
      if (notes != null) 'notes': notes,
      'requested_stock_id': requestedStockId,
      'requested_stock_name': requestedStockName,
      'requested_quantity': requestedQuantity,
      'requested_unit': requestedUnit,
      if (requestedBatch != null) 'requested_batch': requestedBatch,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedDate != null) 'approved_date': approvedDate?.toIso8601String(),
      if (approvedQuantity != null) 'approved_quantity': approvedQuantity,
      if (approvedStockId != null) 'approved_stock_id': approvedStockId,
      if (approvedStockName != null) 'approved_stock_name': approvedStockName,
      if (approvalNotes != null) 'approval_notes': approvalNotes,
      'status': status,
      'fulfilled_quantity': fulfilledQuantity,
      if (rejectedBy != null) 'rejected_by': rejectedBy,
      if (rejectedAt != null) 'rejected_at': rejectedAt?.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (rejectionType != null) 'rejection_type': rejectionType,
    };
  }

  StockRequestModel copyWith({
    String? id,
    String? requestNumber,
    String? requesterId,
    String? requesterName,
    String? roomId,
    String? roomName,
    String? purpose,
    DateTime? requestDate,
    String? notes,
    String? requestedStockId,
    String? requestedStockName,
    double? requestedQuantity,
    String? requestedUnit,
    String? requestedBatch,
    String? approvedBy,
    DateTime? approvedDate,
    double? approvedQuantity,
    String? approvedStockId,
    String? approvedStockName,
    String? approvalNotes,
    String? status,
    double? fulfilledQuantity,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? rejectionType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockRequestModel(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      purpose: purpose ?? this.purpose,
      requestDate: requestDate ?? this.requestDate,
      notes: notes ?? this.notes,
      requestedStockId: requestedStockId ?? this.requestedStockId,
      requestedStockName: requestedStockName ?? this.requestedStockName,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      requestedUnit: requestedUnit ?? this.requestedUnit,
      requestedBatch: requestedBatch ?? this.requestedBatch,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      approvedQuantity: approvedQuantity ?? this.approvedQuantity,
      approvedStockId: approvedStockId ?? this.approvedStockId,
      approvedStockName: approvedStockName ?? this.approvedStockName,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      status: status ?? this.status,
      fulfilledQuantity: fulfilledQuantity ?? this.fulfilledQuantity,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionType: rejectionType ?? this.rejectionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestNumber,
        requesterId,
        requesterName,
        roomId,
        roomName,
        purpose,
        requestDate,
        notes,
        requestedStockId,
        requestedStockName,
        requestedQuantity,
        requestedUnit,
        requestedBatch,
        status,
        fulfilledQuantity,
      ];
}

// lib/features/stock_request/models/stock_request_fulfillment_model.dart
class StockRequestFulfillmentModel {
  final String? id;
  final String stockRequestId;
  final String stockInBinsId;
  final String binId;
  final String stockId;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final String? takenBy;
  final DateTime? takenAt;
  final String? notes;

  StockRequestFulfillmentModel({
    this.id,
    required this.stockRequestId,
    required this.stockInBinsId,
    required this.binId,
    required this.stockId,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    this.takenBy,
    this.takenAt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'stock_request_id': stockRequestId,
      'stock_in_bins_id': stockInBinsId,
      'bin_id': binId,
      'stock_id': stockId,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'quantity': quantity,
      if (takenBy != null) 'taken_by': takenBy,
      if (notes != null) 'notes': notes,
    };
  }
}