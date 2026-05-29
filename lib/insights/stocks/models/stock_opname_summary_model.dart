// File: lib/insights/stocks/models/stock_opname_summary_model.dart

class StockOpnameSummaryModel {
  final int totalOpnames;
  final double totalAdjustment;
  final double totalAbsAdjustment;
  final double avgAdjustment;
  final int problematicItems;

  StockOpnameSummaryModel({
    required this.totalOpnames,
    required this.totalAdjustment,
    required this.totalAbsAdjustment,
    required this.avgAdjustment,
    required this.problematicItems,
  });

  factory StockOpnameSummaryModel.empty() {
    return StockOpnameSummaryModel(
      totalOpnames: 0,
      totalAdjustment: 0,
      totalAbsAdjustment: 0,
      avgAdjustment: 0,
      problematicItems: 0,
    );
  }
}