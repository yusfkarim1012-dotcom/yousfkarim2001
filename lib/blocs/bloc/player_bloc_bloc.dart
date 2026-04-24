import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khatmah/features/audiopage/models/reciter.dart';
// import 'package:khatmah/features/home.dart';r
import 'package:khatmah/features/home.dart';
import 'package:khatmah/main.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:khatmah/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:khatmah/GlobalHelpers/constants.dart';
part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  PlayerBlocBloc() : super(PlayerBlocInitial()) {
    // AudioPlayer? audioPlayer;

    on<PlayerBlocEvent>((event, emit) async {
      // ignore: unnecessary_null_comparison
      if (event is StartPlaying) {
        // if (audioPlayer != null) {
          // audioPlayer!.dispose();
        // }
        // audioPlayer = AudioPlayer();
        audioPlayer.stop();
        int nextMediaId = 0;
        List<String> surahNumbers = event.moshaf.surahList.split(',');
        final appDir = Directory(kDownloadPath);

        if (surahNumbers.any((element) {
          if (File(
                  "${appDir.path}${event.reciter.name}/${event.moshaf.id}-${quran.getSurahNameArabic(int.parse(element))}.mp3")
              .existsSync()) {
            return true;
          } else {
            return false;
          }
        })) {
          PermissionStatus status;
          if (Platform.isAndroid) {
            status = await Permission.audio.request();
            if (!status.isGranted) {
               status = await Permission.storage.request();
            }
          } else {
            status = await Permission.storage.request();
          }
          
          if (status.isGranted || status.isLimited) {
            print(true);
          } else if (status.isPermanentlyDenied) {
            await openAppSettings();
          } else if (status.isDenied) {
            print('Permission Denied');
          }
        }
        List reciterLinks = surahNumbers.map((e) {
          if (File(
                  "${appDir.path}${event.reciter.name}/${event.moshaf.id}-${quran.getSurahNameArabic(int.parse(e))}.mp3")
              .existsSync()) {
            var link = {
              "link": Uri.file(
                  "${appDir.path}${event.reciter.name}/${event.moshaf.id}-${quran.getSurahNameArabic(int.parse(e))}.mp3"),
              "suraNumber": e
            };
            return link;
          } else {
            var link = {
              "link": Uri.parse(
                      "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3")
                  .replace(scheme: 'http'),
              "suraNumber": e
            };
            return link;
          }
        }).toList();

        // Islamic-themed background images for media notification
        final List<Uri> audioBackgrounds = [
          Uri.parse('asset:///assets/images/audio_bg_1.png'),
          Uri.parse('asset:///assets/images/audio_bg_2.png'),
          Uri.parse('asset:///assets/images/audio_bg_3.png'),
        ];

        var playList = reciterLinks.map((e) {
          // Cycle through the 3 Islamic images based on index
          final currentIndex = nextMediaId;
          return AudioSource.uri(
            e["link"],
            tag: MediaItem(
              id: '${nextMediaId++}',
              album: "${event.reciter.name}",
              title: event.jsonData
                  .where((element) =>
                      element["id"].toString() == e["suraNumber"].toString())
                  .first["name"]
                  .toString(),
              artUri: audioBackgrounds[currentIndex % audioBackgrounds.length],
            ),
          );
        }).toList();
        String currentSuraNumber = "";
        if (event.suraNumber == -1) {
          currentSuraNumber = surahNumbers[0];
        }
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        // Listen to errors during playback.
        audioPlayer!.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
        audioPlayer!.setLoopMode(LoopMode.off);
        try {
          // var originalUri = Uri.parse(
          //     "${event.moshaf.server}/${currentSuraNumber.toString().padLeft(3, "0")}.mp3");
          // var newUri = originalUri.replace(scheme: 'http');

          // print(surahNumbers.length);

          await audioPlayer!.setAudioSource(
              initialIndex: event.initialIndex,
              // initialIndex: 2//event.suraNumber == -1 ? int.parse(currentSuraNumber) : event.suraNumber
              // ,
              // initialPosition: Duration.zero,

              ConcatenatingAudioSource(children: playList));
        } catch (e) {
          // Catch load errors: 404, invalid url ...
          print("Error loading playlist: $e");
          // print(stackTrace);
        }
        audioPlayer!.play();

        playerbarBloc.add(ShowBarEvent());
        emit(PlayerBlocPlaying(
            moshaf: event.moshaf,
            reciter: event.reciter,
            suraNumber: event.suraNumber == -1
                ? int.parse(currentSuraNumber)
                : event.suraNumber,
            // suraName: event.suraName,
            jsonData: event.jsonData,
            audioPlayer: audioPlayer!,
            surahNumbers: surahNumbers,
            playList: playList));
      } else if (event is DownloadSurah) {
        final dio = Dio();
        final appDir = Directory(kDownloadPath);
        
        PermissionStatus status = await Permission.audio.status;
        if (!status.isGranted) {
           status = await Permission.audio.request();
           if (!status.isGranted) {
              status = await Permission.storage.request();
           }
        }
        
        if (!(status.isGranted || status.isLimited)) {
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return;
        }

        final reciterDir = Directory("${appDir.path}${event.reciter.name}");
        if (!reciterDir.existsSync()) {
          reciterDir.createSync(recursive: true);
        }

        final fullSuraFilePath =
            "${reciterDir.path}/${event.moshaf.id}-${quran.getSurahNameArabic(int.parse(event.suraNumber))}.mp3";

        if (File(fullSuraFilePath).existsSync()) {
          print('Full sura audio file already cached: $fullSuraFilePath');
        } else {
          try {
            int lastProgress = -1;
            await dio.download(event.url, fullSuraFilePath, onReceiveProgress: (received, total) {
              if (total != -1) {
                int currentProgress = ((received / total) * 100).toInt();
                if (currentProgress != lastProgress) {
                  lastProgress = currentProgress;
                  if (state is PlayerBlocPlaying) {
                    final s = state as PlayerBlocPlaying;
                    emit(PlayerBlocPlaying(
                      moshaf: s.moshaf,
                      reciter: s.reciter,
                      suraNumber: s.suraNumber,
                      jsonData: s.jsonData,
                      audioPlayer: s.audioPlayer,
                      surahNumbers: s.surahNumbers,
                      playList: s.playList,
                      downloadProgress: received / total,
                      downloadingSuraNumber: event.suraNumber,
                    ));
                  } else {
                    emit(PlayerBlocDownloading(
                      suraNumber: event.suraNumber,
                      progress: received / total,
                    ));
                  }
                }
              }
            });
            
            if (state is PlayerBlocPlaying || state is PlayerBlocDownloading) {
               if (state is PlayerBlocPlaying) {
                  final s = state as PlayerBlocPlaying;
                  emit(PlayerBlocPlaying(
                    moshaf: s.moshaf,
                    reciter: s.reciter,
                    suraNumber: s.suraNumber,
                    jsonData: s.jsonData,
                    audioPlayer: s.audioPlayer,
                    surahNumbers: s.surahNumbers,
                    playList: s.playList,
                  ));
               } else {
                  emit(PlayerBlocInitial());
               }
            }
          } catch (e) {
            print(e);
            if (state is! PlayerBlocPlaying) emit(PlayerBlocInitial());
          }
        }
      } else if (event is DownloadAllSurahs) {
        final dio = Dio();
        final appDir = Directory(kDownloadPath);
        
        if (!appDir.existsSync()) {
          appDir.createSync(recursive: true);
        }

        PermissionStatus status;
        if (Platform.isAndroid) {
          // For Android 13+ (API 33+)
          // We check if we can request audio permission
          status = await Permission.audio.request();
          if (!status.isGranted) {
             status = await Permission.storage.request();
          }
        } else {
          status = await Permission.storage.request();
        }

        if (status.isGranted || status.isLimited) {
          final reciterDir = Directory("${appDir.path}${event.reciter.name}");
          if (!reciterDir.existsSync()) {
            reciterDir.createSync(recursive: true);
          }

          List<String> surahNumbers = event.moshaf.surahList.split(',');
          int total = surahNumbers.length;
          
          for (var i = 0; i < total; i++) {
            final sNumRaw = surahNumbers[i].trim();
            if (sNumRaw.isEmpty) continue;
            
            final suraNumber = sNumRaw.padLeft(3, "0");
            final suraName = quran.getSurahNameArabic(int.parse(sNumRaw));
            final fullSuraFilePath = "${reciterDir.path}/${event.moshaf.id}-$suraName.mp3";
            final url = "${event.moshaf.server}/$suraNumber.mp3";

            emit(PlayerBlocDownloading(
              suraNumber: "all-${event.reciter.name}-${event.moshaf.id}",
              progress: (i + 1) / total,
            ));

            if (!File(fullSuraFilePath).existsSync()) {
              try {
                await dio.download(url, fullSuraFilePath);
              } catch (e) {
                print("Error downloading surah $sNumRaw: $e");
              }
            }
          }
          emit(PlayerBlocInitial());
        } else {
          print("Permissions denied for download all");
          // Maybe open app settings if permanently denied
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      } else if (event is ClosePlayerEvent) {
        if (audioPlayer != null){ audioPlayer!.dispose();}
        emit(PlayerBlocInitial());
      } else if (event is PausePlayer) {
        emit(PlayerBlocPaused());
      }
    });
  }
}
