import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCompassBody extends StatefulWidget {
  const CustomCompassBody({super.key});

  @override
  State<CustomCompassBody> createState() => _CustomCompassBodyState();
}

class _CustomCompassBodyState extends State<CustomCompassBody> {
  bool _hasPermissions = false;
  bool _deviceSupported = true;
  bool _checkingSupport = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
    _fetchPermissionStatus();
  }

  Future<void> _checkDeviceSupport() async {
    final supported = await FlutterQiblah.androidDeviceSensorSupport();
    if (mounted) {
      setState(() {
        _deviceSupported = supported ?? false;
        _checkingSupport = false;
      });
    }
  }

  Future<void> _fetchPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    if (mounted) {
      setState(() {
        _hasPermissions = status == PermissionStatus.granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSupport) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xffC5A053),
          strokeWidth: 2.5,
        ),
      );
    }

    if (!_deviceSupported) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_off_rounded,
                  size: 64.sp, color: Colors.white38),
              SizedBox(height: 20.h),
              Text(
                'ئامێرەکەت کۆمپاسی نییە',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.sp,
                  fontFamily: 'cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermissions) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded,
                  size: 64.sp, color: Colors.white38),
              SizedBox(height: 20.h),
              Text(
                'مۆڵەتی شوێن پێویستە بۆ دیاریکردنی قیبلە',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.sp,
                  fontFamily: 'cairo',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC5A053),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                icon: const Icon(Icons.location_on_rounded),
                label: Text(
                  'داوای مۆڵەت بکە',
                  style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp),
                ),
                onPressed: () async {
                  await [
                    Permission.location,
                    Permission.locationWhenInUse,
                  ].request();
                  _fetchPermissionStatus();
                },
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xffC5A053),
              strokeWidth: 2.5,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'کێشەیەک ڕووی داو: ${snapshot.error}',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp,
                  fontFamily: 'cairo'),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'چاوەڕوانی داتای کۆمپاس...',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontFamily: 'cairo'),
            ),
          );
        }

        final qiblahDirection = snapshot.data!;

        // کۆردینەیتی ئامێرەکە
        final double heading = qiblahDirection.direction;

        // ئاراستەی قیبلە بە پێی ڕووی باکور
        final double qiblahAngle = qiblahDirection.qiblah;

        // گێردانی کۆمپاسی ڕووباک (پێچەوانەی ئامێر)
        final double compassTurn = (heading * -1) / 360;

        // گێردانی ئاستیکەی قیبلە
        final double needleTurn = (qiblahAngle - heading) / 360;

        final bool isAligned = qiblahDirection.offset != null &&
            qiblahDirection.offset!.abs() < 5;
        final bool needsCalibration = qiblahDirection.offset != null &&
            qiblahDirection.offset!.abs() > 15;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // نیشاندەری هەوکارکردن
              if (isAligned) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xff2A6048),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: const Color(0xff4CAF82).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: const Color(0xff7DF7C0), size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'ڕووی قیبلەیە! ✓',
                        style: TextStyle(
                          color: const Color(0xff7DF7C0),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (needsCalibration) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'ئامێرەکەت کالیبر بکەرەوە (شەکلی 8)',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12.sp,
                          fontFamily: 'cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // --- کۆمپاسی دیاری ---
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.width * 0.78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // کۆمپاسی ڕووباک — گێردانی پێچەوانەی ئامێر
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: compassTurn,
                      curve: Curves.easeOut,
                      child: Image.asset(
                        'assets/images/compassn.png',
                        fit: BoxFit.fill,
                      ),
                    ),

                    // ئاستیکەی قیبلە — ڕووی کارگەی قیبلە
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: needleTurn,
                      curve: Curves.easeOut,
                      child: SvgPicture.asset(
                        'assets/images/needle.svg',
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // دەرجەی ئامێر
              Text(
                '${heading.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                ),
              ),

              SizedBox(height: 6.h),

              // ئاراستەی قیبلە
              Text(
                'ئاراستەی قیبلە: ${qiblahAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13.sp,
                  fontFamily: 'cairo',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
