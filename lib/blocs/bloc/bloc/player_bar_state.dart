part of 'player_bar_bloc.dart';

@immutable
class PlayerBarState {}

class PlayerBarInitial extends PlayerBarState {
  double height;
  bool isInAudioSection;
  bool isMinimized;
  PlayerBarInitial({
    required this.height,
    this.isInAudioSection = false,
    this.isMinimized = true,
  });
}

class PlayerBarVisible extends PlayerBarState {
  double height;
  bool isInAudioSection;
  bool isMinimized;
  PlayerBarVisible({
    required this.height,
    this.isInAudioSection = false,
    this.isMinimized = true,
  });
}

class PlayerBarHidden extends PlayerBarState {}

class PlayerBarClosed extends PlayerBarState {}
