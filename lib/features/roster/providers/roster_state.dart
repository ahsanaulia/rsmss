import '../models/roster_model.dart';

class RosterState {
  final bool isLoading;
  final String? errorMessage;
  final bool isFlexibleRoster;
  final RosterModel? todayRoster;
  final RosterModel? nextRoster;
  final RosterModel? defaultShift;

  RosterState({
    this.isLoading = true,
    this.errorMessage,
    this.isFlexibleRoster = false,
    this.todayRoster,
    this.nextRoster,
    this.defaultShift,
  });

  bool get hasRoster => todayRoster != null || defaultShift != null;

  RosterModel get displayTodayRoster => todayRoster ?? defaultShift!;

  RosterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isFlexibleRoster,
    RosterModel? todayRoster,
    RosterModel? nextRoster,
    RosterModel? defaultShift,
  }) {
    return RosterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isFlexibleRoster: isFlexibleRoster ?? this.isFlexibleRoster,
      todayRoster: todayRoster ?? this.todayRoster,
      nextRoster: nextRoster ?? this.nextRoster,
      defaultShift: defaultShift ?? this.defaultShift,
    );
  }
}