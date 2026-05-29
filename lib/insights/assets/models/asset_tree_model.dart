// lib/insights/assets/models/asset_tree_model.dart

class AssetCategoryNode {
  final String id;
  final String name;
  final int assetCount;
  final List<AssetSubCategoryNode> subCategories;

  AssetCategoryNode({
    required this.id,
    required this.name,
    required this.assetCount,
    this.subCategories = const [],
  });

  AssetCategoryNode copyWith({
    String? id,
    String? name,
    int? assetCount,
    List<AssetSubCategoryNode>? subCategories,
  }) {
    return AssetCategoryNode(
      id: id ?? this.id,
      name: name ?? this.name,
      assetCount: assetCount ?? this.assetCount,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}

class AssetSubCategoryNode {
  final String id;
  final String name;
  final int assetCount;
  final List<AssetTypeNode> types;

  AssetSubCategoryNode({
    required this.id,
    required this.name,
    required this.assetCount,
    this.types = const [],
  });

  AssetSubCategoryNode copyWith({
    String? id,
    String? name,
    int? assetCount,
    List<AssetTypeNode>? types,
  }) {
    return AssetSubCategoryNode(
      id: id ?? this.id,
      name: name ?? this.name,
      assetCount: assetCount ?? this.assetCount,
      types: types ?? this.types,
    );
  }
}

class AssetTypeNode {
  final String id;
  final String name;
  final int assetCount;
  final List<AssetItem> assets;

  AssetTypeNode({
    required this.id,
    required this.name,
    required this.assetCount,
    this.assets = const [],
  });

  AssetTypeNode copyWith({
    String? id,
    String? name,
    int? assetCount,
    List<AssetItem>? assets,
  }) {
    return AssetTypeNode(
      id: id ?? this.id,
      name: name ?? this.name,
      assetCount: assetCount ?? this.assetCount,
      assets: assets ?? this.assets,
    );
  }
}

class AssetItem {
  final String id;
  final String name;
  final String rfidTagId;
  final String? statusCondition;
  final String? lastRoomName;
  final String? fotoUrl;
  final bool isDangerous;

  AssetItem({
    required this.id,
    required this.name,
    required this.rfidTagId,
    this.statusCondition,
    this.lastRoomName,
    this.fotoUrl,
    this.isDangerous = false,
  });

  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'] as String,
      name: json['asset_name'] as String? ?? 'Unknown',
      rfidTagId: json['rfid_tag_id'] as String? ?? '',
      statusCondition: json['status_condition'] as String?,
      lastRoomName: json['last_room_name'] as String?,
      fotoUrl: json['foto_url'] as String?,
      isDangerous: json['is_dangerous'] == true,
    );
  }
}