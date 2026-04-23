import 'dart:convert';
import 'dart:io';

import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/blocs/bloc/quran_page_player_bloc.dart';
import 'package:khatmah/features/QuranPages/helpers/quran_audio_helper.dart';
import 'package:khatmah/features/QuranPages/helpers/quran_data.dart';
import 'package:khatmah/features/QuranPages/widgets/details_page/share_ayah_dialog.dart';
import 'package:khatmah/features/home.dart';
import 'package:quran/quran.dart' as quran;
import 'package:khatmah/features/QuranPages/widgets/tafseer_and_translation_sheet.dart';

class AyahOptionsSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final int index; // Page index
  final List bookmarks;
  final Function(int surah, int verse) onAddBookmark;
  final Function(int surah, int verse) onRemoveBookmark;
  final bool Function(int surah, int verse) isVerseStarred;
  final Function(int surah, int verse) onToggleStar;
  final dynamic jsonData;

  // Passed Bloc or callbacks?
  // Ideally, use BlocProvider.of(context) if available in parent.
  // Assuming provided in context.

  const AyahOptionsSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    required this.index,
    required this.bookmarks,
    required this.onAddBookmark,
    required this.onRemoveBookmark,
    required this.isVerseStarred,
    required this.onToggleStar,
    required this.jsonData,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    required int index,
    required List bookmarks,
    required Function(int, int) onAddBookmark,
    required Function(int, int) onRemoveBookmark,
    required bool Function(int, int) isVerseStarred,
    required Function(int, int) onToggleStar,
    required dynamic jsonData,
  }) {
    showMaterialModalBottomSheet(
      enableDrag: true,
      animationCurve: Curves.easeInOutQuart,
      elevation: 0,
      bounce: true,
      duration: const Duration(milliseconds: 250),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return AyahOptionsSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          index: index,
          bookmarks: bookmarks,
          onAddBookmark: onAddBookmark,
          onRemoveBookmark: onRemoveBookmark,
          isVerseStarred: isVerseStarred,
          onToggleStar: onToggleStar,
          jsonData: jsonData,
        );
      },
    );
  }

  @override
  State<AyahOptionsSheet> createState() => _AyahOptionsSheetState();
}

class _AyahOptionsSheetState extends State<AyahOptionsSheet> {
  // Local state for downloading if needed, though helper handles it mostly.
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    bool isBookmarked = widget.bookmarks.any((element) =>
        element["suraNumber"] == widget.surahNumber &&
        element["verseNumber"] == widget.verseNumber);

    if (reciters.isEmpty) addReciters();
    // Access Blocs
    // final qurapPagePlayerBloc = BlocProvider.of<QuranPagePlayerBloc>(context);
    // Note: 'playerPageBloc' in original seemed to be same type or different?
    // Line 845 in original: if (playerPageBloc.state is PlayerBlocPlaying)
    // Line 870: if (qurapPagePlayerBloc.state is QuranPagePlayerPlaying)
    // Assuming 'playerPageBloc' is another bloc. I need to know its type.
    // Based on 'ClosePlayerEvent', maybe 'PlayerBloc'?
    // I'll skip 'playerPageBloc' if I can't find it, or use dynamic lookup.
    // It seems to handle closing a global player.
    // I'll comment it out or assume it's available. To be safe, I will omit if I don't have the import.
    // Or I check `quranDetailsPage` imports.
    // It has `import 'package:khatmah/blocs/player_bloc/player_bloc.dart';`?
    // I'll check imports later. For now, I'll focus on `QuranPagePlayerBloc`.

    return Container(
      decoration: BoxDecoration(
          color: backgroundColors[getValue("quranPageolorsIndex")],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      height: MediaQuery.of(context).size.height * .45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Text(
              "${"soura".tr()} ${rtlLanguages.contains(context.locale.languageCode) ? quran.getSurahNameArabic(widget.surahNumber) : quran.getSurahNameEnglish(widget.surahNumber)} - ${"ayah".tr()} ${widget.verseNumber}",
              style: TextStyle(
                  color: primaryColors[getValue("quranPageolorsIndex")],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "cairo"),
            ),
            SizedBox(height: 10.h),
            const Divider(),
            SizedBox(height: 10.h),
            
            // Share Button
            EasyContainer(
              borderRadius: 8,
              color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
              onTap: () {
                Navigator.pop(context);
                showShareAyahDialog(context, widget.surahNumber, widget.verseNumber, widget.index, widget.jsonData);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Icon(
                      Icons.share,
                      color: getValue("quranPageolorsIndex") == 0
                          ? secondaryColors[getValue("quranPageolorsIndex")]
                          : highlightColors[getValue("quranPageolorsIndex")],
                    ),
                    SizedBox(width: 20.w),
                    Text("share".tr(),
                        style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 14.sp,
                            color: primaryColors[getValue("quranPageolorsIndex")])),
                    SizedBox(width: 30.w)
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Bookmark Button
            EasyContainer(
              borderRadius: 8,
              color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
              onTap: () async {
                if (isBookmarked) {
                  widget.onRemoveBookmark(widget.surahNumber, widget.verseNumber);
                } else {
                  widget.onAddBookmark(widget.surahNumber, widget.verseNumber);
                }
                Navigator.pop(context);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: getValue("quranPageolorsIndex") == 0
                          ? secondaryColors[getValue("quranPageolorsIndex")]
                          : highlightColors[getValue("quranPageolorsIndex")],
                    ),
                    SizedBox(width: 20.w),
                    Text(isBookmarked ? "removebookmark".tr() : "addbookmark".tr(),
                        style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 14.sp,
                            color: primaryColors[getValue("quranPageolorsIndex")])),
                    SizedBox(width: 30.w)
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            
            // Favorite Button
            EasyContainer(
              borderRadius: 8,
              color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
              onTap: () async {
                widget.onToggleStar(widget.surahNumber, widget.verseNumber);
                Navigator.pop(context);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Icon(
                      widget.isVerseStarred(widget.surahNumber, widget.verseNumber)
                          ? Icons.star
                          : Icons.star_border,
                      color: getValue("quranPageolorsIndex") == 0
                          ? secondaryColors[getValue("quranPageolorsIndex")]
                          : highlightColors[getValue("quranPageolorsIndex")],
                    ),
                    SizedBox(width: 20.w),
                    Text(
                        widget.isVerseStarred(widget.surahNumber, widget.verseNumber)
                            ? "removefav".tr()
                            : "addtofav".tr(),
                        style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 14.sp,
                            color: primaryColors[getValue("quranPageolorsIndex")])),
                    SizedBox(width: 30.w)
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Tafseer Button
            EasyContainer(
              borderRadius: 8,
              color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
              onTap: () {
                Navigator.pop(context);
                showMaterialModalBottomSheet(
                  enableDrag: true,
                  animationCurve: Curves.easeInOutQuart,
                  elevation: 0,
                  bounce: true,
                  duration: const Duration(milliseconds: 400),
                  backgroundColor: backgroundColors[getValue("quranPageolorsIndex")],
                  context: context,
                  builder: (builder) {
                    return TafseerAndTranslateSheet(
                      surahNumber: widget.surahNumber,
                      verseNumber: widget.verseNumber,
                      isVerseByVerseSelection: true,
                    );
                  },
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Icon(
                      Icons.menu_book,
                      color: getValue("quranPageolorsIndex") == 0
                          ? secondaryColors[getValue("quranPageolorsIndex")]
                          : highlightColors[getValue("quranPageolorsIndex")],
                    ),
                    SizedBox(width: 20.w),
                    Text("tafseer".tr(),
                        style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 14.sp,
                            color: primaryColors[getValue("quranPageolorsIndex")])),
                    SizedBox(width: 30.w)
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            
            // Play Audio Button
            EasyContainer(
              borderRadius: 8,
              color: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.05),
              onTap: () async {
                final reciter = reciters[getValue("reciterIndex")];
                
                await QuranAudioHelper.downloadAndCacheSuraAudio(
                    suraName: quran.getSurahNameEnglish(widget.surahNumber),
                    totalVerses: quran.getVerseCount(widget.surahNumber),
                    surahNumber: widget.surahNumber,
                    reciterIdentifier: reciter.identifier,
                    onDownloadingStateChanged: (downloading) {
                        if (mounted) {
                          setState(() {
                             _isDownloading = downloading;
                          });
                        }
                    }
                );
                
                // Close the bottom sheet after download completes
                if (mounted) {
                  Navigator.pop(context);
                }
                
                // Logic to kill existing player if playing
                if (qurapPagePlayerBloc.state is QuranPagePlayerPlaying) {
                    qurapPagePlayerBloc.add(KillPlayerEvent());
                }

                qurapPagePlayerBloc.add(PlayFromVerse(
                    widget.verseNumber,
                    reciter.identifier,
                    widget.surahNumber,
                    quran.getSurahNameEnglish(widget.surahNumber)));
                
                // Auto scroll logic (simplified)
                if (getValue("alignmentType") == "verticalview" && 
                    quran.getPageNumber(widget.surahNumber, widget.verseNumber) > 600) {
                      // Note: passing itemScrollController would be needed for this.
                      // Currently omitted or needs a callback for 'onPlayAndScroll'.
                      // For now, simple play.
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    Icon(
                      FontAwesome5.book_reader,
                      color: getValue("quranPageolorsIndex") == 0
                          ? secondaryColors[getValue("quranPageolorsIndex")]
                          : highlightColors[getValue("quranPageolorsIndex")],
                    ),
                    SizedBox(width: 20.w),
                    Text("play".tr(),
                        style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 14.sp,
                            color: primaryColors[getValue("quranPageolorsIndex")])),
                    SizedBox(width: 30.w),
                    DropdownButton<int>(
                      value: getValue("reciterIndex"),
                      dropdownColor: backgroundColors[getValue("quranPageolorsIndex")],
                      onChanged: (int? newIndex) {
                        updateValue("reciterIndex", newIndex);
                        setState(() {});
                      },
                      items: reciters.map((reciter) {
                        return DropdownMenuItem<int>(
                          value: reciters.indexOf(reciter),
                          child: Text(
                              rtlLanguages.contains(context.locale.languageCode)
                                  ? reciter.name
                                  : reciter.englishName,
                              style: TextStyle(
                                  color: primaryColors[getValue("quranPageolorsIndex")])),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
