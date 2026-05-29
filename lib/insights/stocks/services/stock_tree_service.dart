// File: lib/insights/stocks/services/stock_tree_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_category_model.dart';
import '../models/stock_sub_category_model.dart';
import '../models/stock_type_model.dart';
import '../models/stock_tree_node_model.dart';

class StockTreeService {
  final _supabase = Supabase.instance.client;

  /// Mendapatkan seluruh tree structure stock (termasuk yang kosong)
  Future<List<StockCategoryNode>> getStockTree() async {
    try {
      // =========================================================
      // 1. Ambil ALL categories (termasuk yang tidak punya stock)
      // =========================================================
      final categoriesData = await _supabase
          .from('ref_stock_categories')
          .select()
          .order('category_name');

      final categories = (categoriesData as List)
          .map((e) => StockCategoryModel.fromJson(e))
          .toList();

      if (categories.isEmpty) return [];

      // =========================================================
      // 2. Ambil ALL sub categories
      // =========================================================
      final subCategoriesData = await _supabase
          .from('ref_stock_sub_categories')
          .select()
          .order('sub_category_name');

      final subCategories = (subCategoriesData as List)
          .map((e) => StockSubCategoryModel.fromJson(e))
          .toList();

      // =========================================================
      // 3. Ambil ALL types
      // =========================================================
      final typesData = await _supabase
          .from('ref_stock_types')
          .select()
          .order('type_name');

      final types = (typesData as List)
          .map((e) => StockTypeModel.fromJson(e))
          .toList();

      // =========================================================
      // 4. Ambil ALL stocks (aktif) untuk dihitung
      // =========================================================
      final stocksData = await _supabase
          .from('stocks')
          .select('id, stock_name, unit, current_stock, minimum_stock, stock_condition, stock_type_id')
          .eq('is_active', true);

      final stocks = (stocksData as List)
          .map((e) => StockTreeItem.fromJson(e))
          .toList();

      // =========================================================
      // 5. Build tree structure (termasuk yang kosong)
      // =========================================================
      return _buildTree(categories, subCategories, types, stocks);
    } catch (e) {
      debugPrint('Error loading stock tree: $e');
      return [];
    }
  }

  /// Build tree dari data yang sudah diambil (termasuk yang kosong)
  List<StockCategoryNode> _buildTree(
    List<StockCategoryModel> categories,
    List<StockSubCategoryModel> subCategories,
    List<StockTypeModel> types,
    List<StockTreeItem> stocks,
  ) {
    final List<StockCategoryNode> nodes = [];

    for (final category in categories) {
      // Filter sub categories untuk category ini (ALL sub categories)
      final categorySubs = subCategories
          .where((sc) => sc.categoryId == category.id)
          .toList();

      final List<StockSubCategoryNode> subCategoryNodes = [];

      for (final subCategory in categorySubs) {
        // Filter types untuk sub category ini (ALL types)
        final subTypes = types
            .where((t) => t.subCategoryId == subCategory.id)
            .toList();

        final List<StockTypeNode> typeNodes = [];

        for (final type in subTypes) {
          // Filter stocks untuk type ini
          final typeStocks = stocks
              .where((s) => s.stockTypeId == type.id)
              .toList();

          // SELALU tambahkan type, meskipun stocks kosong
          typeNodes.add(StockTypeNode(
            type: type,
            items: typeStocks,
          ));
        }

        // SELALU tambahkan sub category, meskipun types kosong
        subCategoryNodes.add(StockSubCategoryNode(
          subCategory: subCategory,
          types: typeNodes,
        ));
      }

      // SELALU tambahkan category, meskipun sub categories kosong
      nodes.add(StockCategoryNode(
        category: category,
        subCategories: subCategoryNodes,
      ));
    }

    return nodes;
  }

  /// Mendapatkan ringkasan cepat (untuk KPI card)
  Future<Map<String, dynamic>> getTreeSummary() async {
    try {
      final categoriesData = await _supabase
          .from('ref_stock_categories')
          .select('id');
      
      final subCategoriesData = await _supabase
          .from('ref_stock_sub_categories')
          .select('id');
      
      final typesData = await _supabase
          .from('ref_stock_types')
          .select('id');
      
      final stocksData = await _supabase
          .from('stocks')
          .select('id')
          .eq('is_active', true);

      return {
        'totalCategories': (categoriesData as List).length,
        'totalSubCategories': (subCategoriesData as List).length,
        'totalTypes': (typesData as List).length,
        'totalStocks': (stocksData as List).length,
      };
    } catch (e) {
      debugPrint('Error loading tree summary: $e');
      return {
        'totalCategories': 0,
        'totalSubCategories': 0,
        'totalTypes': 0,
        'totalStocks': 0,
      };
    }
  }

  /// Search stock items by name
  Future<List<StockTreeItem>> searchStock(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final result = await _supabase
          .from('stocks')
          .select('id, stock_name, unit, current_stock, minimum_stock, stock_condition, stock_type_id')
          .eq('is_active', true)
          .ilike('stock_name', '%$query%')
          .limit(50);

      return (result as List)
          .map((e) => StockTreeItem.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error searching stock: $e');
      return [];
    }
  }
}