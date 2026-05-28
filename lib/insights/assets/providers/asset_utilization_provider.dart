// lib/insights/assets/providers/asset_utilization_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_utilization_service.dart';
import '../models/asset_utilization_model.dart';

final assetUtilizationServiceProvider = Provider<AssetUtilizationService>((ref) {
  return AssetUtilizationService();
});

final assetUtilizationProvider = FutureProvider<AssetUtilizationSummary>((ref) async {
  final service = ref.read(assetUtilizationServiceProvider);
  return await service.getAssetUtilizationSummary();
});