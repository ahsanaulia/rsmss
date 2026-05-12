class AssetGroupModel {
  final String? id;
  final String? name;
  final int totalAssets;

  AssetGroupModel({
    required this.id,
    required this.name,
    required this.totalAssets,
  });

  factory AssetGroupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetGroupModel(
      id:
          json['category_id'] ??
          json['sub_category_id'] ??
          json['type_id'],

      name:
          json['category_name'] ??
          json['sub_category_name'] ??
          json['type_name'] ??
          json['status_condition'],

      totalAssets:
          json['total_assets'] ?? 0,
    );
  }
}