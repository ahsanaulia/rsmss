// File: lib/insights/stocks/models/stock_request_summary_model.dart

class StockRequestSummaryModel {
  final int totalRequests;
  final int pending;
  final int approved;
  final int rejected;
  final int fulfilled;
  final double approvalRate;
  final double averageProcessingHours;

  StockRequestSummaryModel({
    required this.totalRequests,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.fulfilled,
    required this.approvalRate,
    required this.averageProcessingHours,
  });

  factory StockRequestSummaryModel.empty() {
    return StockRequestSummaryModel(
      totalRequests: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
      fulfilled: 0,
      approvalRate: 0.0,
      averageProcessingHours: 0.0,
    );
  }
}