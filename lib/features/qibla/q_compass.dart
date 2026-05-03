import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCompassBody extends StatefulWidget {
  final bool isDark;
  const CustomCompassBody({super.key, required this.isDark});
  @override
  State<CustomCompassBody> createState() => _CustomCompassBodyState();
}

class _CustomCompassBodyState extends State<CustomCompassBody> {
  bool _hasPerms = false;
  bool _supported = true;
  bool _checking = true;

  String _t(String ar, String ku, String en) {
    final l = context.locale.languageCode;
    if (l == 'ar') return ar;
    if (l == 'ckb' || l == 'ku') return ku;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sup = await FlutterQiblah.androidDeviceSensorSupport();
    final perm = await Permission.locationWhenInUse.status;
    if (mounted) setState(() { _supported = sup ?? false; _hasPerms = perm == PermissionStatus.granted; _checking = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? Colors.white : const Color(0xff2C1810);
    final sub = isDark ? Colors.white54 : const Color(0xff8B7355);
    final gold = const Color(0xffC5A053);

    if (_checking) return Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2.5));

    if (!_supported) return _msg(Icons.sensors_off_rounded, _t('الجهاز لا يدعم البوصلة', 'ئامێرەکەت کۆمپاسی نییە', 'Device has no compass'), txt, sub);

    if (!_hasPerms) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_off_rounded, size: 56.sp, color: sub),
        SizedBox(height: 16.h),
        Text(_t('يجب تفعيل الموقع', 'مۆڵەتی شوێن پێویستە', 'Location permission required'),
          style: TextStyle(color: sub, fontSize: 14.sp, fontFamily: 'cairo'), textAlign: TextAlign.center),
        SizedBox(height: 20.h),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
          icon: const Icon(Icons.location_on_rounded),
          label: Text(_t('السماح', 'مۆڵەت بدە', 'Allow'), style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp)),
          onPressed: () async { await [Permission.location, Permission.locationWhenInUse].request(); _init(); }),
      ]));

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2.5));
        if (snap.hasError || !snap.hasData) return _msg(Icons.error_outline, _t('خطأ في البوصلة', 'کێشە لە کۆمپاس', 'Compass error'), txt, sub);

        final data = snap.data!;
        final heading = data.direction;
        final qiblah = data.qiblah;
        final offset = data.offset ?? 0;
        final isAligned = offset.abs() < 5;

        return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status badge
            if (isAligned)
              _badge(Icons.check_circle_rounded, _t('اتجاه القبلة ✓', 'ڕووی قیبلەیە ✓', 'Facing Qibla ✓'),
                isDark ? const Color(0xff1E4A38) : const Color(0xffE8F5E9),
                const Color(0xff4CAF82), isDark),

            SizedBox(height: 12.h),

            // Compass
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              child: Stack(alignment: Alignment.center, children: [
                // Compass dial — rotates opposite to heading
                Transform.rotate(
                  angle: heading * (-math.pi / 180),
                  child: Image.asset('assets/images/compassn.png', fit: BoxFit.fill),
                ),
                // Qibla needle — rotates to point at Qibla
                Transform.rotate(
                  angle: (qiblah - heading) * (math.pi / 180),
                  child: SvgPicture.asset('assets/images/needle.svg',
                    fit: BoxFit.contain, height: MediaQuery.of(context).size.width * 0.65),
                ),
              ]),
            ),

            SizedBox(height: 20.h),

            // Heading degrees
            Text('${heading.toStringAsFixed(0)}°',
              style: TextStyle(color: txt, fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            SizedBox(height: 4.h),
            Text(_t('اتجاه القبلة: ${qiblah.toStringAsFixed(1)}°', 'ئاراستەی قیبلە: ${qiblah.toStringAsFixed(1)}°', 'Qibla: ${qiblah.toStringAsFixed(1)}°'),
              style: TextStyle(color: sub, fontSize: 12.sp, fontFamily: 'cairo')),
          ],
        ));
      },
    );
  }

  Widget _msg(IconData icon, String text, Color txt, Color sub) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 56.sp, color: sub),
      SizedBox(height: 16.h),
      Text(text, style: TextStyle(color: sub, fontSize: 14.sp, fontFamily: 'cairo'), textAlign: TextAlign.center),
    ]));

  Widget _badge(IconData icon, String text, Color bg, Color fg, bool isDark) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: fg.withOpacity(0.5))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: fg, size: 16.sp),
      SizedBox(width: 6.w),
      Text(text, style: TextStyle(color: fg, fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
    ]));
}
