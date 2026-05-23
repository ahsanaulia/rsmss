import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/rooms/models/room_model.dart';
import 'package:rsmss/crud/rooms/services/room_service.dart';
import 'room_state.dart';

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  final service = ref.watch(roomServiceProvider);
  return RoomNotifier(service);
});

class RoomNotifier extends StateNotifier<RoomState> {
  final RoomService _service;

  RoomNotifier(this._service) : super(RoomState.initial());

  Future<void> loadRooms() async {
    debugPrint('🔄 [Provider] loadRooms - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllRooms();
      final rooms = response.map((json) => RoomModel.fromJson(json)).toList();
      
      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadRooms - Success: ${rooms.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadRooms - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadRoomById(String id) async {
    debugPrint('🔄 [Provider] loadRoomById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getRoomById(id);
      if (response != null) {
        final room = RoomModel.fromJson(response);
        state = state.copyWith(
          selectedRoom: room,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadRoomById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Ruangan tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadRoomById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createRoom(RoomModel model) async {
    debugPrint('📝 [Provider] createRoom - Name: ${model.roomName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.floorId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih lantai terlebih dahulu',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertRoom(data);
      await loadRooms();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createRoom - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createRoom - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateRoom(RoomModel model) async {
    debugPrint('✏️ [Provider] updateRoom - ID: ${model.id}, Name: ${model.roomName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID ruangan tidak ditemukan');
      }
      if (model.floorId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih lantai terlebih dahulu',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateRoom(model.id!, data);
      await loadRooms();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateRoom - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateRoom - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteRoom(String id) async {
    debugPrint('🗑️ [Provider] deleteRoom - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteRoom(id);
      await loadRooms();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteRoom - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteRoom - Error: $e');
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
    state = state.copyWith(selectedRoom: null);
  }

  void setSelectedRoom(RoomModel? room) {
    state = state.copyWith(selectedRoom: room);
  }
}