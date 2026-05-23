import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_asset_types/models/ref_asset_type_model.dart';

class RefAssetTypeState extends Equatable {
  final List<RefAssetTypeModel> types;
  final bool isLoading;
  final String? errorMessage;
  final RefAssetTypeModel? selectedType;
  final bool isSubmitting;

  const RefAssetTypeState({
    this.types = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType,
    this.isSubmitting = false,
  });

  factory RefAssetTypeState.initial() {
    return const RefAssetTypeState();
  }

  factory RefAssetTypeState.loading() {
    return const RefAssetTypeState(isLoading: true);
  }

  RefAssetTypeState copyWith({
    List<RefAssetTypeModel>? types,
    bool? isLoading,
    String? errorMessage,
    RefAssetTypeModel? selectedType,
    bool? isSubmitting,
  }) {
    return RefAssetTypeState(
      types: types ?? this.types,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedType: selectedType ?? this.selectedType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        types,
        isLoading,
        errorMessage,
        selectedType,
        isSubmitting,
      ];
}