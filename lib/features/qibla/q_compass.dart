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
                // Compass dial
                Transform.rotate(
                  angle: heading * (-math.pi / 180),
                  child: Image.asset('assets/images/compassn.png', fit: BoxFit.fill)),
                // Qibla needle — rotated so arrow points UP toward Qibla
                Transform.rotate(
                  angle: (qiblah - heading) * (math.pi / 180),
                  child: SvgPicture.asset('assets/images/needle.svg',
                    fit: BoxFit.contain, height: MediaQuery.of(context).size.width * 0.68)),
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

            // --- Calibration instructions ---
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.orange.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange.shade300, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(_t({'ar': 'كيفية المعايرة', 'en': 'How to calibrate',
                    'de': 'So kalibrieren Sie', 'am': 'እንዴት ማስተካከል',
                    'ms': 'Cara menentukur', 'pt': 'Como calibrar',
                    'tr': 'Nasıl kalibre edilir', 'ru': 'Как откалибровать'}),
                    style: TextStyle(color: Colors.orange.shade300, fontSize: 13.sp,
                      fontWeight: FontWeight.bold, fontFamily: 'cairo')),
                ]),
                SizedBox(height: 8.h),
                Text(_t({
                  'ar': '١. أمسك الهاتف بشكل مسطح.\n٢. أدر جسمك حتى يشير سهم الكعبة إلى أعلى الشاشة تماماً.\n٣. أينما كان رأس الهاتف يواجه، فهذه هي القبلة الصحيحة.',
                  'en': '1. Hold your phone flat.\n2. Turn until the Kaaba arrow points straight to the top of the screen.\n3. Wherever the top of your phone is facing, that is the correct Qibla.',
                  'de': '1. Telefon flach halten.\n2. Drehen Sie sich, bis der Kaaba-Pfeil zur Spitze des Bildschirms zeigt.\n3. Wohin die Oberseite Ihres Telefons zeigt, ist die Qibla.',
                  'am': '1. ስልኩን ጠፍጣፋ አድርገው ያዙ።\n2. የካዕባ ቀስት ወደ ማያ ገጹ አናት እስኪጠቁም ድረስ ዙሩ።\n3. የስልኮ አናት የሚመለከትበት አቅጣጫ ቂብላ ነው።',
                  'ms': '1. Pegang telefon secara mendatar.\n2. Pusing sehingga anak panah Kaabah menunjuk ke bahagian atas skrin.\n3. Ke mana sahaja bahagian atas telefon anda menghadap, itulah Kiblat.',
                  'pt': '1. Segure o telefone plano.\n2. Gire até a seta da Kaaba apontar para o topo da tela.\n3. Para onde o topo do seu telefone estiver apontando, essa é a Qibla.',
                  'tr': '1. Telefonu düz tutun.\n2. Kabe oku ekranın en üstüne bakana kadar dönün.\n3. Telefonunuzun üst kısmı nereye bakıyorsa, doğru Kıble orasıdır.',
                  'ru': '1. Держите телефон горизонтально.\n2. Поворачивайтесь, пока стрелка Каабы не укажет на верх экрана.\n3. Куда указывает верх вашего телефона, там и Кибла.',
                  'ku': '١. مۆبایلەکەت بە تەختی بگرە.\n٢. خۆت بسوڕێنە تا سەهمی کەعبە ڕێک ڕووی لە سەرەوەی شاشەکە دەبێت.\n٣. سەری مۆبایلەکەت ڕووی لە هەر کوێ بێت، ئەوە قیبلەی دروستە.',
                  'ckb': '١. مۆبایلەکەت بە تەختی بگرە.\n٢. خۆت بسوڕێنە تا سەهمی کەعبە ڕێک ڕووی لە سەرەوەی شاشەکە دەبێت.\n٣. سەری مۆبایلەکەت ڕووی لە هەر کوێ بێت، ئەوە قیبلەی دروستە.',
                }),
                  style: TextStyle(color: sub, fontSize: 11.sp, fontFamily: 'cairo', height: 1.6)),
              ]),
            ),
            SizedBox(height: 20.h),
          ]),
        );
      },
    );
  }
}
