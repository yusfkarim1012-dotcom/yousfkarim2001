import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
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
  double? _lat, _lng;
  Location? _selectedLocation;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  String _nextPrayerKey = '';
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- Localization helper ---
  String _t(String ar, String ku, String en) {
    final l = context.locale.languageCode;
    if (l == 'ar') return ar;
    if (l == 'ckb' || l == 'ku') return ku;
    return en;
  }

  List<Map<String, String>> get _prayers => [
    {'key': 'fajr', 'ar': 'الفجر', 'ku': 'بانگی بەیانی', 'en': 'Fajr', 'icon': '🌙'},
    {'key': 'sunrise', 'ar': 'الشروق', 'ku': 'هەڵاتنی خۆر', 'en': 'Sunrise', 'icon': '🌅'},
    {'key': 'dhuhr', 'ar': 'الظهر', 'ku': 'نیوەڕۆ', 'en': 'Dhuhr', 'icon': '☀️'},
    {'key': 'asr', 'ar': 'العصر', 'ku': 'ئێوارە', 'en': 'Asr', 'icon': '🌤️'},
    {'key': 'maghrib', 'ar': 'المغرب', 'ku': 'ئاوابوون', 'en': 'Maghrib', 'icon': '🌇'},
    {'key': 'isha', 'ar': 'العشاء', 'ku': 'خەوتن', 'en': 'Isha', 'icon': '🌑'},
  ];

  DateTime? _getTime(String key) {
    if (_prayerTime == null) return null;
    switch (key) {
      case 'fajr': return _prayerTime!.fajr;
      case 'sunrise': return _prayerTime!.sunrise;
      case 'dhuhr': return _prayerTime!.dhuhr;
      case 'asr': return _prayerTime!.asr;
      case 'maghrib': return _prayerTime!.maghrib;
      case 'isha': return _prayerTime!.isha;
    }
    return null;
  }

  String _findNextPrayer() {
    if (_prayerTime == null) return '';
    final now = DateTime.now();
    for (final k in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      if (_getTime(k)!.isAfter(now)) return k;
    }
    return 'fajr';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _nextPrayerKey = _findNextPrayer();
    _updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final t = _getTime(_nextPrayerKey);
    if (t == null) return;
    final diff = t.difference(DateTime.now());
    if (diff.isNegative) {
      _nextPrayerKey = _findNextPrayer();
      return;
    }
    if (mounted) setState(() => _remaining = diff);
  }

  String _fmt(DateTime dt) {
    final h = dt.hour, m = dt.minute.toString().padLeft(2, '0');
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final suffix = context.locale.languageCode == 'en'
        ? (h < 12 ? ' AM' : ' PM')
        : (h < 12 ? ' ص' : ' م');
    return '$h12:$m$suffix';
  }

  // --- Load prayer times ---
  Future<void> _loadPrayerTimes() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        setState(() { _isLoading = false; _errorMessage = _t('يرجى تفعيل الموقع', 'تکایە شوێن چالاک بکە', 'Please enable location'); });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      _lat = pos.latitude; _lng = pos.longitude;
      final repo = MuslimRepository();
      final loc = await repo.reverseGeocoder(latitude: _lat!, longitude: _lng!);
      _locationName = loc?.name ?? '${_lat!.toStringAsFixed(2)}, ${_lng!.toStringAsFixed(2)}';
      final attr = PrayerAttribute(calculationMethod: CalculationMethod.mwl, asrMethod: AsrMethod.shafii, higherLatitudeMethod: HigherLatitudeMethod.angleBased);
      final l = loc ?? Location(id: 0, name: 'GPS', latitude: _lat!, longitude: _lng!, countryCode: 'XX', countryName: '', hasFixedPrayerTime: false);
      final pt = await repo.getPrayerTimes(location: l, date: DateTime.now(), attribute: attr, useFixedPrayer: loc != null);
      if (mounted) { setState(() { _prayerTime = pt; _isLoading = false; }); _fadeCtrl.forward(from: 0); _startCountdown(); _updateWidget(); }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = _t('خطأ في التحميل', 'هەڵەیەک ڕوویدا', 'Error loading data'); });
    }
  }

  Future<void> _updateWidget() async {
    if (_prayerTime == null) return;
    try {
      final fmtW = (DateTime dt) { final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12; return '$h:${dt.minute.toString().padLeft(2, '0')}'; };
      await HomeWidget.saveWidgetData('fajr', fmtW(_prayerTime!.fajr));
      await HomeWidget.saveWidgetData('dhuhr', fmtW(_prayerTime!.dhuhr));
      await HomeWidget.saveWidgetData('asr', fmtW(_prayerTime!.asr));
      await HomeWidget.saveWidgetData('maghrib', fmtW(_prayerTime!.maghrib));
      await HomeWidget.saveWidgetData('isha', fmtW(_prayerTime!.isha));
      await HomeWidget.saveWidgetData('next_prayer', _nextPrayerKey);
      // Localized labels
      await HomeWidget.saveWidgetData('fajr_label', _t('الفجر', 'بانگی بەیانی', 'Fajr'));
      await HomeWidget.saveWidgetData('dhuhr_label', _t('الظهر', 'نیوەڕۆ', 'Dhuhr'));
      await HomeWidget.saveWidgetData('asr_label', _t('العصر', 'ئێوارە', 'Asr'));
      await HomeWidget.saveWidgetData('maghrib_label', _t('المغرب', 'ئاوابوون', 'Maghrib'));
      await HomeWidget.saveWidgetData('isha_label', _t('العشاء', 'خەوتن', 'Isha'));
      await HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
    } catch (_) {}
  }

  Future<void> _loadForLocation(Location loc) async {
    setState(() { _isLoading = true; _errorMessage = ''; _selectedLocation = loc; });
    try {
      _lat = loc.latitude; _lng = loc.longitude;
      _locationName = '${loc.name}, ${loc.countryName}';
      final attr = PrayerAttribute(calculationMethod: CalculationMethod.mwl, asrMethod: AsrMethod.shafii, higherLatitudeMethod: HigherLatitudeMethod.angleBased);
      final pt = await MuslimRepository().getPrayerTimes(location: loc, date: DateTime.now(), attribute: attr, useFixedPrayer: loc.hasFixedPrayerTime);
      if (mounted) { setState(() { _prayerTime = pt; _isLoading = false; }); _fadeCtrl.forward(from: 0); _startCountdown(); _updateWidget(); }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = _t('خطأ', 'هەڵە', 'Error'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = getValue('darkMode') ?? false;
    final bg = isDark ? darkPrimaryColor : const Color(0xffFAF6EE);
    final cardBg = isDark ? Colors.white.withOpacity(0.07) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff2C1810);
    final subText = isDark ? Colors.white54 : const Color(0xff8B7355);
    final gold = const Color(0xffC5A053);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : textColor),
        title: Text(_t('مواقيت الصلاة', 'کاتی نوێژ', 'Prayer Times'),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: textColor, fontFamily: 'cairo')),
        actions: [
          IconButton(icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : textColor), onPressed: () => _showSearch(isDark)),
          IconButton(icon: Icon(Icons.my_location_rounded, color: isDark ? Colors.white : textColor),
            onPressed: () { _selectedLocation = null; _loadPrayerTimes(); }),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2.5))
          : _errorMessage.isNotEmpty
              ? _buildError(textColor, gold)
              : FadeTransition(opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut),
                  child: _buildBody(isDark, cardBg, textColor, subText, gold)),
    );
  }

  Widget _buildError(Color txt, Color gold) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.location_off_rounded, color: txt.withOpacity(0.4), size: 56.sp),
      SizedBox(height: 16.h),
      Text(_errorMessage, style: TextStyle(color: txt.withOpacity(0.7), fontSize: 15.sp, fontFamily: 'cairo'), textAlign: TextAlign.center),
      SizedBox(height: 20.h),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
        icon: const Icon(Icons.refresh_rounded), label: Text(_t('إعادة المحاولة', 'هەوڵدانەوە', 'Retry'), style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp)),
        onPressed: _loadPrayerTimes),
    ]));

  Widget _buildBody(bool isDark, Color cardBg, Color txt, Color sub, Color gold) {
    final nextMeta = _prayers.firstWhere((m) => m['key'] == _nextPrayerKey, orElse: () => _prayers[0]);
    final h = _remaining.inHours, m = _remaining.inMinutes % 60, s = _remaining.inSeconds % 60;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      child: Column(children: [
        // --- Countdown Hero ---
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: isDark ? [const Color(0xff1E4A38), const Color(0xff162E24)] : [const Color(0xff2A6048), const Color(0xff1B5E3B)]),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: gold.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text(_t('الصلاة التالية', 'نوێژی دواتر', 'Next Prayer'),
              style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontFamily: 'cairo')),
            SizedBox(height: 4.h),
            Text(_t(nextMeta['ar']!, nextMeta['ku']!, nextMeta['en']!),
              style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            SizedBox(height: 8.h),
            // Countdown digits
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _digit(h.toString().padLeft(2, '0'), _t('ساعة', 'کاتژمێر', 'hr')),
                Text(' : ', style: TextStyle(color: const Color(0xff7DF7C0), fontSize: 24.sp, fontWeight: FontWeight.bold)),
                _digit(m.toString().padLeft(2, '0'), _t('دقيقة', 'خولەک', 'min')),
                Text(' : ', style: TextStyle(color: const Color(0xff7DF7C0), fontSize: 24.sp, fontWeight: FontWeight.bold)),
                _digit(s.toString().padLeft(2, '0'), _t('ثانية', 'چرکە', 'sec')),
              ]),
            ),
          ]),
        ),
        SizedBox(height: 12.h),

        // --- Location + Date ---
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: gold.withOpacity(0.25)),
          ),
          child: Row(children: [
            Icon(Icons.location_on_rounded, color: gold, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(_locationName, style: TextStyle(color: txt, fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'cairo'), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(DateFormat('dd MMM', context.locale.languageCode).format(DateTime.now()),
              style: TextStyle(color: gold, fontSize: 11.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold)),
          ]),
        ),
        SizedBox(height: 14.h),

        // --- Prayer Cards ---
        ...List.generate(_prayers.length, (i) {
          final p = _prayers[i];
          final time = _getTime(p['key']!);
          final isNext = p['key'] == _nextPrayerKey;
          return _prayerCard(p, time, isNext, isDark, cardBg, txt, sub, gold, i);
        }),
      ]),
    );
  }

  Widget _digit(String val, String label) => Column(children: [
    Text(val, style: TextStyle(color: const Color(0xff7DF7C0), fontSize: 26.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
    Text(label, style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontFamily: 'cairo')),
  ]);

  Widget _prayerCard(Map<String, String> p, DateTime? time, bool isNext, bool isDark, Color cardBg, Color txt, Color sub, Color gold, int i) {
    final name = _t(p['ar']!, p['ku']!, p['en']!);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: isNext ? (isDark ? const Color(0xff1E4A38) : const Color(0xffE8F5E9)) : cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isNext ? const Color(0xff4CAF82).withOpacity(0.6) : (isDark ? Colors.white.withOpacity(0.08) : gold.withOpacity(0.15)),
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Text(p['icon']!, style: TextStyle(fontSize: 22.sp)),
        SizedBox(width: 12.w),
        Expanded(child: Text(name, style: TextStyle(
          color: isNext ? (isDark ? const Color(0xff7DF7C0) : const Color(0xff2E7D32)) : txt,
          fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo'))),
        if (time != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isNext ? const Color(0xff4CAF82).withOpacity(isDark ? 0.2 : 0.12) : (isDark ? Colors.white.withOpacity(0.06) : gold.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(8.r)),
            child: Text(_fmt(time), style: TextStyle(
              color: isNext ? (isDark ? const Color(0xff7DF7C0) : const Color(0xff2E7D32)) : (isDark ? Colors.white.withOpacity(0.85) : txt),
              fontSize: 17.sp, fontWeight: FontWeight.w900, fontFamily: 'cairo'))),
        if (isNext) ...[SizedBox(width: 6.w), Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xff4CAF82), size: 12.sp)],
      ]),
    );
  }

  // --- Search ---
  void _showSearch(bool isDark) {
    final ctrl = TextEditingController();
    List<Location> res = [];
    bool loading = false;
    final sheetBg = isDark ? const Color(0xff1C1815) : Colors.white;
    final txtC = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16.w, right: 16.w, top: 16.h),
        child: SizedBox(height: MediaQuery.of(ctx).size.height * 0.55, child: Column(children: [
          Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          SizedBox(height: 14.h),
          Text(_t('البحث عن مدينة', 'گەڕان بۆ شار', 'Search city'),
            style: TextStyle(color: txtC, fontSize: 15.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
          SizedBox(height: 10.h),
          TextField(
            controller: ctrl, style: TextStyle(color: txtC, fontFamily: 'cairo', fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: _t('اكتب اسم المدينة...', 'ناوی شار بنووسە...', 'Type city name...'),
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'cairo'),
              prefixIcon: Icon(Icons.search, color: const Color(0xffC5A053)),
              filled: true, fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none)),
            onChanged: (v) async {
              if (v.length < 2) { setS(() => res = []); return; }
              setS(() => loading = true);
              final r = await MuslimRepository().searchLocations(locationName: v);
              setS(() { res = r; loading = false; });
            }),
          SizedBox(height: 8.h),
          Expanded(child: loading
            ? Center(child: CircularProgressIndicator(color: const Color(0xffC5A053), strokeWidth: 2))
            : res.isEmpty
              ? Center(child: Text(ctrl.text.length < 2 ? _t('اكتب حرفين على الأقل', 'لانیکەم ٢ پیت بنووسە', 'Type at least 2 chars')
                : _t('لا توجد نتائج', 'ئەنجام نییە', 'No results'),
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13.sp, fontFamily: 'cairo')))
              : ListView.builder(itemCount: res.length, itemBuilder: (_, i) {
                  final l = res[i];
                  return ListTile(
                    leading: Icon(Icons.location_city_rounded, color: const Color(0xffC5A053), size: 20.sp),
                    title: Text(l.name, style: TextStyle(color: txtC, fontFamily: 'cairo', fontSize: 14.sp)),
                    subtitle: Text(l.countryName, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontFamily: 'cairo', fontSize: 11.sp)),
                    onTap: () { Navigator.pop(ctx); _loadForLocation(l); });
                })),
        ])))),
    );
  }
}
