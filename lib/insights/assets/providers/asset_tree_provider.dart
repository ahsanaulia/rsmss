// lib/insights/assets/providers/asset_tree_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_tree_service.dart';
import '../models/asset_tree_model.dart';

final assetTreeServiceProvider = Provider<AssetTreeService>((ref) {
  return AssetTreeService();
});

final assetTreeProvider = FutureProvider<List<AssetCategoryNode>>((ref) async {
  final service = ref.read(assetTreeServiceProvider);
  return await service.getAssetTree();
});

final assetsByTypeProvider = FutureProvider.family<List<AssetItem>, String>((ref, typeId) async {
  final service = ref.read(assetTreeServiceProvider);
  return await service.getAssetsByTypeId(typeId);
});