import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';

part 'player_bar_event.dart';
part 'player_bar_state.dart';

class PlayerBarBloc extends Bloc<PlayerBarEvent, PlayerBarState> {
  PlayerBarBloc() : super(PlayerBarInitial(height: 60, isInAudioSection: false)) {
    on<PlayerBarEvent>((event, emit) {
      final currentState = state;
      bool currentSection = false;
      bool currentMinimized = true;
      double currentHeight = 60;

      if (currentState is PlayerBarVisible) {
        currentSection = currentState.isInAudioSection;
        currentMinimized = currentState.isMinimized;
        currentHeight = currentState.height;
      }
      if (currentState is PlayerBarInitial) {
        currentSection = currentState.isInAudioSection;
        currentMinimized = currentState.isMinimized;
        currentHeight = currentState.height;
      }

      if (event is HideBarEvent) {
        emit(PlayerBarHidden());
      } else if (event is ShowBarEvent) {
        emit(PlayerBarVisible(height: currentHeight, isInAudioSection: currentSection, isMinimized: false));
      } else if (event is MinimizeBarEvent) {
        emit(PlayerBarVisible(height: currentHeight, isInAudioSection: currentSection, isMinimized: true));
      } else if (event is ExtendBarEvent) {
        emit(PlayerBarVisible(height: 70, isInAudioSection: currentSection, isMinimized: currentMinimized));
      } else if (event is CloseBarEvent) {
        emit(PlayerBarClosed());
      } else if (event is SetSectionVisibilityEvent) {
        emit(PlayerBarVisible(height: currentHeight, isInAudioSection: event.isInAudioSection, isMinimized: currentMinimized));
      }
    });
  }
}
