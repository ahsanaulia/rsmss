// lib/insights/assets/providers/asset_detail_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_detail_service.dart';
import '../models/asset_detail_model.dart';

final assetDetailServiceProvider = Provider<AssetDetailService>((ref) {
  return AssetDetailService();
});

final selectedAssetIdProvider = StateProvider<String?>((ref) => null);

final assetDetailProvider = FutureProvider<AssetDetail?>((ref) async {
  final assetId = ref.watch(selectedAssetIdProvider);
  if (assetId == null) return null;
  
  final service = ref.read(assetDetailServiceProvider);
  final result = await service.getAssetDetail(assetId);
  return result;
});