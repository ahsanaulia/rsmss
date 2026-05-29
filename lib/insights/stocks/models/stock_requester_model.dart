// File: lib/insights/stocks/models/stock_requester_model.dart

class StockRequesterModel {
  final String requesterId;
  final String requesterName;
  final String? positionName;
  final String? unitName;
  final int totalRequests;
  final double totalQuantity;

  StockRequesterModel({
    required this.requesterId,
    required this.requesterName,
    this.positionName,
    this.unitName,
    required this.totalRequests,
    required this.totalQuantity,
  });
}

class StockRequestPerUnitModel {
  final String unitName;
  final int totalRequests;
  final double totalQuantity;

  StockRequestPerUnitModel({
    required this.unitName,
    required this.totalRequests,
    required this.totalQuantity,
  });
}

class StockRequestPerRoomModel {
  final String roomName;
  final int totalRequests;
  final double totalQuantity;

  StockRequestPerRoomModel({
    required this.roomName,
    required this.totalRequests,
    required this.totalQuantity,
  });
}

class StockRequestPerPositionModel {
  final String positionName;
  final int totalRequests;
  final double totalQuantity;

  StockRequestPerPositionModel({
    required this.positionName,
    required this.totalRequests,
    required this.totalQuantity,
  });
}

class StockRequestTrendModel {
  final DateTime date;
  final int totalRequests;
  final double totalQuantity;

  StockRequestTrendModel({
    required this.date,
    required this.totalRequests,
    required this.totalQuantity,
  });
}