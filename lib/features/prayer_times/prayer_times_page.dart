import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage>
    with TickerProviderStateMixin {
  PrayerTime? _prayerTime;
  bool _isLoading = true;
  String _errorMessage = '';
  String _locationName = '';
  double? _lat;
  double? _lng;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // الأسماء العربية لأوقات الصلاة
  final List<Map<String, dynamic>> _prayerMeta = [
    {'key': 'fajr', 'ar': 'الفجر', 'en': 'Fajr', 'icon': '🌙'},
    {'key': 'sunrise', 'ar': 'الشروق', 'en': 'Sunrise', 'icon': '🌅'},
    {'key': 'dhuhr', 'ar': 'الظهر', 'en': 'Dhuhr', 'icon': '☀️'},
    {'key': 'asr', 'ar': 'العصر', 'en': 'Asr', 'icon': '🌤️'},
    {'key': 'maghrib', 'ar': 'المغرب', 'en': 'Maghrib', 'icon': '🌇'},
    {'key': 'isha', 'ar': 'العشاء', 'en': 'Isha', 'icon': '🌑'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. دەستگیرکردنی مۆڵەتی شوێن
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'locationPermissionDenied'.tr();
        });
        return;
      }

      // 2. وەرگرتنی کۆردینات
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      _lat = pos.latitude;
      _lng = pos.longitude;

      // 3. Reverse Geocoding (ناوی شار)
      final muslimRepo = MuslimRepository();
      final location = await muslimRepo.reverseGeocoder(
        latitude: _lat!,
        longitude: _lng!,
      );

      _locationName = location?.name ?? '${_lat!.toStringAsFixed(2)}, ${_lng!.toStringAsFixed(2)}';

      // 4. دیاریکردنی كات بەپێی ڕێگای MWL
      final attribute = PrayerAttribute(
        calculationMethod: CalculationMethod.mwl,
        asrMethod: AsrMethod.shafii,
        higherLatitudeMethod: HigherLatitudeMethod.angleBased,
      );

      final loc = location ??
          Location(
            id: 0,
            name: 'Current Location',
            latitude: _lat!,
            longitude: _lng!,
            countryCode: 'XX',
            countryName: 'Unknown',
            hasFixedPrayerTime: false,
          );

      final prayerTime = await muslimRepo.getPrayerTimes(
        location: loc,
        date: DateTime.now(),
        attribute: attribute,
        useFixedPrayer: location != null,
      );

      if (mounted) {
        setState(() {
          _prayerTime = prayerTime;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'errorLoadingPrayerTimes'.tr();
        });
      }
    }
  }

  /// تۆماری کاتی نوێژ بەپێی کلیل
  DateTime? _getTime(String key) {
    if (_prayerTime == null) return null;
    switch (key) {
      case 'fajr':
        return _prayerTime!.fajr;
      case 'sunrise':
        return _prayerTime!.sunrise;
      case 'dhuhr':
        return _prayerTime!.dhuhr;
      case 'asr':
        return _prayerTime!.asr;
      case 'maghrib':
        return _prayerTime!.maghrib;
      case 'isha':
        return _prayerTime!.isha;
    }
    return null;
  }

  /// دیاریکردنی نوێژی دواتر
  String _getNextPrayer() {
    if (_prayerTime == null) return '';
    final now = DateTime.now();
    final prayers = [
      {'name': 'fajr', 'time': _prayerTime!.fajr},
      {'name': 'dhuhr', 'time': _prayerTime!.dhuhr},
      {'name': 'asr', 'time': _prayerTime!.asr},
      {'name': 'maghrib', 'time': _prayerTime!.maghrib},
      {'name': 'isha', 'time': _prayerTime!.isha},
    ];
    for (final p in prayers) {
      if ((p['time'] as DateTime).isAfter(now)) return p['name'] as String;
    }
    return 'fajr'; // بکاتە سباحەی داهاتوو
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final isAm = h < 12;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m ${isAm ? 'ص' : 'م'}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = getValue('darkMode') ?? false;
    final bool isAr = context.locale.languageCode == 'ar';
    final String nextPrayer = _prayerTime != null ? _getNextPrayer() : '';

    return Container(
      decoration: BoxDecoration(
        color: darkPrimaryColor,
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/tasbeehbackground.png'),
          alignment: Alignment.center,
          opacity: 0.05,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: Colors.white.withOpacity(0.95),
              fontFamily: 'cairo',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _loadPrayerTimes,
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _buildContent(isDark, isAr, nextPrayer),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xffC5A053),
            strokeWidth: 2.5,
          ),
          SizedBox(height: 20.h),
          Text(
            'جاری خانی داتا...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontFamily: 'cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded,
                color: Colors.white54, size: 56.sp),
            SizedBox(height: 20.h),
            Text(
              _errorMessage,
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
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'هەوڵدانەوە',
                style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp),
              ),
              onPressed: _loadPrayerTimes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isAr, String nextPrayer) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          children: [
            // --- کارتی شوێن + دیکۆریشن ---
            _buildLocationCard(isDark),
            SizedBox(height: 16.h),

            // --- کارتی نوێژی دواتر ---
            if (nextPrayer.isNotEmpty) ...[
              _buildNextPrayerBanner(nextPrayer, isAr),
              SizedBox(height: 16.h),
            ],

            // --- لیستی نوێژەکان ---
            ...List.generate(_prayerMeta.length, (i) {
              final meta = _prayerMeta[i];
              final time = _getTime(meta['key']);
              final isNext = meta['key'] == nextPrayer;
              return _buildPrayerCard(
                name: isAr ? meta['ar'] : meta['en'],
                icon: meta['icon'],
                time: time,
                isNext: isNext,
                isDark: isDark,
                delay: i * 80,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xffC5A053).withOpacity(0.2),
            const Color(0xffC5A053).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xffC5A053).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xffC5A053).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded,
                color: const Color(0xffC5A053), size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _locationName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_lat != null)
                  Text(
                    '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp,
                      fontFamily: 'cairo',
                    ),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM', 'ar').format(DateTime.now()),
            style: TextStyle(
              color: const Color(0xffC5A053),
              fontSize: 12.sp,
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerBanner(String nextPrayerKey, bool isAr) {
    final meta = _prayerMeta.firstWhere((m) => m['key'] == nextPrayerKey,
        orElse: () => _prayerMeta[0]);
    final time = _getTime(nextPrayerKey);
    final now = DateTime.now();
    final diff = time != null ? time.difference(now) : Duration.zero;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff2A6048), Color(0xff1A4030)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2A6048).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(meta['icon'] as String, style: TextStyle(fontSize: 36.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوێژی دواتر',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    fontFamily: 'cairo',
                  ),
                ),
                Text(
                  isAr ? meta['ar'] : meta['en'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (time != null)
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    color: const Color(0xff7DF7C0),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                  ),
                ),
              Text(
                h > 0 ? 'لە $h کاتژمێر و $m خولەک' : 'لە $m خولەک',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11.sp,
                  fontFamily: 'cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard({
    required String name,
    required String icon,
    required DateTime? time,
    required bool isNext,
    required bool isDark,
    required int delay,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: isNext
            ? const LinearGradient(
                colors: [Color(0xff1E4A38), Color(0xff162E24)],
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0.03),
                ],
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isNext
              ? const Color(0xff4CAF82).withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          width: isNext ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // أيقونة
          Text(icon, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 14.w),

          // اسم الصلاة
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isNext ? const Color(0xff7DF7C0) : Colors.white,
                fontSize: 16.sp,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                fontFamily: 'cairo',
              ),
            ),
          ),

          // الوقت
          if (time != null)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isNext
                    ? const Color(0xff4CAF82).withOpacity(0.2)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                _formatTime(time),
                style: TextStyle(
                  color: isNext
                      ? const Color(0xff7DF7C0)
                      : Colors.white.withOpacity(0.85),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                ),
              ),
            ),

          if (isNext) ...[
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xff4CAF82),
              size: 14.sp,
            ),
          ],
        ],
      ),
    );
  }
}
