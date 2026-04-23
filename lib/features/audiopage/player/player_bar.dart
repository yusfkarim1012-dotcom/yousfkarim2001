import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:khatmah/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:khatmah/blocs/bloc/player_bloc_bloc.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/home.dart';

import 'package:quran/quran.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  @override
  void initState() {
    addFavorites();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isMinimized) {
      return false;
    } else {
      BlocProvider.of<PlayerBarBloc>(context).add(MinimizeBarEvent());
      isMinimized = true;
    }
    return true;
  }

  List favoriteSurahList = [];
  addFavorites() {
    favoriteSurahList = json.decode(getValue("favoriteSurahList") ?? "[]");
    setState(() {});
  }

  final appDir = Directory(kDownloadPath);
  bool isPlaylistShown = false;
  bool isMinimized = true;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Directionality(
        textDirection: m.TextDirection.ltr,
        child: BlocBuilder(
          bloc: playerPageBloc,
          builder: (context, state) {
            if (state is PlayerBlocPlaying) {
              return BlocBuilder<PlayerBarBloc, PlayerBarState>(
                bloc: BlocProvider.of<PlayerBarBloc>(context),
                builder: (context, statee) {
                  if (statee is PlayerBarHidden) {
                    return Positioned(
                        bottom: 25.h,
                        right: 25.w,
                        child: FadeInRight(
                          child: FadeInUp(
                            child: StreamBuilder(
                                stream: state.audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Opacity(
                                      opacity: .5,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: SpinPerfect(
                                          infinite: true,
                                          duration: const Duration(seconds: 7),
                                          animate: snapshot.data!.playing,
                                          child: GestureDetector(
                                            onTap: () {
                                              BlocProvider.of<PlayerBarBloc>(context).add(ShowBarEvent());
                                            },
                                            child: Container(
                                              height: 45.h,
                                              width: 45.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
                                              ),
                                              child: Center(
                                                child: CircleAvatar(
                                                  backgroundColor: getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
                                                  backgroundImage: const AssetImage("assets/images/quran.png"),
                                                  foregroundImage: CachedNetworkImageProvider(
                                                    "${getValue("${state.reciter.name} photo url")}",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                          ),
                        ));
                  } else if (statee is PlayerBarVisible) {
                    isMinimized = statee.height == 60;
                    
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: isMinimized ? (MediaQuery.of(context).padding.bottom + 10.h) : 0,
                      left: isMinimized ? 10.w : 0,
                      right: isMinimized ? 10.w : 0,
                      top: isMinimized ? (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.bottom + 10.h + 70.h)) : 0,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              if (isMinimized) {
                                BlocProvider.of<PlayerBarBloc>(context).add(ExtendBarEvent());
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                  gradient: isMinimized
                                      ? LinearGradient(
                                          colors: [blueColor, blueColor.withOpacity(0.8)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isMinimized ? null : darkPrimaryColor,
                                  borderRadius: BorderRadius.circular(isMinimized ? 15.r : 0),
                                  boxShadow: isMinimized ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ] : null),
                              child: isMinimized
                                  ? _buildMinimizedBar(state)
                                  : _buildExtendedPlayer(state),
                            ),
                          ),
                        ),
                      ),
                    );

                  } else if (statee is PlayerBarClosed) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox.shrink();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMinimizedBar(PlayerBlocPlaying state) {
    return StreamBuilder<SequenceState?>(
      stream: state.audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final statee = snapshot.data;
        if (statee == null || statee.sequence.isEmpty) return const SizedBox();
        final metadata = statee.currentSource!.tag as MediaItem;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.w),
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundImage: const AssetImage("assets/images/quran.png"),
                  foregroundImage: getValue("${state.reciter.name} photo url") != null
                      ? CachedNetworkImageProvider(getValue("${state.reciter.name} photo url"))
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo'),
                    ),
                    Text(
                      state.reciter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontFamily: 'cairo'),
                    ),
                  ],
                ),
              ),
              StreamBuilder<PlayerState>(
                stream: state.audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final playing = playerState?.playing;
                  return IconButton(
                    icon: Icon(playing == true ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28.sp),
                    onPressed: () => playing == true ? state.audioPlayer.pause() : state.audioPlayer.play(),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.white70, size: 20.sp),
                onPressed: () {
                  state.audioPlayer.stop();
                  BlocProvider.of<PlayerBarBloc>(context).add(CloseBarEvent());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtendedPlayer(PlayerBlocPlaying state) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            opacity: 0.15,
            image: AssetImage("assets/images/framee.png"),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => BlocProvider.of<PlayerBarBloc>(context).add(MinimizeBarEvent()),
                    icon: Icon(LineariconsFree.chevron_down, size: 30.sp, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => setState(() => isPlaylistShown = !isPlaylistShown),
                    icon: Icon(Icons.playlist_play_rounded, size: 35.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isPlaylistShown ? _buildPlaylist(state) : _buildMainPlayerContent(state),
            ),
            if (!isPlaylistShown)
              Padding(
                padding: EdgeInsets.only(bottom: 30.h, left: 50.w, right: 50.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFavoriteButton(state),
                    _buildDownloadButton(state),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPlayerContent(PlayerBlocPlaying state) {
    return StreamBuilder<SequenceState?>(
      stream: state.audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final stateData = snapshot.data;
        if (stateData == null || stateData.sequence.isEmpty) return const SizedBox();
        final metadata = stateData.currentSource!.tag as MediaItem;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(metadata.title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            Text(state.reciter.name, style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontFamily: 'cairo')),
            SizedBox(height: 20.h),
            SizedBox(
              height: 220.h,
              width: 220.h,
              child: Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12, width: 3.w),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)],
                ),
                child: ClipOval(
                  child: Builder(
                    builder: (ctx) {
                      try {
                        String? url = getValue("${state.reciter.name} photo url");
                        if (url != null && url.isNotEmpty) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset("assets/images/quran.png", fit: BoxFit.cover),
                            errorWidget: (context, url, error) => Image.asset("assets/images/quran.png", fit: BoxFit.cover),
                          );
                        } else {
                          return Image.asset("assets/images/quran.png", fit: BoxFit.cover);
                        }
                      } catch (e) {
                        return Image.asset("assets/images/quran.png", fit: BoxFit.cover);
                      }
                    }
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            ControlButtons(state.audioPlayer),
            SizedBox(height: 20.h),
            _buildProgressSlider(state.audioPlayer),
          ],
        );
      },
    );
  }

  Widget _buildProgressSlider(AudioPlayer player) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }
        if (progress < 0) progress = 0.0;
        if (progress > 1) progress = 1.0;

        return SizedBox(
          height: 100.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        double percent = details.localPosition.dx / constraints.maxWidth;
                        if (percent < 0) percent = 0.0;
                        if (percent > 1) percent = 1.0;
                        try {
                          player.seek(Duration(milliseconds: (duration.inMilliseconds * percent).toInt()));
                        } catch(e){}
                      },
                      onTapDown: (details) {
                        double percent = details.localPosition.dx / constraints.maxWidth;
                        if (percent < 0) percent = 0.0;
                        if (percent > 1) percent = 1.0;
                        try {
                          player.seek(Duration(milliseconds: (duration.inMilliseconds * percent).toInt()));
                        } catch(e){}
                      },
                      child: Container(
                        height: 20.h, // Larger hit area
                        alignment: Alignment.center,
                        child: Container(
                          height: 4.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2.h),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2.h),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(position), style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                      Text(formatDuration(duration), style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(PlayerBlocPlaying state) {
    final surahId = "${state.reciter.name}${state.moshaf.name}${state.audioPlayer.currentIndex! + 1}".trim();
    final isFav = favoriteSurahList.contains(surahId);
    return IconButton(
      onPressed: () {
        setState(() {
          if (isFav) favoriteSurahList.remove(surahId);
          else favoriteSurahList.add(surahId);
          updateValue("favoriteSurahList", json.encode(favoriteSurahList));
        });
      },
      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 32.sp),
    );
  }

  Widget _buildDownloadButton(PlayerBlocPlaying state) {
    final fileName = "${state.moshaf.id}-${getSurahNameArabic(int.parse(state.surahNumbers[state.audioPlayer.currentIndex!]))}.mp3";
    final file = File("${kDownloadPath}${state.reciter.name}/$fileName");
    final exists = file.existsSync();

    return IconButton(
      onPressed: () {
        if (!exists) {
          playerPageBloc.add(DownloadSurah(
            reciter: state.reciter,
            moshaf: state.moshaf,
            suraNumber: state.surahNumbers[state.audioPlayer.currentIndex!],
            url: "${state.moshaf.server}/${state.surahNumbers[state.audioPlayer.currentIndex!].padLeft(3, "0")}.mp3",
          ));
          Future.delayed(const Duration(seconds: 2), () => setState(() {}));
        }
      },
      icon: Icon(exists ? Icons.download_done : Icons.download, 
                 color: exists ? Colors.white.withOpacity(0.4) : Colors.white, 
                 size: 32.sp),
    );
  }

  Widget _buildPlaylist(PlayerBlocPlaying state) {
    return StreamBuilder<SequenceState?>(
      stream: state.audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final sequenceState = snapshot.data;
        if (sequenceState == null) return const SizedBox();
        final sequence = sequenceState.sequence;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15.sp),
              child: Text("قائمة التشغيل", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sequence.length,
                itemBuilder: (context, i) {
                  final metadata = sequence[i].tag as MediaItem;
                  final isCurrent = i == sequenceState.currentIndex;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.white12 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      title: Text(metadata.title, textDirection: m.TextDirection.rtl, style: TextStyle(color: isCurrent ? Colors.white : Colors.white70, fontSize: 16.sp, fontFamily: 'cairo')),
                      trailing: isCurrent ? Icon(Icons.volume_up, color: Colors.white, size: 20.sp) : null,
                      onTap: () => state.audioPlayer.seek(Duration.zero, index: i),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            final loopMode = snapshot.data ?? LoopMode.off;
            Icon icon;
            switch (loopMode) {
              case LoopMode.off:
                icon = Icon(Icons.repeat, color: Colors.white.withOpacity(0.3), size: 28.sp);
                break;
              case LoopMode.one:
                icon = Icon(Icons.repeat_one, color: Colors.white, size: 28.sp);
                break;
              case LoopMode.all:
                icon = Icon(Icons.repeat, color: Colors.white, size: 28.sp);
                break;
            }
            return IconButton(
              icon: icon,
              onPressed: () {
                final nextMode = loopMode == LoopMode.off 
                  ? LoopMode.all 
                  : (loopMode == LoopMode.all ? LoopMode.one : LoopMode.off);
                player.setLoopMode(nextMode);
              },
            );
          },
        ),
        SizedBox(width: 8.w),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ?? Duration.zero;
            return IconButton(
              onPressed: () => player.seek(Duration(seconds: positionData.inSeconds - 10)),
              icon: Icon(Icons.fast_rewind, color: Colors.white, size: 32.sp),
            );
          },
        ),
        SizedBox(width: 8.w),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: Icon(Icons.skip_previous, color: Colors.white, size: 32.sp),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        SizedBox(width: 8.w),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return Container(margin: const EdgeInsets.all(8.0), width: 32.0.w, height: 32.h, child: const CircularProgressIndicator(color: Colors.white));
            } else if (playing != true) {
              return IconButton(icon: const Icon(Icons.play_arrow), iconSize: 40.sp, color: Colors.white, onPressed: player.play);
            } else if (processingState != ProcessingState.completed) {
              return IconButton(icon: const Icon(Icons.pause), iconSize: 40.sp, color: Colors.white, onPressed: player.pause);
            } else {
              return IconButton(icon: const Icon(Icons.replay), iconSize: 40.sp, color: Colors.white, onPressed: () => player.seek(Duration.zero, index: player.effectiveIndices!.first));
            }
          },
        ),
        SizedBox(width: 8.w),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: Icon(Icons.skip_next, color: Colors.white, size: 32.sp),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        SizedBox(width: 8.w),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ?? Duration.zero;
            return IconButton(
              onPressed: () => player.seek(Duration(seconds: positionData.inSeconds + 10)),
              icon: Icon(Icons.fast_forward, color: Colors.white, size: 32.sp),
            );
          },
        ),
        SizedBox(width: 8.w),
        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            final shuffleModeEnabled = snapshot.data ?? false;
            return IconButton(
              icon: Icon(
                Icons.shuffle,
                color: shuffleModeEnabled ? Colors.white : Colors.white.withOpacity(0.3),
                size: 28.sp,
              ),
              onPressed: () async {
                if (!shuffleModeEnabled) {
                  await player.shuffle();
                }
                await player.setShuffleModeEnabled(!shuffleModeEnabled);
              },
            );
          },
        ),
      ],
    );
  }
}

String formatDuration(Duration duration, {bool includeHours = true}) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);
  if (hours > 0 || includeHours) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
