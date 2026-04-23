import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/QuranPages/helpers/quran_page_utils.dart';
import 'package:quran/quran.dart';

class QuranPageHeader extends StatelessWidget {
  final int index;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const QuranPageHeader({
    Key? key,
    required this.index,
    required this.jsonData,
    required this.quarterJsonData,
    required this.onBack,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final pageData = getPageData(index);
    final surahNumber = pageData[0]["surah"];
    final surahName = jsonData[surahNumber - 1]["name"];
    final colorIndex = getValue("quranPageolorsIndex") ?? 0;
    final isDarkMode = getValue("darkMode") == true;

    // Use white color for elements if in dark mode or if the current background color is dark
    final Color bgColor = backgroundColors[colorIndex];
    final bool isDarkTheme = bgColor.computeLuminance() < 0.3 || isDarkMode;
    final Color elementsColor = isDarkTheme ? Colors.white : secondaryColors[colorIndex];

    return SizedBox(
      width: screenSize.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: (screenSize.width * .27).w,
            child: Row(
              children: [
                IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24.sp,
                      color: elementsColor,
                    )),
                Text(surahName,
                    style: TextStyle(
                        color: elementsColor,
                        fontFamily: "Taha",
                        fontSize: 14.sp)),
              ],
            ),
          ),
          SizedBox(
            width: (screenSize.width * .32).w,
            child: Center(
              child: Stack(
                children: [
                  _buildPageInfoChunk(index, pageData, colorIndex, isDarkTheme),
                ],
              ),
            ),
          ),
          SizedBox(
            width: (screenSize.width * .27).w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: onSettings,
                    icon: Icon(
                      Icons.settings,
                      size: 24.sp,
                      color: elementsColor,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPageInfoChunk(int index, dynamic pageData, int colorIndex, bool isDarkTheme) {
    final result = QuranPageUtils.checkIfPageIncludesQuarterAndQuarterIndex(
        quarterJsonData, pageData, indexes);
    
    final Color chunkBgColor = secondaryColors[colorIndex].withOpacity(.5);
    // If background is dark, use white text for contrast, otherwise use backgroundColors[colorIndex]
    final Color chunkTextColor = (chunkBgColor.computeLuminance() < 0.4 || isDarkTheme) 
        ? Colors.white 
        : backgroundColors[colorIndex];

    if (result.includesQuarter) {
      return EasyContainer(
        borderRadius: 12.r,
        color: chunkBgColor,
        borderColor: isDarkTheme ? Colors.white24 : primaryColors[colorIndex],
        showBorder: true,
        height: 20.h,
        width: 160.w,
        padding: 0,
        margin: 0,
        child: Text(
          result.includesQuarter == true
              ? "${"page".tr()} ${(index).toString()} | ${(result.quarterIndex + 1) == 1 ? "" : "${(result.quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(result.hizbIndex + 1).toString()} | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])} "
              : "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
          style: TextStyle(
            fontFamily: 'aldahabi',
            fontSize: 10.sp,
            color: chunkTextColor,
          ),
        ),
      );
    } else {
      return EasyContainer(
        borderRadius: 12.r,
        color: chunkBgColor,
        borderColor: isDarkTheme ? Colors.white24 : backgroundColors[colorIndex],
        showBorder: true,
        height: 20.h,
        width: 120.w,
        padding: 0,
        margin: 0,
        child: Center(
          child: Text(
            "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
            style: TextStyle(
              fontFamily: 'aldahabi',
              fontSize: 12.sp,
              color: chunkTextColor,
            ),
          ),
        ),
      );
    }
  }
}
