import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/qibla/q_compass.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  String _t(BuildContext c, Map<String, String> texts) {
    final l = c.locale.languageCode;
    return texts[l] ?? texts['en'] ?? '';
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
          _t(context, {'ar': 'القبلة', 'en': 'Qibla', 'de': 'Qibla',
            'am': 'ቂብላ', 'ms': 'Kiblat', 'pt': 'Qibla', 'tr': 'Kıble', 'ru': 'Кибла'}),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: txt, fontFamily: 'cairo'),
        ),
      ),
      body: CustomCompassBody(isDark: isDark),
    );
  }
}
