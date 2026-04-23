part of 'player_bloc_bloc.dart';

@immutable
class PlayerBlocState {}

class PlayerBlocInitial extends PlayerBlocState {}

class PlayerBlocPlaying extends PlayerBlocState {
  Moshaf moshaf;
  Reciter reciter;
  int suraNumber;
  // String suraName;
  var jsonData;
  AudioPlayer audioPlayer;
  List surahNumbers;var playList;

  // bool isHidden;
  double? downloadProgress;
  String? downloadingSuraNumber;

  PlayerBlocPlaying({
    required this.moshaf,
    required this.reciter,
    required this.suraNumber,
    required this.jsonData,
    required this.audioPlayer,
    required this.surahNumbers,
    required this.playList,
    this.downloadProgress,
    this.downloadingSuraNumber,
  });
}

class PlayerBlocPaused extends PlayerBlocState {}

class PlayerBlocClosed extends PlayerBlocState {}

class PlayerBlocDownloading extends PlayerBlocState {
  final String suraNumber;
  final double progress;
  PlayerBlocDownloading({required this.suraNumber, required this.progress});
}
