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

  // 8 languages: ar, en, de, am, ms, pt, tr, ru
  String _t(Map<String, String> texts) {
    final l = context.locale.languageCode;
    return texts[l] ?? texts['en'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      setState(() { _loading = true; _error = ''; });
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _loading = false; _error = _t({
          'ar': 'يرجى تفعيل خدمة الموقع', 'en': 'Please enable location service',
          'de': 'Bitte Standortdienst aktivieren', 'am': 'እባክዎ የአካባቢ አገልግሎት ያንቁ',
          'ms': 'Sila aktifkan perkhidmatan lokasi', 'pt': 'Ative o serviço de localização',
          'tr': 'Lütfen konum hizmetini etkinleştirin', 'ru': 'Включите службу геолокации',
        }); });
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() { _loading = false; _error = _t({
          'ar': 'يرجى السماح بالوصول للموقع', 'en': 'Please allow location access',
          'de': 'Bitte Standortzugriff erlauben', 'am': 'እባክዎ የአካባቢ ተደራሽነት ይፍቀዱ',
          'ms': 'Sila benarkan akses lokasi', 'pt': 'Permita o acesso à localização',
          'tr': 'Lütfen konum erişimine izin verin', 'ru': 'Разрешите доступ к геолокации',
        }); });
        return;
      }
      if (mounted) setState(() { _locationReady = true; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
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
          label: Text(_t({'ar': 'إعادة المحاولة', 'en': 'Retry', 'de': 'Wiederholen',
            'am': 'እንደገና ሞክር', 'ms': 'Cuba lagi', 'pt': 'Tentar novamente',
            'tr': 'Tekrar dene', 'ru': 'Повторить'}),
            style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp)),
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
            Text(_t({'ar': 'جاري تحديد القبلة...', 'en': 'Finding Qibla...',
              'de': 'Qibla wird gesucht...', 'am': 'ቂብላ በመፈለግ ላይ...',
              'ms': 'Mencari Kiblat...', 'pt': 'Encontrando Qibla...',
              'tr': 'Kıble bulunuyor...', 'ru': 'Поиск Киблы...'}),
              style: TextStyle(color: sub, fontSize: 13.sp, fontFamily: 'cairo')),
          ]));
        }

        if (snap.hasError) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade300),
            SizedBox(height: 12.h),
            Text(_t({'ar': 'خطأ في البوصلة', 'en': 'Compass error',
              'de': 'Kompassfehler', 'am': 'የኮምፓስ ስህተት',
              'ms': 'Ralat kompas', 'pt': 'Erro na bússola',
              'tr': 'Pusula hatası', 'ru': 'Ошибка компаса'}),
              style: TextStyle(color: sub, fontSize: 14.sp, fontFamily: 'cairo')),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white),
              onPressed: () => setState(() { _locationReady = false; _checkLocation(); }),
              child: Text(_t({'ar': 'إعادة', 'en': 'Retry', 'de': 'Wiederholen',
                'am': 'እንደገና', 'ms': 'Cuba lagi', 'pt': 'Tentar',
                'tr': 'Tekrar', 'ru': 'Повторить'}), style: const TextStyle(fontFamily: 'cairo'))),
          ]));
        }

        if (!snap.hasData) return const SizedBox();

        final data = snap.data!;
        final heading = data.direction;
        final qiblah = data.qiblah;
        final offset = data.offset ?? 999;
        final isAligned = offset.abs() < 5;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            SizedBox(height: 8.h),

            // --- Qibla degree info ---
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: gold.withOpacity(0.25)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.explore_rounded, color: gold, size: 20.sp),
                SizedBox(width: 8.w),
                Text('${_t({'ar': 'اتجاه القبلة', 'en': 'Qibla direction',
                  'de': 'Qibla-Richtung', 'am': 'የቂብላ አቅጣጫ',
                  'ms': 'Arah Kiblat', 'pt': 'Direção da Qibla',
                  'tr': 'Kıble yönü', 'ru': 'Направление Киблы'})}: ',
                  style: TextStyle(color: sub, fontSize: 12.sp, fontFamily: 'cairo')),
                Text('${qiblah.toStringAsFixed(1)}°',
                  style: TextStyle(color: gold, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
              ]),
            ),
            SizedBox(height: 8.h),

            // --- Aligned badge ---
            if (isAligned)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E4A38) : const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xff4CAF82).withOpacity(0.5))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle_rounded, color: const Color(0xff4CAF82), size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(_t({'ar': 'أنت تواجه القبلة ✓', 'en': 'You are facing Qibla ✓',
                    'de': 'Sie blicken zur Qibla ✓', 'am': 'ወደ ቂብላ ፊት ለፊት ነዎት ✓',
                    'ms': 'Anda menghadap Kiblat ✓', 'pt': 'Você está virado para a Qibla ✓',
                    'tr': 'Kıbleye bakıyorsunuz ✓', 'ru': 'Вы смотрите на Киблу ✓'}),
                    style: TextStyle(color: const Color(0xff4CAF82), fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
                ]),
              ),
            SizedBox(height: 12.h),

            // --- Compass ---
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.78,
              height: MediaQuery.of(context).size.width * 0.78,
              child: Stack(alignment: Alignment.center, children: [
                // Inner beautiful circle
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withOpacity(0.3), width: 2),
                  ),
                ),
                // Center dot
                Container(
                  width: 12.w, height: 12.w,
                  decoration: BoxDecoration(color: gold, shape: BoxShape.circle),
                ),
                // The rotating 4-way arrow with Kaaba
                Transform.rotate(
                  angle: (qiblah - heading) * (math.pi / 180),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    height: MediaQuery.of(context).size.width * 0.78,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Vertical line
                        Container(width: 3.w, height: MediaQuery.of(context).size.width * 0.65, color: gold.withOpacity(0.6)),
                        // Horizontal line
                        Container(height: 3.w, width: MediaQuery.of(context).size.width * 0.65, color: gold.withOpacity(0.3)),
                        // The Kaaba placed at the top
                        Positioned(
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: gold.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)],
                            ),
                            child: Image.asset('assets/images/kabaa.png', height: 65.h),
                          ),
                        ),
                        // Arrows on the other 3 ends
                        Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down_rounded, color: gold.withOpacity(0.8), size: 36.sp)),
                        Positioned(left: 0, child: Icon(Icons.keyboard_arrow_left_rounded, color: gold.withOpacity(0.5), size: 36.sp)),
                        Positioned(right: 0, child: Icon(Icons.keyboard_arrow_right_rounded, color: gold.withOpacity(0.5), size: 36.sp)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 16.h),

            // --- Heading degrees ---
            Text('${heading.toStringAsFixed(0)}°',
              style: TextStyle(color: txt, fontSize: 30.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            SizedBox(height: 4.h),
            Text(_t({'ar': 'اتجاهك الحالي', 'en': 'Your current heading',
              'de': 'Ihre aktuelle Richtung', 'am': 'የአሁኑ አቅጣጫዎ',
              'ms': 'Arah semasa anda', 'pt': 'Sua direção atual',
              'tr': 'Mevcut yönünüz', 'ru': 'Ваше текущее направление'}),
              style: TextStyle(color: sub, fontSize: 11.sp, fontFamily: 'cairo')),
            SizedBox(height: 20.h),


          ]),
        );
      },
    );
  }
}
