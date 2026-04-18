import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

// Import for specific widgets used in Grid
import 'package:flutter_svg/flutter_svg.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:iconsax/iconsax.dart';

// --- Home Header ---
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               IconButton(
                  onPressed: onDarkModeToggle,
                  icon: Icon(
                    Icons.dark_mode_outlined,
                    color: getValue("darkMode") ? Colors.white70 : goldColor,
                  )),
              DropdownButton<Locale>(
                value: context.locale,
                underline: Container(), // Remove underline
                icon: Icon(Icons.language, color: getValue("darkMode") ? Colors.white70 : goldColor),
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
                  const Locale("ku")
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
                    "ku": "کوردی"
                  };
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(
                      languageNames[locale.languageCode] ?? locale.languageCode.toUpperCase(),
                      style: TextStyle(
                          color: getValue("darkMode") ? orangeColor : blueColor),
                    ),
                  );
                }).toList(),
              ),
             
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'main'.tr(),
            textAlign: TextAlign.end,
            style: TextStyle(
                color: getValue("darkMode") ? Colors.white : goldColor,
                fontFamily: "cairo",
                fontWeight: FontWeight.bold,
                fontSize: 32.sp),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(18.0.w),
        decoration: BoxDecoration(
          color: getValue("darkMode")
                        ? const Color(0xff443F42).withOpacity(.9)
                        : const Color(0xffFEFEFE),
          borderRadius: BorderRadius.circular(24.0.r),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Iconsax.book_1, color: orangeColor),
                Text(
                  title, 
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 14.sp,
                    color: getValue("darkMode") ? Colors.white70 : blueColor
                  ),
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
                color: getValue("darkMode") ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
             SizedBox(height: 12.h),
             Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: orangeColor,
                fontFamily: "cairo"
              ),
             )
          ],
        ),
      ),
    );
  }
}

// --- Superellipse Button (Reused) ---
// Moved here to be reusable strictly in the grid context
class HomeGridItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String imagePath;

  const HomeGridItem({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.imagePath
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    bool isDarkMode = getValue("darkMode");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0.w, vertical: 6.h),
      child: Material(
        color: isDarkMode
            ? const Color(0xff443F42).withOpacity(.9) // Keeping original dark palette logic
            : const Color(0xffFEFEFE),
        shape: SuperellipseShape(
          borderRadius: BorderRadius.circular(20.0.r), // Changed from 24 to 20
        ),
        elevation: 3, // Increased elevation
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onPressed,
          splashColor: orangeColor.withOpacity(0.2), // Increased opacity
          borderRadius: BorderRadius.circular(20.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath.contains("svg"))
                SvgPicture.asset(
                  imagePath,
                  height: 32.h,
                )
              else
                Image.asset(
                  imagePath,
                  height: 32.h,
                ),
              SizedBox(height: 12.h),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : orangeColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "cairo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
