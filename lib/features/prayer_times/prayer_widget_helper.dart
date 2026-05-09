import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';

/// Updates the Android home screen prayer widget with current prayer times.
/// Called automatically on app start and when prayer times page is opened.
class PrayerWidgetHelper {
  static Future<void> updateWidget({String langCode = 'ar'}) async {
    try {
      // Check if location is available
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

      // Use last known position for speed, or current position if none
      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      
      final repo = MuslimRepository();
      final loc = await repo.reverseGeocoder(latitude: pos.latitude, longitude: pos.longitude);

      final attr = PrayerAttribute(
        calculationMethod: CalculationMethod.mwl,
        asrMethod: AsrMethod.shafii,
        higherLatitudeMethod: HigherLatitudeMethod.angleBased,
      );

      final l = loc ?? Location(
        id: 0, name: 'GPS', latitude: pos.latitude, longitude: pos.longitude,
        countryCode: 'XX', countryName: '', hasFixedPrayerTime: false,
      );

      final pt = await repo.getPrayerTimes(
        location: l, date: DateTime.now(), attribute: attr, useFixedPrayer: loc != null,
      );

      if (pt == null) return;

      String fmt(DateTime dt) {
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        return '$h:${dt.minute.toString().padLeft(2, '0')}';
      }

      String t(String ar, String ku, String en) {
        if (langCode == 'ar') return ar;
        if (langCode == 'ckb' || langCode == 'ku') return ku;
        return en;
      }

      // Find next prayer
      final now = DateTime.now();
      String nextPrayer = 'fajr';
      final prayers = {'fajr': pt.fajr, 'dhuhr': pt.dhuhr, 'asr': pt.asr, 'maghrib': pt.maghrib, 'isha': pt.isha};
      for (final e in prayers.entries) {
        if (e.value.isAfter(now)) { nextPrayer = e.key; break; }
      }

      // Save widget data
      await HomeWidget.saveWidgetData('fajr', fmt(pt.fajr));
      await HomeWidget.saveWidgetData('dhuhr', fmt(pt.dhuhr));
      await HomeWidget.saveWidgetData('asr', fmt(pt.asr));
      await HomeWidget.saveWidgetData('maghrib', fmt(pt.maghrib));
      await HomeWidget.saveWidgetData('isha', fmt(pt.isha));
      await HomeWidget.saveWidgetData('next_prayer', nextPrayer);

      await HomeWidget.saveWidgetData('fajr_label', t('الفجر', 'بانگی بەیانی', 'Fajr'));
      await HomeWidget.saveWidgetData('dhuhr_label', t('الظهر', 'نیوەڕۆ', 'Dhuhr'));
      await HomeWidget.saveWidgetData('asr_label', t('العصر', 'ئێوارە', 'Asr'));
      await HomeWidget.saveWidgetData('maghrib_label', t('المغرب', 'ئاوابوون', 'Maghrib'));
      await HomeWidget.saveWidgetData('isha_label', t('العشاء', 'خەوتن', 'Isha'));

      // --- Date Header Data (Fully Localized) ---
      final dayOfWeek = _getDayOfWeek(now.weekday, langCode);
      await HomeWidget.saveWidgetData('day_of_week', dayOfWeek);

      // Hijri Date
      final isRtl = langCode == 'ar' || langCode == 'ku' || langCode == 'ckb';
      HijriCalendar.setLocal(isRtl ? 'ar' : 'en');
      final hijri = HijriCalendar.now();
      await HomeWidget.saveWidgetData('hijri_date', hijri.toFormat('dd MMMM yyyy'));

      // Gregorian Date
      final gregorian = DateFormat('d MMM yyyy', isRtl ? 'ar' : 'en').format(now);
      await HomeWidget.saveWidgetData('gregorian_date', gregorian);

      await HomeWidget.saveWidgetData('app_lang', langCode);

      await HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
    } catch (_) {}
  }

  static String _getDayOfWeek(int weekday, String langCode) {
    final Map<String, List<String>> dayTranslations = {
      'ar': ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
      'ku': ['دووشەممە', 'سێشەممە', 'چوارشەممە', 'پێنجشەممە', 'هەینی', 'شەممە', 'یەکشەممە'],
      'ckb': ['دووشەممە', 'سێشەممە', 'چوارشەممە', 'پێنجشەممە', 'هەینی', 'شەممە', 'یەکشەممە'],
      'de': ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'],
      'tr': ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'],
      'ru': ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'],
      'ms': ['Isnin', 'Selasa', 'Rabu', 'Khamis', 'Jumaat', 'Sabtu', 'Ahad'],
      'pt': ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'],
      'am': ['ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'አርብ', 'ቅዳሜ', 'እሁድ'],
      'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    };

    final idx = weekday - 1; 
    final days = dayTranslations[langCode] ?? dayTranslations['en']!;
    return days[idx];
  }
}
