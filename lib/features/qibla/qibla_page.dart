import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/qibla/q_compass.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  String _t(BuildContext c, String ar, String ku, String en) {
    final l = c.locale.languageCode;
    if (l == 'ar') return ar;
    if (l == 'ckb' || l == 'ku') return ku;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = getValue('darkMode') ?? false;
    final bg = isDark ? darkPrimaryColor : const Color(0xffFAF6EE);
    final txt = isDark ? Colors.white : const Color(0xff2C1810);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: txt),
        title: Text(
          _t(context, 'القبلة', 'قیبلە', 'Qibla'),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: txt, fontFamily: 'cairo'),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: CustomCompassBody(isDark: isDark)),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: Text(
              _t(context, 'أبعد الجهاز عن المعادن للحصول على نتائج أفضل',
                'ئامێرەکەت لەدوور شتی ئاسنی بگرە', 'Keep device away from metal for best results'),
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11.sp, fontFamily: 'cairo'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
