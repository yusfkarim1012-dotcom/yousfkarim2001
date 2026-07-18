import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/features/home.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/blocs/bloc/quran_page_player_bloc.dart';
import 'package:khatmah/features/QuranPages/helpers/convertNumberToAr.dart';
import 'package:khatmah/features/QuranPages/widgets/bismallah.dart';
import 'package:khatmah/features/QuranPages/widgets/header_widget.dart';
import 'package:khatmah/features/QuranPages/widgets/details_page/quran_page_header.dart';
import 'package:quran/quran.dart' as quran;

const Map<String, Map<String, String>> navTranslations = {
  'ar': {'prev': 'السابق', 'next': 'التالي', 'back': 'خروج'},
  'en': {'prev': 'Prev', 'next': 'Next', 'back': 'Back'},
  'ku': {'prev': 'پێشوو', 'next': 'داهاتوو', 'back': 'گەڕانەوە'},
  'tr': {'prev': 'Geri', 'next': 'İleri', 'back': 'Çıkış'},
  'fr': {'prev': 'Préc.', 'next': 'Suiv.', 'back': 'Retour'},
  'de': {'prev': 'Zurück', 'next': 'Weiter', 'back': 'Beenden'},
  'id': {'prev': 'Sebelum', 'next': 'Berikut', 'back': 'Kembali'},
  'ms': {'prev': 'Sebelum', 'next': 'Seterus', 'back': 'Kembali'},
  'pt': {'prev': 'Anter.', 'next': 'Próx.', 'back': 'Voltar'},
  'ru': {'prev': 'Назад', 'next': 'Далее', 'back': 'Выход'},
  'ur': {'prev': 'پچھلا', 'next': 'اگلا', 'back': 'واپس'},
  'bn': {'prev': 'আগে', 'next': 'পরে', 'back': 'ফিরে'},
  'es': {'prev': 'Ant.', 'next': 'Sig.', 'back': 'Salir'},
  'zh': {'prev': '上页', 'next': '下页', 'back': '返回'},
  'hi': {'prev': 'पिछला', 'next': 'अगला', 'back': 'वापस'},
  'am': {'prev': 'ቀደመ', 'next': 'ቀጥለ', 'back': 'ተመለስ'},
  'sw': {'prev': 'Iliyo', 'next': 'Inayo', 'back': 'Rudi'},
  'ha': {'prev': 'Baya', 'next': 'Gaba', 'back': 'Koma'},
  'yo': {'prev': 'Ìwájú', 'next': 'Ẹ̀yìn', 'back': 'Padà'},
  'vi': {'prev': 'Trước', 'next': 'Sau', 'back': 'Quay lại'},
  'tl': {'prev': 'Naka.', 'next': 'Sunod', 'back': 'Bumalik'},
};

String _navText(String key, BuildContext ctx) {
  final lc = ctx.locale.languageCode;
  return navTranslations[lc]?[key] ?? navTranslations['ar']?[key] ?? key;
}

class QuranPageView extends StatefulWidget {
  final PageController pageController;
  final Function(int) onPageChanged;
  final Function() onBack;
  final Function() onSettings;
  final Function(int, int, int) onShowAyahOptions;
  final List bookmarks;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final bool shouldHighlightText;
  final dynamic highlightVerse;
  final int index;

  const QuranPageView({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
    required this.onBack,
    required this.onSettings,
    required this.onShowAyahOptions,
    required this.bookmarks,
    required this.jsonData,
    required this.quarterJsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
    required this.index,
  }) : super(key: key);

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  String selectedSpan = "";
  List<GlobalKey> richTextKeys = List.generate(604, (_) => GlobalKey());
  bool _showNav = true;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.pageController.position.isScrollingNotifier.value && selectedSpan.isNotEmpty) {
      setState(() => selectedSpan = "");
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onScroll);
    super.dispose();
  }

  Color get _bgColor => backgroundColors[getValue("quranPageolorsIndex")];
  Color get _txtColor => primaryColors[getValue("quranPageolorsIndex")];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showNav = !_showNav),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Column(
          children: [
            // Header
            SafeArea(
              bottom: false,
              child: QuranPageHeader(
                index: widget.index,
                jsonData: widget.jsonData,
                quarterJsonData: widget.quarterJsonData,
                onBack: widget.onBack,
                onSettings: widget.onSettings,
              ),
            ),
            // Quran content - full page, no scroll
            Expanded(
              child: PageView.builder(
                allowImplicitScrolling: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (a) {
                  setState(() => selectedSpan = "");
                  widget.onPageChanged(a);
                },
                controller: widget.pageController,
                reverse: !rtlLanguages.contains(context.locale.languageCode),
                itemCount: quran.totalPagesCount + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      color: const Color(0xffFFFCE7),
                      child: Image.asset("assets/images/quran.jpg", fit: BoxFit.fill),
                    );
                  }
                  return _buildPage(index);
                },
              ),
            ),
            // Bottom navigation bar
            if (_showNav) _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
      bloc: qurapPagePlayerBloc,
      builder: (context, state) {
        bool isIdle = state is QuranPagePlayerInitial || state is QuranPagePlayerIdle;
        bool isPlaying = state is QuranPagePlayerPlaying;

        if (!isIdle && !isPlaying) return Container();

        return Directionality(
          textDirection: m.TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SizedBox(
              width: double.infinity,
              child: RichText(
                key: richTextKeys[index - 1],
                textDirection: m.TextDirection.rtl,
                textAlign: TextAlign.center,
                softWrap: true,
                locale: const Locale("ar"),
                text: TextSpan(
                  style: TextStyle(
                    color: _txtColor,
                    fontSize: getValue("pageViewFontSize").toDouble(),
                    fontFamily: getValue("selectedFontFamily"),
                  ),
                  locale: const Locale("ar"),
                  children: quran.getPageData(index).expand((e) {
                    List<InlineSpan> spans = [];
                    for (var i = e["start"]; i <= e["end"]; i++) {
                      if (i == 1) {
                        spans.add(WidgetSpan(child: HeaderWidget(e: e, jsonData: widget.jsonData)));
                        if (index != 187 && index != 1) {
                          spans.add(WidgetSpan(child: Basmallah(index: getValue("quranPageolorsIndex"))));
                        }
                        if (index == 187) {
                          spans.add(WidgetSpan(child: SizedBox(height: 10.h)));
                        }
                      }

                      bool isBookmarked = widget.bookmarks.any(
                          (el) => el["suraNumber"] == e["surah"] && el["verseNumber"] == i);
                      String bmColor = isBookmarked
                          ? widget.bookmarks
                              .firstWhere((el) => el["suraNumber"] == e["surah"] && el["verseNumber"] == i)["color"]
                          : "";

                      spans.add(TextSpan(
                        locale: const Locale("ar"),
                        recognizer: LongPressGestureRecognizer()
                          ..onLongPress = () { widget.onShowAyahOptions(index, e["surah"], i); }
                          ..onLongPressDown = (_) { setState(() { selectedSpan = " ${e["surah"]}$i"; }); }
                          ..onLongPressUp = () { setState(() { selectedSpan = ""; }); }
                          ..onLongPressCancel = () { setState(() { selectedSpan = ""; }); },
                        text: isIdle
                            ? (i == e["start"]
                                ? "${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                                : quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''))
                            : quran.getVerseQCF(e["surah"], i).replaceAll(' ', ''),
                        style: TextStyle(
                          color: isBookmarked ? Color(int.parse("0x$bmColor")) : _txtColor,
                          height: (index == 1 || index == 2) ? 2.h : 1.95.h,
                          letterSpacing: 0.w,
                          wordSpacing: 0,
                          fontFamily: "QCF_P${index.toString().padLeft(3, "0")}",
                          fontSize: index == 1 || index == 2
                              ? 28.sp
                              : (index == 145 || index == 201)
                                  ? (index == 532 || index == 533 ? 22.5.sp : 22.4.sp)
                                  : 22.9.sp,
                          backgroundColor: isBookmarked
                              ? Color(int.parse("0x$bmColor")).withOpacity(.19)
                              : widget.shouldHighlightText
                                  ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                      : selectedSpan == " ${e["surah"]}$i"
                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                          : Colors.transparent
                                  : selectedSpan == " ${e["surah"]}$i"
                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                      : Colors.transparent,
                        ),
                        children: const [],
                      ));

                      if (isBookmarked) {
                        spans.add(WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.bookmark, color: Color(int.parse("0x$bmColor")), size: 14.sp),
                        ));
                      }
                    }
                    return spans;
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
          top: BorderSide(color: _txtColor.withOpacity(0.15), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            _navBtn(
              icon: Icons.arrow_forward_ios,
              label: _navText('back', ctx),
              onTap: () => widget.onBack(),
            ),
            // Vertical buttons (swipe up / down)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.pageController.hasClients && (widget.pageController.page ?? 0) > 0) {
                      widget.pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _txtColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.keyboard_arrow_up, color: _txtColor, size: 20.sp),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _txtColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _txtColor.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    "${widget.index} / ${quran.totalPagesCount}",
                    style: TextStyle(color: _txtColor, fontSize: 10.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () {
                    if (widget.pageController.hasClients &&
                        (widget.pageController.page ?? 0) < quran.totalPagesCount) {
                      widget.pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _txtColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.keyboard_arrow_down, color: _txtColor, size: 20.sp),
                  ),
                ),
              ],
            ),
            // Horizontal buttons (prev / next)
            _navBtn(
              icon: Icons.chevron_right,
              label: _navText('prev', ctx),
              onTap: () {
                if (widget.pageController.hasClients && (widget.pageController.page ?? 0) > 0) {
                  widget.pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                }
              },
            ),
            _navBtn(
              icon: Icons.chevron_left,
              label: _navText('next', ctx),
              onTap: () {
                if (widget.pageController.hasClients &&
                    (widget.pageController.page ?? 0) < quran.totalPagesCount) {
                  widget.pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                }
              },
            ),
            // Settings
            _navBtn(
              icon: Icons.settings,
              label: '',
              onTap: () => widget.onSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _txtColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            if (label.isNotEmpty) ...[
              SizedBox(width: 3.w),
              Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
