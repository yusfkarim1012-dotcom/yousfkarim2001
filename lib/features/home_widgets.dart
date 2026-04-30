import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

// Import for specific widgets used in Grid
import 'package:flutter_svg/flutter_svg.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:iconsax/iconsax.dart';

// --- Home Header (no title, just controls) ---
class HomeHeader extends StatelessWidget {
  final Size screenSize;
  final VoidCallback onDarkModeToggle;
  final Function(Locale) onLanguageChanged;

  const HomeHeader({
    Key? key,
    required this.screenSize,
    required this.onDarkModeToggle,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dark/Light Mode Button
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: onDarkModeToggle,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? const Color(0xffF0E0C0) : const Color(0xff8B6914),
                size: 24.sp,
              ),
            ),
          ),
          
          // Language Selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: isDark ? const Color(0xffC5A053).withOpacity(0.2) : const Color(0xffD4C4A0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: context.locale,
                icon: Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.w),
                  child: Icon(Icons.language_rounded,
                      color: isDark ? const Color(0xffC5A053) : const Color(0xff8B6914), 
                      size: 20.sp),
                ),
                dropdownColor: isDark ? const Color(0xff2A2520) : const Color(0xffFFFDF7),
                borderRadius: BorderRadius.circular(15.r),
                onChanged: (Locale? newValue) {
                  if (newValue != null) onLanguageChanged(newValue);
                },
                items: [
                  const Locale("ar"),
                  const Locale('en'),
                  const Locale('de'),
                  const Locale("am"),
                  const Locale("ms"),
                  const Locale("pt"),
                  const Locale("tr"),
                  const Locale("ru"),
                  const Locale("jp")
                ].map<DropdownMenuItem<Locale>>((Locale locale) {
                  Map<String, String> languageNames = {
                    "ar": "العربية",
                    "en": "English",
                    "de": "Deutsch",
                    "am": "አማርኛ",
                    "ms": "Melayu",
                    "pt": "Português",
                    "tr": "Türkçe",
                    "ru": "Русский",
                    "jp": "日本語"
                  };
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(
                      languageNames[locale.languageCode] ??
                          locale.languageCode.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E),
                        fontFamily: "cairo",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Last Read Card ---
class LastReadCard extends StatelessWidget {
  final VoidCallback onTap;
  final String surahName;
  final int pageNumber;
  final int juzNumber;
  final bool isHalfWidth;

  const LastReadCard({
    Key? key,
    required this.onTap,
    required this.surahName,
    required this.pageNumber,
    required this.juzNumber,
    this.isHalfWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isHalfWidth ? 4.w : 16.w, vertical: 8.h),
        padding: EdgeInsets.all(isHalfWidth ? 14.w : 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xff2A2520), const Color(0xff1C1815)]
                : [Colors.white, const Color(0xffFFFDF7)],
          ),
          borderRadius: BorderRadius.circular(24.0.r),
          border: Border.all(
            color: isDark
                ? const Color(0xffC5A053).withOpacity(0.3)
                : const Color(0xffD4C4A0).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : const Color(0xff8B6914).withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -10.w,
              bottom: -10.h,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Iconsax.book_1,
                  size: isHalfWidth ? 60.sp : 80.sp,
                  color: const Color(0xffC5A053),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.book_saved,
                          color: const Color(0xffC5A053),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "lastRead".tr(),
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: isHalfWidth ? 12.sp : 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isHalfWidth ? 12.h : 18.h),
                Text(
                  surahName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "me",
                    fontSize: isHalfWidth ? 16.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xff2C1810),
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _InfoTag(
                      label: "${"juz".tr()} $juzNumber",
                      isDark: isDark,
                      fontSize: 9.sp,
                    ),
                    _InfoTag(
                      label: "${"page".tr()} $pageNumber",
                      isDark: isDark,
                      fontSize: 9.sp,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Bookmark Card ---
class BookmarkCard extends StatelessWidget {
  final VoidCallback onTap;
  final String surahName;
  final String bookmarkName;
  final int verseNumber;
  final bool isHalfWidth;

  const BookmarkCard({
    Key? key,
    required this.onTap,
    required this.surahName,
    required this.bookmarkName,
    required this.verseNumber,
    this.isHalfWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isHalfWidth ? 4.w : 16.w, vertical: 8.h),
        padding: EdgeInsets.all(isHalfWidth ? 14.w : 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xff1C2A20), const Color(0xff151C18)]
                : [const Color(0xffF7FFF7), Colors.white],
          ),
          borderRadius: BorderRadius.circular(24.0.r),
          border: Border.all(
            color: isDark
                ? const Color(0xff53C5A0).withOpacity(0.3)
                : const Color(0xffA0D4C4).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : const Color(0xff148B69).withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -10.w,
              bottom: -10.h,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.bookmark_added_rounded,
                  size: isHalfWidth ? 60.sp : 80.sp,
                  color: const Color(0xff53C5A0),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bookmark_rounded,
                          color: const Color(0xff53C5A0),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "addbookmark".tr(), // Or "Bookmarks"
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: isHalfWidth ? 12.sp : 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xffC0F0E0) : const Color(0xff1E5C4A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isHalfWidth ? 12.h : 18.h),
                Text(
                  surahName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "me",
                    fontSize: isHalfWidth ? 16.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xff102C18),
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _InfoTag(
                      label: bookmarkName.isNotEmpty ? bookmarkName : "${"ayah".tr()} $verseNumber",
                      isDark: isDark,
                      fontSize: 9.sp,
                      colorOverride: const Color(0xff53C5A0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final bool isDark;
  final double? fontSize;
  final Color? colorOverride;

  const _InfoTag({required this.label, required this.isDark, this.fontSize, this.colorOverride});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = colorOverride ?? const Color(0xffC5A053);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: "cairo",
          fontSize: fontSize ?? 11.sp,
          color: isDark ? primaryColor : primaryColor.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Daily Content Card (Verse/Hadith) ---
class DailyContentCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String content;
  final String subtitle;

  const DailyContentCard({
    Key? key,
    required this.onTap,
    required this.title,
    required this.content,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(18.0.w),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff2A2520).withOpacity(.95)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20.0.r),
          border: Border.all(
            color: isDark
                ? const Color(0xffC5A053).withOpacity(0.25)
                : const Color(0xffD4C4A0).withOpacity(0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : Colors.brown.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Iconsax.book_1, color: const Color(0xffC5A053)),
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: "cairo",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xffF0E0C0)
                          : const Color(0xff5C4A1E)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "UthmanicHafs13",
                fontSize: 18.sp,
                color: isDark ? Colors.white : const Color(0xff2C1810),
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xffC5A053),
                  fontFamily: "cairo"),
            )
          ],
        ),
      ),
    );
  }
}

// --- Home Grid Item ---
class HomeGridItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String imagePath;

  const HomeGridItem(
      {Key? key,
      required this.text,
      required this.onPressed,
      required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 5.h),
      child: Material(
        color: isDark
            ? const Color(0xff2A2520).withOpacity(.95)
            : Colors.white.withOpacity(0.85),
        shape: SuperellipseShape(
          borderRadius: BorderRadius.circular(28.0.r),
          side: BorderSide(
            color: isDark
                ? const Color(0xffC5A053).withOpacity(0.2)
                : const Color(0xffD4C4A0).withOpacity(0.4),
            width: 1.0,
          ),
        ),
        elevation: isDark ? 2 : 4,
        shadowColor: isDark
            ? Colors.black38
            : Colors.brown.withOpacity(0.15),
        child: InkWell(
          onTap: onPressed,
          customBorder: SuperellipseShape(
            borderRadius: BorderRadius.circular(28.0.r),
          ),
          splashColor: const Color(0xffC5A053).withOpacity(0.1),
          highlightColor: const Color(0xffC5A053).withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath.contains("svg"))
                  SvgPicture.asset(imagePath, height: 40.h)
                else
                  Image.asset(imagePath, height: 40.h),
                SizedBox(height: 10.h),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xffF0E0C0)
                          : const Color(0xff5C4A1E),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "cairo"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
