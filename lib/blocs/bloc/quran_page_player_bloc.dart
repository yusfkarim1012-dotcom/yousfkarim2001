// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';


part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';
class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {

    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
      

        // audioPlayer = AudioPlayer();

        // Verify reciter exists
        final reciterMatch = reciters.firstWhere(
          (element) => element["identifier"] == event.reciterIdentifier,
          orElse: () => null,
        );
        if (reciterMatch == null) {
          Fluttertoast.showToast(msg: "Reciter not found");
          return;
        }

        final appDir = await getTemporaryDirectory();

        
        // Get total verses in the surah
        final totalVerses = getVerseCount(event.surahNumber);
        
        // Build playlist from individual verse files
        final List<AudioSource> audioSources = [];
        final Map<int, int> verseToIndexMap = {}; // Maps verse number to playlist index
        
        for (int verseNum = 1; verseNum <= totalVerses; verseNum++) {
          final verseFilePath = 
              '${appDir.path}/${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}-$verseNum.mp3';
          
          // Check if verse file exists
          if (File(verseFilePath).existsSync()) {
            verseToIndexMap[verseNum] = audioSources.length; // Track the index
            audioSources.add(
              AudioSource.file(
                verseFilePath,
                tag: MediaItem(
                  id: '${event.suraName}-$verseNum',
                  album: reciterMatch["englishName"],
                  title: '${getSurahNameArabic(event.surahNumber)} - ${tr("ayah")} $verseNum',
                  artUri: Uri.parse(
                      "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg"),
                ),
              ),
            );
          }
        }
        
        // Check if we have any audio files
        if (audioSources.isEmpty) {
          Fluttertoast.showToast(msg: "No audio files found. Please download first.");
          return;
        }
        
        // Find the correct index for the requested verse
        int startIndex = verseToIndexMap[event.verse] ?? 0;
        if (startIndex < 0 || startIndex >= audioSources.length) {
          startIndex = 0; // Fallback to first available verse
        }

        // Configure audio session
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        // Listen for playback errors
        audioPlayer!.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          Fluttertoast.showToast(msg: "Playback error: $e");
        });

        try {
          // Create playlist and set initial index to the verse we want to start from
          await audioPlayer!.setAudioSource(
            ConcatenatingAudioSource(children: audioSources),
            initialIndex: startIndex,
          );
        } catch (e) {
          Fluttertoast.showToast(msg: "Error loading audio: $e");
          return;
        }

        // Start playback
        audioPlayer!.play();

        Fluttertoast.showToast(msg: "Start Playing");

        emit(QuranPagePlayerPlaying(
          player: audioPlayer!,
          audioPlayerStream: audioPlayer!.positionStream,
          suraNumber: event.surahNumber,
          reciter: reciterMatch,
          durations: [], // No longer needed with playlist approach
        ));


      } else if (event is StopPlaying) {
        if (audioPlayer != null) {
          await audioPlayer!.stop();
        }
        emit(QuranPagePlayerInitial());

      } else if (event is KillPlayerEvent) {
        if (audioPlayer != null) {
          await audioPlayer!.stop();
          // audioPlayer = null;
        }
        emit(QuranPagePlayerInitial());
      }
    });
  }
}
