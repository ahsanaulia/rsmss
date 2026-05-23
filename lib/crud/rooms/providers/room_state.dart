import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/rooms/models/room_model.dart';

class RoomState extends Equatable {
  final List<RoomModel> rooms;
  final bool isLoading;
  final String? errorMessage;
  final RoomModel? selectedRoom;
  final bool isSubmitting;

  const RoomState({
    this.rooms = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedRoom,
    this.isSubmitting = false,
  });

  factory RoomState.initial() {
    return const RoomState();
  }

  factory RoomState.loading() {
    return const RoomState(isLoading: true);
  }

  RoomState copyWith({
    List<RoomModel>? rooms,
    bool? isLoading,
    String? errorMessage,
    RoomModel? selectedRoom,
    bool? isSubmitting,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        rooms,
        isLoading,
        errorMessage,
        selectedRoom,
        isSubmitting,
      ];
}