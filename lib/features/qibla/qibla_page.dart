import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/qibla/q_compass.dart';
import 'package:khatmah/features/qibla/qibla_maps.dart';
import 'package:khatmah/GlobalHelpers/translations.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = getValue('darkMode') ?? false;
    final bg = isDark ? darkPrimaryColor : const Color(0xffFAF6EE);
    final txt = isDark ? Colors.white : const Color(0xff2C1810);
    final gold = const Color(0xffC5A053);
    final lang = context.locale.languageCode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: txt),
          title: Text(
            tGlobal('qibla', lang) == '' ? 'Qibla' : tGlobal('qibla', lang),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: txt, fontFamily: 'cairo'),
          ),
          bottom: TabBar(
            labelColor: gold,
            unselectedLabelColor: txt.withOpacity(0.5),
            indicatorColor: gold,
            labelStyle: TextStyle(fontFamily: 'cairo', fontWeight: FontWeight.bold, fontSize: 14.sp),
            unselectedLabelStyle: TextStyle(fontFamily: 'cairo', fontWeight: FontWeight.normal, fontSize: 14.sp),
            tabs: [
              Tab(text: tGlobal('compass', lang)),
              Tab(text: tGlobal('map', lang)),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Map can conflict with swiping tabs
          children: [
            CustomCompassBody(isDark: isDark),
            QiblahMaps(isDark: isDark),
          ],
        ),
      ),
    );
  }
}
