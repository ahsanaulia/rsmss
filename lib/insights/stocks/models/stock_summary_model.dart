class StockSummaryModel {
  final int totalItems;
  final double totalQuantity;
  final int lowStock;
  final int emptyStock;
  final double stockValue;

  const StockSummaryModel({
    required this.totalItems,
    required this.totalQuantity,
    required this.lowStock,
    required this.emptyStock,
    required this.stockValue,
  });

  factory StockSummaryModel.empty() {
    return const StockSummaryModel(
      totalItems: 0,
      totalQuantity: 0,
      lowStock: 0,
      emptyStock: 0,
      stockValue: 0,
    );
  }

  double get healthPercentage {
    final healthyItems = totalItems - lowStock - emptyStock;
    if (totalItems == 0) return 0;
    return (healthyItems / totalItems) * 100;
  }
}