// File: lib/models/stocks_view_model.dart

import 'dart:convert';

class StocksViewModel {
  // =====================================================
  // CORE
  // =====================================================

  final String id;

  final String? stockCode;
  final String stockName;

  final String? stockTypeId;
  final String? stockTypeName;
  final String? stockTypeDescription;

  final String unit;

  final double minimumStock;
  final double currentStock;

  final String stockCondition;

  final String? photoUrl;

  final bool isActive;

  // =====================================================
  // LAST OPNAME
  // =====================================================

  final DateTime? lastOpnameAt;
  final String? lastOpnameBy;
  final String? lastOpnameByName;
  final String? lastOpnameByEmployeeId;

  final String? lastOpnameNote;
  final double? lastOpnameStock;

  // =====================================================
  // LAST PURCHASE
  // =====================================================

  final DateTime? lastPurchaseAt;
  final String? lastPurchaseBy;
  final String? lastPurchaseByName;
  final String? lastPurchaseByEmployeeId;

  final double? lastPurchaseQty;
  final double? lastPurchasePrice;

  // =====================================================
  // LAST USAGE
  // =====================================================

  final DateTime? lastUsageAt;
  final String? lastUsageBy;
  final String? lastUsageByName;
  final String? lastUsageByEmployeeId;

  final double? lastUsageQty;

  // =====================================================
  // META
  // =====================================================

  final DateTime? updatedAt;
  final DateTime? createdAt;

  // =====================================================
  // FLAGS
  // =====================================================

  final bool isEmpty;
  final bool isLowStock;
  final bool isStockSafe;

  // =====================================================
  // SORT
  // =====================================================

  final String? sortTypeName;
  final String? sortStockName;

  const StocksViewModel({
    required this.id,
    required this.stockName,
    required this.unit,
    required this.minimumStock,
    required this.currentStock,
    required this.stockCondition,
    required this.isActive,
    required this.isEmpty,
    required this.isLowStock,
    required this.isStockSafe,

    this.stockCode,

    this.stockTypeId,
    this.stockTypeName,
    this.stockTypeDescription,

    this.photoUrl,

    this.lastOpnameAt,
    this.lastOpnameBy,
    this.lastOpnameByName,
    this.lastOpnameByEmployeeId,
    this.lastOpnameNote,
    this.lastOpnameStock,

    this.lastPurchaseAt,
    this.lastPurchaseBy,
    this.lastPurchaseByName,
    this.lastPurchaseByEmployeeId,
    this.lastPurchaseQty,
    this.lastPurchasePrice,

    this.lastUsageAt,
    this.lastUsageBy,
    this.lastUsageByName,
    this.lastUsageByEmployeeId,
    this.lastUsageQty,

    this.updatedAt,
    this.createdAt,

    this.sortTypeName,
    this.sortStockName,
  });

  // =====================================================
  // FACTORY
  // =====================================================

  factory StocksViewModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return StocksViewModel(
      // =====================================================
      // CORE
      // =====================================================

      id: _asString(map['id']),

      stockCode: _asNullableString(map['stock_code']),
      stockName: _asString(map['stock_name']),

      stockTypeId:
          _asNullableString(map['stock_type_id']),

      stockTypeName:
          _asNullableString(map['stock_type_name']),

      stockTypeDescription:
          _asNullableString(
        map['stock_type_description'],
      ),

      unit: _asString(map['unit']),

      minimumStock:
          _asDouble(map['minimum_stock']),

      currentStock:
          _asDouble(map['current_stock']),

      stockCondition:
          _asString(map['stock_condition']),

      photoUrl:
          _asNullableString(map['photo_url']),

      isActive:
          _asBool(map['is_active']),

      // =====================================================
      // LAST OPNAME
      // =====================================================

      lastOpnameAt:
          _asDateTime(map['last_opname_at']),

      lastOpnameBy:
          _asNullableString(map['last_opname_by']),

      lastOpnameByName:
          _asNullableString(
        map['last_opname_by_name'],
      ),

      lastOpnameByEmployeeId:
          _asNullableString(
        map['last_opname_by_employee_id'],
      ),

      lastOpnameNote:
          _asNullableString(
        map['last_opname_note'],
      ),

      lastOpnameStock:
          _asNullableDouble(
        map['last_opname_stock'],
      ),

      // =====================================================
      // LAST PURCHASE
      // =====================================================

      lastPurchaseAt:
          _asDateTime(map['last_purchase_at']),

      lastPurchaseBy:
          _asNullableString(
        map['last_purchase_by'],
      ),

      lastPurchaseByName:
          _asNullableString(
        map['last_purchase_by_name'],
      ),

      lastPurchaseByEmployeeId:
          _asNullableString(
        map['last_purchase_by_employee_id'],
      ),

      lastPurchaseQty:
          _asNullableDouble(
        map['last_purchase_qty'],
      ),

      lastPurchasePrice:
          _asNullableDouble(
        map['last_purchase_price'],
      ),

      // =====================================================
      // LAST USAGE
      // =====================================================

      lastUsageAt:
          _asDateTime(map['last_usage_at']),

      lastUsageBy:
          _asNullableString(
        map['last_usage_by'],
      ),

      lastUsageByName:
          _asNullableString(
        map['last_usage_by_name'],
      ),

      lastUsageByEmployeeId:
          _asNullableString(
        map['last_usage_by_employee_id'],
      ),

      lastUsageQty:
          _asNullableDouble(
        map['last_usage_qty'],
      ),

      // =====================================================
      // META
      // =====================================================

      updatedAt:
          _asDateTime(map['updated_at']),

      createdAt:
          _asDateTime(map['created_at']),

      // =====================================================
      // FLAGS
      // =====================================================

      isEmpty:
          _asBool(map['is_empty']),

      isLowStock:
          _asBool(map['is_low_stock']),

      isStockSafe:
          _asBool(map['is_stock_safe']),

      // =====================================================
      // SORT
      // =====================================================

      sortTypeName:
          _asNullableString(
        map['sort_type_name'],
      ),

      sortStockName:
          _asNullableString(
        map['sort_stock_name'],
      ),
    );
  }

  // =====================================================
  // MAP
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      // =====================================================
      // CORE
      // =====================================================

      'id': id,

      'stock_code': stockCode,
      'stock_name': stockName,

      'stock_type_id': stockTypeId,
      'stock_type_name': stockTypeName,
      'stock_type_description':
          stockTypeDescription,

      'unit': unit,

      'minimum_stock': minimumStock,
      'current_stock': currentStock,

      'stock_condition': stockCondition,

      'photo_url': photoUrl,

      'is_active': isActive,

      // =====================================================
      // LAST OPNAME
      // =====================================================

      'last_opname_at':
          lastOpnameAt?.toIso8601String(),

      'last_opname_by':
          lastOpnameBy,

      'last_opname_by_name':
          lastOpnameByName,

      'last_opname_by_employee_id':
          lastOpnameByEmployeeId,

      'last_opname_note':
          lastOpnameNote,

      'last_opname_stock':
          lastOpnameStock,

      // =====================================================
      // LAST PURCHASE
      // =====================================================

      'last_purchase_at':
          lastPurchaseAt?.toIso8601String(),

      'last_purchase_by':
          lastPurchaseBy,

      'last_purchase_by_name':
          lastPurchaseByName,

      'last_purchase_by_employee_id':
          lastPurchaseByEmployeeId,

      'last_purchase_qty':
          lastPurchaseQty,

      'last_purchase_price':
          lastPurchasePrice,

      // =====================================================
      // LAST USAGE
      // =====================================================

      'last_usage_at':
          lastUsageAt?.toIso8601String(),

      'last_usage_by':
          lastUsageBy,

      'last_usage_by_name':
          lastUsageByName,

      'last_usage_by_employee_id':
          lastUsageByEmployeeId,

      'last_usage_qty':
          lastUsageQty,

      // =====================================================
      // META
      // =====================================================

      'updated_at':
          updatedAt?.toIso8601String(),

      'created_at':
          createdAt?.toIso8601String(),

      // =====================================================
      // FLAGS
      // =====================================================

      'is_empty': isEmpty,
      'is_low_stock': isLowStock,
      'is_stock_safe': isStockSafe,

      // =====================================================
      // SORT
      // =====================================================

      'sort_type_name': sortTypeName,
      'sort_stock_name': sortStockName,
    };
  }

  // =====================================================
  // JSON
  // =====================================================

  String toJson() {
    return jsonEncode(toMap());
  }

  factory StocksViewModel.fromJson(
    String source,
  ) {
    return StocksViewModel.fromMap(
      jsonDecode(source),
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  StocksViewModel copyWith({
    String? id,

    String? stockCode,
    String? stockName,

    String? stockTypeId,
    String? stockTypeName,
    String? stockTypeDescription,

    String? unit,

    double? minimumStock,
    double? currentStock,

    String? stockCondition,

    String? photoUrl,

    bool? isActive,

    DateTime? lastOpnameAt,
    String? lastOpnameBy,
    String? lastOpnameByName,
    String? lastOpnameByEmployeeId,
    String? lastOpnameNote,
    double? lastOpnameStock,

    DateTime? lastPurchaseAt,
    String? lastPurchaseBy,
    String? lastPurchaseByName,
    String? lastPurchaseByEmployeeId,
    double? lastPurchaseQty,
    double? lastPurchasePrice,

    DateTime? lastUsageAt,
    String? lastUsageBy,
    String? lastUsageByName,
    String? lastUsageByEmployeeId,
    double? lastUsageQty,

    DateTime? updatedAt,
    DateTime? createdAt,

    bool? isEmpty,
    bool? isLowStock,
    bool? isStockSafe,

    String? sortTypeName,
    String? sortStockName,
  }) {
    return StocksViewModel(
      id: id ?? this.id,

      stockCode:
          stockCode ?? this.stockCode,

      stockName:
          stockName ?? this.stockName,

      stockTypeId:
          stockTypeId ?? this.stockTypeId,

      stockTypeName:
          stockTypeName ?? this.stockTypeName,

      stockTypeDescription:
          stockTypeDescription ??
              this.stockTypeDescription,

      unit: unit ?? this.unit,

      minimumStock:
          minimumStock ?? this.minimumStock,

      currentStock:
          currentStock ?? this.currentStock,

      stockCondition:
          stockCondition ?? this.stockCondition,

      photoUrl:
          photoUrl ?? this.photoUrl,

      isActive:
          isActive ?? this.isActive,

      lastOpnameAt:
          lastOpnameAt ?? this.lastOpnameAt,

      lastOpnameBy:
          lastOpnameBy ?? this.lastOpnameBy,

      lastOpnameByName:
          lastOpnameByName ??
              this.lastOpnameByName,

      lastOpnameByEmployeeId:
          lastOpnameByEmployeeId ??
              this.lastOpnameByEmployeeId,

      lastOpnameNote:
          lastOpnameNote ??
              this.lastOpnameNote,

      lastOpnameStock:
          lastOpnameStock ??
              this.lastOpnameStock,

      lastPurchaseAt:
          lastPurchaseAt ??
              this.lastPurchaseAt,

      lastPurchaseBy:
          lastPurchaseBy ??
              this.lastPurchaseBy,

      lastPurchaseByName:
          lastPurchaseByName ??
              this.lastPurchaseByName,

      lastPurchaseByEmployeeId:
          lastPurchaseByEmployeeId ??
              this.lastPurchaseByEmployeeId,

      lastPurchaseQty:
          lastPurchaseQty ??
              this.lastPurchaseQty,

      lastPurchasePrice:
          lastPurchasePrice ??
              this.lastPurchasePrice,

      lastUsageAt:
          lastUsageAt ?? this.lastUsageAt,

      lastUsageBy:
          lastUsageBy ?? this.lastUsageBy,

      lastUsageByName:
          lastUsageByName ??
              this.lastUsageByName,

      lastUsageByEmployeeId:
          lastUsageByEmployeeId ??
              this.lastUsageByEmployeeId,

      lastUsageQty:
          lastUsageQty ??
              this.lastUsageQty,

      updatedAt:
          updatedAt ?? this.updatedAt,

      createdAt:
          createdAt ?? this.createdAt,

      isEmpty:
          isEmpty ?? this.isEmpty,

      isLowStock:
          isLowStock ?? this.isLowStock,

      isStockSafe:
          isStockSafe ?? this.isStockSafe,

      sortTypeName:
          sortTypeName ??
              this.sortTypeName,

      sortStockName:
          sortStockName ??
              this.sortStockName,
    );
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

  bool get hasPhoto {
    return photoUrl != null &&
        photoUrl!.isNotEmpty;
  }

  bool get hasLowStock {
    return currentStock <= minimumStock;
  }

  bool get isOutOfStock {
    return currentStock <= 0;
  }

  double get stockPercentage {
    if (minimumStock <= 0) {
      return 1;
    }

    final value =
        currentStock / minimumStock;

    if (value < 0) {
      return 0;
    }

    return value;
  }

  String get stockStatusLabel {
    switch (stockCondition.toUpperCase()) {
      case 'LOW':
        return 'Low Stock';

      case 'EMPTY':
        return 'Empty';

      case 'DAMAGED':
        return 'Damaged';

      case 'EXPIRED':
        return 'Expired';

      default:
        return 'Good';
    }
  }

  // =====================================================
  // PARSERS
  // =====================================================

  static String _asString(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String? _asNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text = value.toString();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static double _asDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double? _asNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static bool _asBool(
    dynamic value,
  ) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    return value
            .toString()
            .toLowerCase() ==
        'true';
  }

  static DateTime? _asDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // =====================================================
  // EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StocksViewModel &&
        other.id == id &&
        other.stockName == stockName &&
        other.currentStock == currentStock &&
        other.stockCondition ==
            stockCondition;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        stockName.hashCode ^
        currentStock.hashCode ^
        stockCondition.hashCode;
  }

  @override
  String toString() {
    return '''
StocksViewModel(
  id: $id,
  stockName: $stockName,
  currentStock: $currentStock,
  stockCondition: $stockCondition
)
''';
  }
}