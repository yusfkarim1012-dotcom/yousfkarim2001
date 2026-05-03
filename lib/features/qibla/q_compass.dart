import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

class CustomCompassBody extends StatefulWidget {
  final bool isDark;
  const CustomCompassBody({super.key, required this.isDark});
  @override
  State<CustomCompassBody> createState() => _CustomCompassBodyState();
}

class _CustomCompassBodyState extends State<CustomCompassBody> {
  bool _locationReady = false;
  bool _loading = true;
  String _error = '';

  String _t(String ar, String ku, String en) {
    final l = context.locale.languageCode;
    if (l == 'ar') return ar;
    if (l == 'ckb' || l == 'ku') return ku;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      setState(() { _loading = true; _error = ''; });

      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _loading = false; _error = _t('يرجى تفعيل خدمة الموقع', 'خزمەتگوزاری شوێن چالاک بکە', 'Enable location service'); });
        return;
      }

      // Check permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() { _loading = false; _error = _t('يرجى السماح بالوصول للموقع', 'مۆڵەتی شوێن بدە', 'Allow location access'); });
        return;
      }

      if (mounted) setState(() { _locationReady = true; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = _t('خطأ: $e', 'هەڵە: $e', 'Error: $e'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? Colors.white : const Color(0xff2C1810);
    final sub = isDark ? Colors.white54 : const Color(0xff8B7355);
    final gold = const Color(0xffC5A053);

    if (_loading) return Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2.5));

    if (_error.isNotEmpty) return Center(child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_off_rounded, size: 56.sp, color: sub),
        SizedBox(height: 16.h),
        Text(_error, style: TextStyle(color: sub, fontSize: 14.sp, fontFamily: 'cairo'), textAlign: TextAlign.center),
        SizedBox(height: 20.h),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(_t('إعادة المحاولة', 'هەوڵدانەوە', 'Retry'), style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp)),
          onPressed: _checkLocation),
      ])));

    if (!_locationReady) return const SizedBox();

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: gold, strokeWidth: 2.5),
            SizedBox(height: 12.h),
            Text(_t('جاري تحديد القبلة...', 'دۆزینەوەی قیبلە...', 'Finding Qibla...'),
              style: TextStyle(color: sub, fontSize: 13.sp, fontFamily: 'cairo')),
          ]));
        }

        if (snap.hasError) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade300),
            SizedBox(height: 12.h),
            Text(_t('خطأ في البوصلة', 'هەڵە لە کۆمپاس', 'Compass error'),
              style: TextStyle(color: sub, fontSize: 14.sp, fontFamily: 'cairo')),
            SizedBox(height: 6.h),
            Text('${snap.error}', style: TextStyle(color: sub.withOpacity(0.6), fontSize: 10.sp), textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white),
              onPressed: () => setState(() { _locationReady = false; _checkLocation(); }),
              child: Text(_t('إعادة', 'دووبارە', 'Retry'), style: const TextStyle(fontFamily: 'cairo'))),
          ]));
        }

        if (!snap.hasData) return const SizedBox();

        final data = snap.data!;
        final heading = data.direction;
        final qiblah = data.qiblah;
        final offset = data.offset ?? 999;
        final isAligned = offset.abs() < 5;

        return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAligned)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E4A38) : const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xff4CAF82).withOpacity(0.5))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle_rounded, color: const Color(0xff4CAF82), size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(_t('اتجاه القبلة ✓', 'ڕووی قیبلەیە ✓', 'Facing Qibla ✓'),
                    style: TextStyle(color: const Color(0xff4CAF82), fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
                ]),
              ),
            SizedBox(height: 12.h),

            // Compass
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              child: Stack(alignment: Alignment.center, children: [
                // Compass dial
                Transform.rotate(
                  angle: heading * (-math.pi / 180),
                  child: Image.asset('assets/images/compassn.png', fit: BoxFit.fill)),
                // Qibla needle
                Transform.rotate(
                  angle: (qiblah - heading) * (math.pi / 180),
                  child: SvgPicture.asset('assets/images/needle.svg',
                    fit: BoxFit.contain, height: MediaQuery.of(context).size.width * 0.65)),
              ]),
            ),
            SizedBox(height: 20.h),
            Text('${heading.toStringAsFixed(0)}°',
              style: TextStyle(color: txt, fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            SizedBox(height: 4.h),
            Text('${_t('اتجاه القبلة', 'ئاراستەی قیبلە', 'Qibla direction')}: ${qiblah.toStringAsFixed(1)}°',
              style: TextStyle(color: sub, fontSize: 12.sp, fontFamily: 'cairo')),
          ],
        ));
      },
    );
  }
}
