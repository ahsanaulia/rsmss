import 'dart:io';

class IncidentState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  // Dropdown data
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> rooms;

  // Form fields
  final String title;
  final String description;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final String? selectedCategoryCode;
  final String? selectedRoomId;
  final String? selectedRoomName;
  final String severity;
  final String locationText;
  final DateTime occurredAt;
  final List<File> photos;

  // 🔴 TAMBAHKAN: GPS Location fields
  final double? lat;
  final double? long;
  final String? address;

  IncidentState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isSaved = false,
    this.categories = const [],
    this.rooms = const [],
    this.title = '',
    this.description = '',
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.selectedCategoryCode,
    this.selectedRoomId,
    this.selectedRoomName,
    this.severity = 'MEDIUM',
    this.locationText = '',
    DateTime? occurredAt,
    this.photos = const [],
    this.lat,
    this.long,
    this.address,
  }) : occurredAt = occurredAt ?? DateTime.now();

  bool get isValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        selectedCategoryId != null;
  }

  /// Apakah lokasi GPS sudah diisi?
  bool get hasGpsLocation => lat != null && long != null;

  IncidentState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isSaved,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? rooms,
    String? title,
    String? description,
    String? selectedCategoryId,
    String? selectedCategoryName,
    String? selectedCategoryCode,
    String? selectedRoomId,
    String? selectedRoomName,
    String? severity,
    String? locationText,
    DateTime? occurredAt,
    List<File>? photos,
    double? lat,
    double? long,
    String? address,
  }) {
    return IncidentState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaved: isSaved ?? this.isSaved,
      categories: categories ?? this.categories,
      rooms: rooms ?? this.rooms,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedCategoryName: selectedCategoryName ?? this.selectedCategoryName,
      selectedCategoryCode: selectedCategoryCode ?? this.selectedCategoryCode,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      selectedRoomName: selectedRoomName ?? this.selectedRoomName,
      severity: severity ?? this.severity,
      locationText: locationText ?? this.locationText,
      occurredAt: occurredAt ?? this.occurredAt,
      photos: photos ?? this.photos,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      address: address ?? this.address,
    );
  }
}