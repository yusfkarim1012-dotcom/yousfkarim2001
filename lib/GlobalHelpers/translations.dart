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
    'share_app': {
      'ar': 'شارك التطبيق', 'ku': 'ئەپەکە بڵاوبکەرەوە', 'ckb': 'ئەپەکە بڵاوبکەرەوە', 'en': 'Share App',
      'de': 'App teilen', 'am': 'መተግበሪያውን አጋራ', 'ms': 'Kongsi Aplikasi', 'pt': 'Compartilhar App',
      'tr': 'Uygulamayı Paylaş', 'ru': 'Поделиться',
    },
    'share_app_text': {
      'ar': '🕌 حمّل تطبيق ختمة\nرفيقك الروحي اليومي لحياة إسلامية.\n\n✅ أكثر من 240 قارئ للقرآن و 178 محطة إذاعية.\n✅ مواقيت صلاة دقيقة واتجاه القبلة.\n✅ أذكار يومية، أحاديث، ومسبحة إلكترونية.\n✅ بدون إعلانات ومجاني بالكامل.\n\nحمّله الآن:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ku': '🕌 ئەپی خەتمە دابەزێنە\nهاوڕێی ڕۆحانیت بۆ ژیانی ئیسلامی.\n\n✅ زیاتر لە 240 قاری قورئان و 178 وێستگەی ڕادیۆ.\n✅ کاتی نوێژ و قیبلەنما بە وردی.\n✅ ئەزکار، حەدیس، و تەسبیحی ئەلیکترۆنی.\n✅ بەبێ ڕیکلام و بەتەواوی بەخۆڕایی.\n\nئێستا دایبەزێنە:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ckb': '🕌 ئەپی خەتمە دابەزێنە\nهاوڕێی ڕۆحانیت بۆ ژیانی ئیسلامی.\n\n✅ زیاتر لە 240 قاری قورئان و 178 وێستگەی ڕادیۆ.\n✅ کاتی نوێژ و قیبلەنما بە وردی.\n✅ ئەزکار، حەدیس، و تەسبیحی ئەلیکترۆنی.\n✅ بەبێ ڕیکلام و بەتەواوی بەخۆڕایی.\n\nئێستا دایبەزێنە:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'en': '🕌 Download Khatmah App\nYour ultimate spiritual companion for a daily Islamic life.\n\n✅ 240+ Quran Reciters & 178 Radio Stations.\n✅ Accurate Prayer Times & Qibla Finder.\n✅ Daily Adhkar, Hadith, and Tasbih Counter.\n✅ Ad-free and completely FREE.\n\nGet it now:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'de': '🕌 Lade die Khatmah App herunter\nDein ultimativer spiritueller Begleiter für ein tägliches islamisches Leben.\n\n✅ Über 240 Koranrezitatoren & 178 Radiosender.\n✅ Genaue Gebetszeiten & Qibla-Finder.\n✅ Tägliche Adhkar, Hadith und Tasbih-Zähler.\n✅ Werbefrei und komplett KOSTENLOS.\n\nJetzt herunterladen:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'am': '🕌 የከተማ መተግበሪያን ያውርዱ\nለዕለታዊ እስላማዊ ሕይወት የእርስዎ ከፍተኛ መንፈሳዊ አጋር።\n\n✅ 240+ የቁርአን አንባቢዎች እና 178 የሬዲዮ ጣቢያዎች።\n✅ ትክክለኛ የጸሎት ጊዜያት እና ቂብላ ፈላጊ።\n✅ ዕለታዊ አድካር፣ ሐዲስ እና ተስቢሕ ቆጣሪ።\n✅ ያለ ማስታወቂያ እና ሙሉ በሙሉ ነፃ።\n\nአሁን ያውርዱ:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ms': '🕌 Muat Turun Aplikasi Khatmah\nTeman rohani utama anda untuk kehidupan Islam harian.\n\n✅ 240+ Qari Al-Quran & 178 Stesen Radio.\n✅ Waktu Solat Tepat & Pencari Kiblat.\n✅ Zikir Harian, Hadis, dan Kaunter Tasbih.\n✅ Tanpa iklan dan sepenuhnya PERCUMA.\n\nDapatkan sekarang:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'pt': '🕌 Baixe o App Khatmah\nSeu companheiro espiritual definitivo para uma vida islâmica diária.\n\n✅ 240+ Recitadores do Alcorão e 178 Estações de Rádio.\n✅ Horários de Oração Precisos e Localizador de Qibla.\n✅ Adhkar Diário, Hadith e Contador de Tasbih.\n✅ Sem anúncios e completamente GRATUITO.\n\nBaixe agora:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'tr': '🕌 Khatmah Uygulamasını İndirin\nGünlük İslami yaşam için nihai ruhani arkadaşınız.\n\n✅ 240+ Kuran Hafızı ve 178 Radyo İstasyonu.\n✅ Doğru Namaz Vakitleri ve Kıble Bulucu.\n✅ Günlük Zikirler, Hadis ve Tesbih Sayacı.\n✅ Reklamsız ve tamamen ÜCRETSİZ.\n\nŞimdi indirin:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ru': '🕌 Скачайте приложение Khatmah\nВаш лучший духовный спутник для ежедневной исламской жизни.\n\n✅ 240+ чтецов Корана и 178 радиостанций.\n✅ Точное время молитв и поиск Киблы.\n✅ Ежедневные азкары, хадисы и счётчик тасбиха.\n✅ Без рекламы и полностью БЕСПЛАТНО.\n\nСкачайте сейчас:\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
    },
  };

  final map = dict[key];
  if (map == null) return key;
  return map[langCode] ?? map['en'] ?? key;
}
