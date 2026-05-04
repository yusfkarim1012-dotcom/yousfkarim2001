import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/GlobalHelpers/translations.dart';
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

  final List<Map<String, String>> _prayers = [
    {'key': 'fajr', 'icon': 'assets/images/fajr_icon.png'},
    {'key': 'sunrise', 'icon': 'assets/images/sunrise_icon.png'},
    {'key': 'dhuhr', 'icon': 'assets/images/dhuhr_icon.png'},
    {'key': 'asr', 'icon': 'assets/images/asr_icon.png'},
    {'key': 'maghrib', 'icon': 'assets/images/maghrib_icon.png'},
    {'key': 'isha', 'icon': 'assets/images/isha_icon.png'},
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
      case 'fajr_tomorrow':
        return _prayerTime!.fajr.add(const Duration(days: 1));
    }
    return null;
  }

  /// Returns the key of the next upcoming prayer.
  /// After Isha, returns 'fajr_tomorrow' so the countdown targets
  /// tomorrow's Fajr time instead of today's (already passed) Fajr.
  String _findNextPrayer() {
    if (_prayerTime == null) return '';
    final now = DateTime.now();
    for (final k in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      if (_getTime(k)!.isAfter(now)) return k;
    }
    // All prayers have passed for today → next is tomorrow's Fajr
    return 'fajr_tomorrow';
  }

  /// The display key strips '_tomorrow' so the UI shows "Fajr" not "fajr_tomorrow".
  String get _displayPrayerKey {
    if (_nextPrayerKey == 'fajr_tomorrow') return 'fajr';
    return _nextPrayerKey;
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
      // Prayer time has passed — recalculate which prayer is next
      final oldKey = _nextPrayerKey;
      _nextPrayerKey = _findNextPrayer();
      // If we crossed midnight and fajr_tomorrow is now fajr (today),
      // reload prayer times for the new day
      if (oldKey == 'fajr_tomorrow' && _nextPrayerKey != 'fajr_tomorrow') {
        _loadPrayerTimes();
      }
      _updateWidget();
      return;
    }
    if (mounted) setState(() => _remaining = diff);
  }

  String _fmtN(String val) {
    if (context.locale.languageCode == 'ar') {
      const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      for (int i = 0; i < 10; i++) {
        val = val.replaceAll(en[i], ar[i]);
      }
    }
    return val;
  }

  String _fmt(DateTime dt) {
    final h = dt.hour, m = dt.minute.toString().padLeft(2, '0');
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final suffix = context.locale.languageCode == 'en'
        ? (h < 12 ? ' AM' : ' PM')
        : (h < 12 ? ' ص' : ' م');
    return _fmtN('$h12:$m$suffix');
  }

  // --- Load prayer times ---
  Future<void> _loadPrayerTimes({bool forceRefresh = false}) async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final repo = MuslimRepository();
      Location? loc;

      if (!forceRefresh && getValue("cached_lat") != null && getValue("cached_lng") != null) {
        _lat = getValue("cached_lat");
        _lng = getValue("cached_lng");
        loc = await repo.reverseGeocoder(latitude: _lat!, longitude: _lng!);
      } else {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.deniedForever) {
          setState(() { _isLoading = false; _errorMessage = tGlobal('enable_location', context.locale.languageCode); });
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        _lat = pos.latitude; _lng = pos.longitude;
        updateValue("cached_lat", _lat);
        updateValue("cached_lng", _lng);
        loc = await repo.reverseGeocoder(latitude: _lat!, longitude: _lng!);
      }

      _locationName = loc?.name ?? '${_lat!.toStringAsFixed(2)}, ${_lng!.toStringAsFixed(2)}';
      final attr = PrayerAttribute(calculationMethod: CalculationMethod.mwl, asrMethod: AsrMethod.shafii, higherLatitudeMethod: HigherLatitudeMethod.angleBased);
      final l = loc ?? Location(id: 0, name: 'GPS', latitude: _lat!, longitude: _lng!, countryCode: 'XX', countryName: '', hasFixedPrayerTime: false);
      final pt = await repo.getPrayerTimes(location: l, date: DateTime.now(), attribute: attr, useFixedPrayer: loc != null);
      if (mounted) { setState(() { _prayerTime = pt; _isLoading = false; }); _fadeCtrl.forward(from: 0); _startCountdown(); _updateWidget(); }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = tGlobal('error_loading', context.locale.languageCode); });
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
      await HomeWidget.saveWidgetData('app_lang', context.locale.languageCode);
      // Localized labels
      await HomeWidget.saveWidgetData('fajr_label', tGlobal('fajr', context.locale.languageCode));
      await HomeWidget.saveWidgetData('dhuhr_label', tGlobal('dhuhr', context.locale.languageCode));
      await HomeWidget.saveWidgetData('asr_label', tGlobal('asr', context.locale.languageCode));
      await HomeWidget.saveWidgetData('maghrib_label', tGlobal('maghrib', context.locale.languageCode));
      await HomeWidget.saveWidgetData('isha_label', tGlobal('isha', context.locale.languageCode));
      await HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
    } catch (_) {}
  }

  Future<void> _loadForLocation(Location loc) async {
    setState(() { _isLoading = true; _errorMessage = ''; _selectedLocation = loc; });
    try {
      _lat = loc.latitude; _lng = loc.longitude;
      updateValue("cached_lat", _lat);
      updateValue("cached_lng", _lng);
      _locationName = '${loc.name}, ${loc.countryName}';
      final attr = PrayerAttribute(calculationMethod: CalculationMethod.mwl, asrMethod: AsrMethod.shafii, higherLatitudeMethod: HigherLatitudeMethod.angleBased);
      final pt = await MuslimRepository().getPrayerTimes(location: loc, date: DateTime.now(), attribute: attr, useFixedPrayer: loc.hasFixedPrayerTime);
      if (mounted) { setState(() { _prayerTime = pt; _isLoading = false; }); _fadeCtrl.forward(from: 0); _startCountdown(); _updateWidget(); }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = tGlobal('error', context.locale.languageCode); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false; // Forced light mode as requested by user
    final bg = isDark ? darkPrimaryColor : const Color(0xffFAF6EE);
    final cardBg = isDark ? Colors.white.withOpacity(0.12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff2C1810);
    final subText = isDark ? Colors.white54 : const Color(0xff8B7355);
    final gold = const Color(0xffC5A053);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : textColor),
        title: Text(tGlobal('prayer_times', context.locale.languageCode),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: textColor, fontFamily: 'cairo')),
        actions: [
          IconButton(icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : textColor), onPressed: () => _showSearch()),
          IconButton(icon: Icon(Icons.my_location_rounded, color: isDark ? Colors.white : textColor),
            onPressed: () { _selectedLocation = null; _loadPrayerTimes(forceRefresh: true); }),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDark ? "assets/images/prayerbackgroundnight.png" : "assets/images/daytimetry2.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(bg.withOpacity(0.85), BlendMode.darken),
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2.5))
            : _errorMessage.isNotEmpty
                ? _buildError(textColor, gold)
                : FadeTransition(opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut),
                    child: _buildBody(isDark, cardBg, textColor, subText, gold)),
      ),
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
        icon: const Icon(Icons.refresh_rounded), label: Text(tGlobal('retry', context.locale.languageCode), style: TextStyle(fontFamily: 'cairo', fontSize: 14.sp)),
        onPressed: _loadPrayerTimes),
    ]));

  Widget _buildBody(bool isDark, Color cardBg, Color txt, Color sub, Color gold) {
    final displayKey = _displayPrayerKey;
    final nextMeta = _prayers.firstWhere((m) => m['key'] == displayKey, orElse: () => _prayers[0]);
    final h = _remaining.inHours, m = _remaining.inMinutes % 60, s = _remaining.inSeconds % 60;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      child: Column(children: [
        // --- Countdown Hero ---
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: isDark
                ? [const Color(0xff1E4A38), const Color(0xff0E2A1C)]
                : [const Color(0xff1B6B45), const Color(0xff0D4A2E)]),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: gold.withOpacity(0.35), width: 1.2),
            boxShadow: [
              BoxShadow(color: const Color(0xff1B5E3B).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
              BoxShadow(color: gold.withOpacity(0.08), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          child: Column(children: [
            // Mosque icon
            Image.asset('assets/images/mosquepnggold.png', width: 36.w, height: 36.w, color: gold.withOpacity(0.6)),
            SizedBox(height: 6.h),
            Text(tGlobal('next_prayer', context.locale.languageCode),
              style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontFamily: 'cairo', letterSpacing: 0.5)),
            SizedBox(height: 4.h),
            Text(tGlobal(displayKey, context.locale.languageCode),
              style: TextStyle(color: gold, fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            SizedBox(height: 14.h),
            // Countdown digit boxes
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _digitBox(_fmtN(h.toString().padLeft(2, '0')), tGlobal('hour', context.locale.languageCode)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(':', style: TextStyle(color: gold, fontSize: 28.sp, fontWeight: FontWeight.bold))),
                _digitBox(_fmtN(m.toString().padLeft(2, '0')), tGlobal('minute', context.locale.languageCode)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(':', style: TextStyle(color: gold, fontSize: 28.sp, fontWeight: FontWeight.bold))),
                _digitBox(_fmtN(s.toString().padLeft(2, '0')), tGlobal('second', context.locale.languageCode)),
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
            Text(_fmtN(DateFormat('dd MMM', context.locale.languageCode).format(DateTime.now())),
              style: TextStyle(color: gold, fontSize: 11.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold)),
          ]),
        ),
        SizedBox(height: 14.h),

        // --- Prayer Cards ---
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/islamic_frame.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: List.generate(_prayers.length, (i) {
              final p = _prayers[i];
              final time = _getTime(p['key']!);
              final isNext = p['key'] == _displayPrayerKey;
              return _prayerCard(p, time, isNext, isDark, cardBg, txt, sub, gold, i);
            }),
          ),
        ),
      ]),
    );
  }

  Widget _digitBox(String val, String label) => Container(
    width: 68.w,
    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(children: [
      Text(val, style: TextStyle(color: const Color(0xff7DF7C0), fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
      SizedBox(height: 2.h),
      Text(label, style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontFamily: 'cairo')),
    ]),
  );

  Widget _prayerCard(Map<String, String> p, DateTime? time, bool isNext, bool isDark, Color cardBg, Color txt, Color sub, Color gold, int i) {
    final name = tGlobal(p['key']!, context.locale.languageCode);
    final nextGreen = const Color(0xff1B6B45);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: isNext ? LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [nextGreen, nextGreen.withOpacity(0.85)],
        ) : null,
        color: isNext ? null : cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isNext ? gold.withOpacity(0.5) : gold.withOpacity(0.12),
          width: isNext ? 1.5 : 0.8,
        ),
        boxShadow: isNext
          ? [BoxShadow(color: nextGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
          : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Icon with subtle background
        Container(
          width: 40.w, height: 40.w,
          decoration: BoxDecoration(
            color: isNext ? Colors.white.withOpacity(0.15) : gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(child: Image.asset(p['icon']!, width: 26.w, height: 26.w)),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(
              color: isNext ? Colors.white : txt,
              fontSize: 17.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
            if (isNext)
              Text(tGlobal('next_prayer', context.locale.languageCode),
                style: TextStyle(color: gold.withOpacity(0.8), fontSize: 10.sp, fontFamily: 'cairo')),
          ],
        )),
        if (time != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isNext ? Colors.white.withOpacity(0.15) : gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isNext ? gold.withOpacity(0.3) : Colors.transparent)),
            child: Text(_fmt(time), style: TextStyle(
              color: isNext ? Colors.white : txt,
              fontSize: 16.sp, fontWeight: FontWeight.w900, fontFamily: 'cairo'))),
      ]),
    );
  }

  // --- Search ---
  void _showSearch() {
    final isDark = false; // Forced light mode
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
          Text(tGlobal('search_city', context.locale.languageCode),
            style: TextStyle(color: txtC, fontSize: 15.sp, fontWeight: FontWeight.bold, fontFamily: 'cairo')),
          SizedBox(height: 10.h),
          TextField(
            controller: ctrl, style: TextStyle(color: txtC, fontFamily: 'cairo', fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: tGlobal('type_city_name', context.locale.languageCode),
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
              ? Center(child: Text(ctrl.text.length < 2 ? tGlobal('type_2_chars', context.locale.languageCode)
                : tGlobal('no_results', context.locale.languageCode),
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
