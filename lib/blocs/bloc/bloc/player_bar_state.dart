part of 'player_bar_bloc.dart';

@immutable
class PlayerBarState {}

class PlayerBarInitial extends PlayerBarState {
  double height;
  bool isInAudioSection;
  PlayerBarInitial({
    required this.height,
    this.isInAudioSection = false,
  });
}

class PlayerBarVisible extends PlayerBarState {
  double height;
  bool isInAudioSection;
  PlayerBarVisible({
    required this.height,
    this.isInAudioSection = false,
  });
}

class PlayerBarHidden extends PlayerBarState {}

class PlayerBarClosed extends PlayerBarState {}
