// lib/insights/assets/services/asset_tree_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_tree_model.dart';

class AssetTreeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AssetCategoryNode>> getAssetTree() async {
    print('📊 [AssetTreeService] Mengambil data tree asset...');

    // Step 1: Ambil semua categories
    final categoriesRes = await _supabase
        .from('ref_asset_categories')
        .select('id, category_name')
        .order('category_name');

    // Step 2: Ambil semua sub categories
    final subCategoriesRes = await _supabase
        .from('ref_asset_sub_categories')
        .select('id, category_id, sub_category_name')
        .order('sub_category_name');

    // Step 3: Ambil semua types
    final typesRes = await _supabase
        .from('ref_asset_types')
        .select('id, sub_category_id, type_name')
        .order('type_name');

    // Step 4: Ambil semua assets dengan type_id
    final assetsRes = await _supabase
        .from('assets')
        .select('''
          id,
          asset_name,
          rfid_tag_id,
          status_condition,
          type_id,
          last_room_id,
          foto_url,
          is_dangerous,
          rooms!left(
            room_name
          )
        ''')
        .eq('is_active', true);

    // Build mapping: type_id -> assets
    final Map<String, List<AssetItem>> assetsByType = {};
    for (final asset in assetsRes) {
      final typeId = asset['type_id'] as String?;
      if (typeId != null) {
        final room = asset['rooms'];
        final roomName = room != null ? room['room_name'] as String? : null;
        
        final assetItem = AssetItem(
          id: asset['id'] as String,
          name: asset['asset_name'] as String? ?? 'Unknown',
          rfidTagId: asset['rfid_tag_id'] as String? ?? '',
          statusCondition: asset['status_condition'] as String?,
          lastRoomName: roomName,
          fotoUrl: asset['foto_url'] as String?,
          isDangerous: asset['is_dangerous'] == true,
        );
        assetsByType.putIfAbsent(typeId, () => []).add(assetItem);
      }
    }

    // Build mapping: sub_category_id -> types with asset count
    final Map<String, List<AssetTypeNode>> typesBySubCategory = {};
    for (final type in typesRes) {
      final subCategoryId = type['sub_category_id'] as String?;
      if (subCategoryId == null) continue;
      
      final typeId = type['id'] as String;
      final assets = assetsByType[typeId] ?? [];
      
      final typeNode = AssetTypeNode(
        id: typeId,
        name: type['type_name'] as String? ?? 'Unknown',
        assetCount: assets.length,
        assets: assets,
      );
      
      typesBySubCategory.putIfAbsent(subCategoryId, () => []).add(typeNode);
    }

    // Build mapping: category_id -> sub categories with type count
    final Map<String, List<AssetSubCategoryNode>> subCategoriesByCategory = {};
    for (final subCat in subCategoriesRes) {
      final categoryId = subCat['category_id'] as String?;
      if (categoryId == null) continue;
      
      final subCatId = subCat['id'] as String;
      final types = typesBySubCategory[subCatId] ?? [];
      final totalAssets = types.fold(0, (sum, t) => sum + t.assetCount);
      
      final subCatNode = AssetSubCategoryNode(
        id: subCatId,
        name: subCat['sub_category_name'] as String? ?? 'Unknown',
        assetCount: totalAssets,
        types: types,
      );
      
      subCategoriesByCategory.putIfAbsent(categoryId, () => []).add(subCatNode);
    }

    // Build final categories
    final List<AssetCategoryNode> categories = [];
    for (final cat in categoriesRes) {
      final catId = cat['id'] as String;
      final subCategories = subCategoriesByCategory[catId] ?? [];
      final totalAssets = subCategories.fold(0, (sum, sc) => sum + sc.assetCount);
      
      categories.add(AssetCategoryNode(
        id: catId,
        name: cat['category_name'] as String? ?? 'Unknown',
        assetCount: totalAssets,
        subCategories: subCategories,
      ));
    }

    print('📊 [AssetTreeService] Ditemukan ${categories.length} categories, total assets: ${categories.fold(0, (sum, c) => sum + c.assetCount)}');
    
    return categories;
  }

  Future<List<AssetItem>> getAssetsByTypeId(String typeId) async {
    final response = await _supabase
        .from('assets')
        .select('''
          id,
          asset_name,
          rfid_tag_id,
          status_condition,
          type_id,
          last_room_id,
          foto_url,
          is_dangerous,
          rooms!left(
            room_name
          )
        ''')
        .eq('type_id', typeId)
        .eq('is_active', true);

    final List<AssetItem> assets = [];
    for (final json in response) {
      final room = json['rooms'];
      final roomName = room != null ? room['room_name'] as String? : null;
      
      assets.add(AssetItem(
        id: json['id'] as String,
        name: json['asset_name'] as String? ?? 'Unknown',
        rfidTagId: json['rfid_tag_id'] as String? ?? '',
        statusCondition: json['status_condition'] as String?,
        lastRoomName: roomName,
        fotoUrl: json['foto_url'] as String?,
        isDangerous: json['is_dangerous'] == true,
      ));
    }
    
    return assets;
  }
}