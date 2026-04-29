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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onDarkModeToggle,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xffF0E0C0) : const Color(0xff8B6914),
              size: 26,
            ),
          ),
          DropdownButton<Locale>(
            value: context.locale,
            underline: const SizedBox(),
            icon: Icon(Icons.language_rounded,
                color: isDark ? const Color(0xffF0E0C0) : const Color(0xff8B6914), size: 24),
            dropdownColor: isDark ? const Color(0xff2A2520) : const Color(0xffFFFDF7),
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
              const Locale("ru")
            ].map<DropdownMenuItem<Locale>>((Locale locale) {
              Map<String, String> languageNames = {
                "ar": "العربية",
                "en": "English",
                "de": "Deutsch",
                "am": "አማርኛ",
                "ms": "Melayu",
                "pt": "Português",
                "tr": "Türkçe",
                "ru": "Русский"
              };
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(
                  languageNames[locale.languageCode] ??
                      locale.languageCode.toUpperCase(),
                  style: TextStyle(
                    color: isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E),
                    fontFamily: "cairo",
                    fontSize: 14.sp,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
