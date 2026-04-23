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
      if (currentState is PlayerBarVisible) currentSection = currentState.isInAudioSection;
      if (currentState is PlayerBarInitial) currentSection = currentState.isInAudioSection;

      if (event is HideBarEvent) {
        emit(PlayerBarHidden());
      } else if (event is ShowBarEvent || event is MinimizeBarEvent) {
        emit(PlayerBarVisible(height: 60, isInAudioSection: currentSection));
      } else if (event is ExtendBarEvent) {
        emit(PlayerBarVisible(height: 70, isInAudioSection: currentSection));
      } else if (event is CloseBarEvent) {
        emit(PlayerBarClosed());
      } else if (event is SetSectionVisibilityEvent) {
        if (currentState is PlayerBarVisible) {
          emit(PlayerBarVisible(height: currentState.height, isInAudioSection: event.isInAudioSection));
        } else if (currentState is PlayerBarInitial) {
          emit(PlayerBarInitial(height: currentState.height, isInAudioSection: event.isInAudioSection));
        }
      }
    });
  }
}
