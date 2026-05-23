import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';
import 'package:rsmss/crud/stock_bins/services/stock_bin_service.dart';
import 'stock_bin_state.dart';

final stockBinServiceProvider = Provider<StockBinService>((ref) {
  return StockBinService();
});

final stockBinProvider = StateNotifierProvider<StockBinNotifier, StockBinState>((ref) {
  final service = ref.watch(stockBinServiceProvider);
  return StockBinNotifier(service);
});

class StockBinNotifier extends StateNotifier<StockBinState> {
  final StockBinService _service;

  StockBinNotifier(this._service) : super(StockBinState.initial());

  Future<void> loadBins() async {
    debugPrint('🔄 [Provider] loadBins - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllBins();
      final bins = response.map((json) => StockBinModel.fromJson(json)).toList();
      
      state = state.copyWith(
        bins: bins,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadBins - Success: ${bins.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadBins - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadBinById(String id) async {
    debugPrint('🔄 [Provider] loadBinById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getBinById(id);
      if (response != null) {
        final bin = StockBinModel.fromJson(response);
        state = state.copyWith(
          selectedBin: bin,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadBinById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Bin tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadBinById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createBin(StockBinModel model) async {
    debugPrint('📝 [Provider] createBin - Code: ${model.code}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isCodeExists(model.code, model.shelfId);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode bin "${model.code}" sudah ada di shelf ini',
        );
        return false;
      }

      if (model.barcode != null && model.barcode!.isNotEmpty) {
        final barcodeExists = await _service.isBarcodeExists(model.barcode!);
        if (barcodeExists) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: 'Barcode "${model.barcode}" sudah digunakan',
          );
          return false;
        }
      }

      final data = model.toJson();
      await _service.insertBin(data);
      await loadBins();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createBin - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createBin - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateBin(StockBinModel model) async {
    debugPrint('✏️ [Provider] updateBin - ID: ${model.id}, Code: ${model.code}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID bin tidak ditemukan');
      }

      final exists = await _service.isCodeExists(
        model.code, 
        model.shelfId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode bin "${model.code}" sudah ada di shelf ini',
        );
        return false;
      }

      if (model.barcode != null && model.barcode!.isNotEmpty) {
        final barcodeExists = await _service.isBarcodeExists(
          model.barcode!,
          excludeId: model.id,
        );
        if (barcodeExists) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: 'Barcode "${model.barcode}" sudah digunakan',
          );
          return false;
        }
      }

      final data = model.toJson();
      await _service.updateBin(model.id!, data);
      await loadBins();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateBin - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateBin - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteBin(String id) async {
    debugPrint('🗑️ [Provider] deleteBin - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteBin(id);
      await loadBins();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteBin - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteBin - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSelected() {
    state = state.copyWith(selectedBin: null);
  }

  void setSelectedBin(StockBinModel? bin) {
    state = state.copyWith(selectedBin: bin);
  }
}