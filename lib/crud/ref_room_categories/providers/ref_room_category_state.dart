import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_room_categories/models/ref_room_category_model.dart';

class RefRoomCategoryState extends Equatable {
  final List<RefRoomCategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;
  final RefRoomCategoryModel? selectedCategory;
  final bool isSubmitting;

  const RefRoomCategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
    this.isSubmitting = false,
  });

  factory RefRoomCategoryState.initial() {
    return const RefRoomCategoryState();
  }

  factory RefRoomCategoryState.loading() {
    return const RefRoomCategoryState(isLoading: true);
  }

  RefRoomCategoryState copyWith({
    List<RefRoomCategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    RefRoomCategoryModel? selectedCategory,
    bool? isSubmitting,
  }) {
    return RefRoomCategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        isLoading,
        errorMessage,
        selectedCategory,
        isSubmitting,
      ];
}