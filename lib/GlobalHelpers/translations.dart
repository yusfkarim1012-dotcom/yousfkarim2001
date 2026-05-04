import 'package:flutter/material.dart';

String tGlobal(String key, String langCode) {
  const Map<String, Map<String, String>> dict = {
    'prayer_times': {
      'ar': 'مواقيت الصلاة', 'ku': 'کاتەکانی نوێژ', 'ckb': 'کاتەکانی نوێژ', 'en': 'Prayer Times',
      'de': 'Gebetszeiten', 'am': 'የጸሎት ጊዜያት', 'ms': 'Waktu Solat', 'pt': 'Horários de Oração',
      'tr': 'Namaz Vakitleri', 'ru': 'Время молитв',
    },
    'qibla': {
      'ar': 'القبلة', 'ku': 'قیبلە', 'ckb': 'قیبلە', 'en': 'Qibla',
      'de': 'Qibla', 'am': 'ቂብላ', 'ms': 'Kiblat', 'pt': 'Qibla',
      'tr': 'Kıble', 'ru': 'Кибла',
    },
    'hijri_calendar': {
      'ar': 'التقويم الهجري', 'ku': 'ڕۆژمێری کۆچی', 'ckb': 'ڕۆژمێری کۆچی', 'en': 'Hijri Calendar',
      'de': 'Hidschri-Kalender', 'am': 'የሂጅራ ካላንደር', 'ms': 'Kalendar Hijriah', 'pt': 'Calendário Islâmico',
      'tr': 'Hicri Takvim', 'ru': 'Календарь Хиджры',
    },
    'fajr': {
      'ar': 'الفجر', 'ku': 'بەیانی', 'ckb': 'بەیانی', 'en': 'Fajr',
      'de': 'Fadschr', 'am': 'ፈጅር', 'ms': 'Subuh', 'pt': 'Fajr',
      'tr': 'İmsak', 'ru': 'Фаджр',
    },
    'sunrise': {
      'ar': 'الشروق', 'ku': 'خۆرهەڵاتن', 'ckb': 'خۆرهەڵاتن', 'en': 'Sunrise',
      'de': 'Sonnenaufgang', 'am': 'ፀሐይ መውጣት', 'ms': 'Syuruk', 'pt': 'Nascer do sol',
      'tr': 'Güneş', 'ru': 'Восход',
    },
    'dhuhr': {
      'ar': 'الظهر', 'ku': 'نیوەڕۆ', 'ckb': 'نیوەڕۆ', 'en': 'Dhuhr',
      'de': 'Dhuhr', 'am': 'ዙህር', 'ms': 'Zohor', 'pt': 'Dhuhr',
      'tr': 'Öğle', 'ru': 'Зухр',
    },
    'asr': {
      'ar': 'العصر', 'ku': 'ئێوارە', 'ckb': 'ئێوارە', 'en': 'Asr',
      'de': 'Asr', 'am': 'አስር', 'ms': 'Asar', 'pt': 'Asr',
      'tr': 'İkindi', 'ru': 'Аср',
    },
    'maghrib': {
      'ar': 'المغرب', 'ku': 'مەغریب', 'ckb': 'مەغریب', 'en': 'Maghrib',
      'de': 'Maghrib', 'am': 'መግሪብ', 'ms': 'Maghrib', 'pt': 'Maghrib',
      'tr': 'Akşam', 'ru': 'Магриб',
    },
    'isha': {
      'ar': 'العشاء', 'ku': 'عیشا', 'ckb': 'عیشا', 'en': 'Isha',
      'de': 'Ischa', 'am': 'ኢሻ', 'ms': 'Isyak', 'pt': 'Isha',
      'tr': 'Yatsı', 'ru': 'Иша',
    },
    'next_prayer': {
      'ar': 'الصلاة التالية', 'ku': 'نوێژی دواتر', 'ckb': 'نوێژی دواتر', 'en': 'Next Prayer',
      'de': 'Nächstes Gebet', 'am': 'ቀጣይ ጸሎት', 'ms': 'Solat Seterusnya', 'pt': 'Próxima Oração',
      'tr': 'Sonraki Namaz', 'ru': 'Следующая молитва',
    },
    'hour': {
      'ar': 'ساعة', 'ku': 'کاتژمێر', 'ckb': 'کاتژمێر', 'en': 'hr',
      'de': 'Std', 'am': 'ሰዓት', 'ms': 'jam', 'pt': 'h',
      'tr': 'saat', 'ru': 'час',
    },
    'minute': {
      'ar': 'دقيقة', 'ku': 'خولەک', 'ckb': 'خولەک', 'en': 'min',
      'de': 'Min', 'am': 'ደቂቃ', 'ms': 'min', 'pt': 'min',
      'tr': 'dk', 'ru': 'мин',
    },
    'second': {
      'ar': 'ثانية', 'ku': 'چرکە', 'ckb': 'چرکە', 'en': 'sec',
      'de': 'Sek', 'am': 'ሰከንድ', 'ms': 'saat', 'pt': 'seg',
      'tr': 'sn', 'ru': 'сек',
    },
    'retry': {
      'ar': 'إعادة المحاولة', 'ku': 'هەوڵدانەوە', 'ckb': 'هەوڵدانەوە', 'en': 'Retry',
      'de': 'Wiederholen', 'am': 'እንደገና ሞክር', 'ms': 'Cuba lagi', 'pt': 'Tentar novamente',
      'tr': 'Tekrar dene', 'ru': 'Повторить',
    },
    'error_loading': {
      'ar': 'خطأ في التحميل', 'ku': 'هەڵەیەک ڕوویدا', 'ckb': 'هەڵەیەک ڕوویدا', 'en': 'Error loading',
      'de': 'Ladefehler', 'am': 'የመጫን ስህተት', 'ms': 'Ralat memuatkan', 'pt': 'Erro ao carregar',
      'tr': 'Yükleme hatası', 'ru': 'Ошибка загрузки',
    },
    'type_city_name': {
      'ar': 'اكتب اسم المدينة...', 'ku': 'ناوی شار بنووسە...', 'ckb': 'ناوی شار بنووسە...', 'en': 'Type city name...',
      'de': 'Stadtname eingeben...', 'am': 'የከተማ ስም ይጻፉ...', 'ms': 'Taip nama bandar...', 'pt': 'Digite o nome da cidade...',
      'tr': 'Şehir adını yazın...', 'ru': 'Введите название города...',
    },
    'type_2_chars': {
      'ar': 'اكتب حرفين على الأقل', 'ku': 'لانیکەم ٢ پیت بنووسە', 'ckb': 'لانیکەم ٢ پیت بنووسە', 'en': 'Type at least 2 chars',
      'de': 'Mindestens 2 Zeichen', 'am': 'ቢያንስ 2 ፊደላት ይጻፉ', 'ms': 'Taip sekurang-kurangnya 2 aksara', 'pt': 'Digite pelo menos 2 caracteres',
      'tr': 'En az 2 karakter yazın', 'ru': 'Введите как минимум 2 символа',
    },
    'no_results': {
      'ar': 'لا توجد نتائج', 'ku': 'ئەنجام نییە', 'ckb': 'ئەنجام نییە', 'en': 'No results',
      'de': 'Keine Ergebnisse', 'am': 'ምንም ውጤት የለም', 'ms': 'Tiada hasil', 'pt': 'Nenhum resultado',
      'tr': 'Sonuç bulunamadı', 'ru': 'Нет результатов',
    },
    'enable_location': {
      'ar': 'يرجى تفعيل الموقع', 'ku': 'تکایە شوێن چالاک بکە', 'ckb': 'تکایە شوێن چالاک بکە', 'en': 'Please enable location',
      'de': 'Bitte Standort aktivieren', 'am': 'እባክዎ አካባቢን ያንቁ', 'ms': 'Sila dayakan lokasi', 'pt': 'Por favor ative a localização',
      'tr': 'Lütfen konumu etkinleştirin', 'ru': 'Включите местоположение',
    },
    'search_city': {
      'ar': 'البحث عن مدينة', 'ku': 'گەڕان بۆ شار', 'ckb': 'گەڕان بۆ شار', 'en': 'Search city',
      'de': 'Stadt suchen', 'am': 'ከተማ ይፈልጉ', 'ms': 'Cari bandar', 'pt': 'Pesquisar cidade',
      'tr': 'Şehir ara', 'ru': 'Поиск города',
    },
    'error': {
      'ar': 'خطأ', 'ku': 'هەڵە', 'ckb': 'هەڵە', 'en': 'Error',
      'de': 'Fehler', 'am': 'ስህተት', 'ms': 'Ralat', 'pt': 'Erro',
      'tr': 'Hata', 'ru': 'Ошибка',
    },
  };

  final map = dict[key];
  if (map == null) return key;
  return map[langCode] ?? map['en'] ?? key;
}
