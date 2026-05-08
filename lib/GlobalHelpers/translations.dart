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
      'de': 'Stadtname eingeben...', 'am': 'የከተማ ስም ይጻፉ...', 'ms': 'Taip nama bandار...', 'pt': 'Digite o nome da cidade...',
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
      'ar': '📖 تطبيق ختمة (Khatmah) | رفيقك الشرعي لحياة إيمانية\n\nتطبيق شامل يلتزم بالمصادر الإسلامية الصحيحة، ويجمع لك كل ما تحتاجه في مكان واحد وفق السنة النبوية:\n\n✅ قراءة القرآن الكريم بتصميم أنيق وهادئ، مع توفر تفاسير دقيقة وموثوقة.\n✅ يقتصر على الأحاديث والأذكار الثابتة والصحيحة فقط وفق السنة.\n✅ شروحات للأحاديث النبوية لضمان الفهم الصحيح والمنضبط.\n✅ مكتبة صوتية تضم ٢٤٠ قارئاً و١٧٨ إذاعة إسلامية (قرآن وتفسير) على مدار الساعة.\n✅ أدوات المسلم: مواقيت الصلاة، اتجاه القبلة، والتقويم الهجري.\n✅ مجاني تماماً، سريع، وبدون أي إعلانات مزعجة.\n\nحمله الآن وساهم في نشره (الدال على الخير كفاعله):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ku': '📖 ئەپی خەتمە (Khatmah) | هاوڕێی شەرعیت بۆ ژیانێکی ئیمانی\n\nئەپێکی گشتگیر کە پابەندە بە سەرچاوە ئیسلامییە ڕاستەکان، و هەموو ئەوانەی پێویستتە لە یەک شوێندا بۆت کۆدەکاتەوە بەپێی سوننەتی پێغەمبەر (د.خ):\n\n✅ خوێندنەوەی قورئانی پیرۆز بە دیزاینێکی شیک و ئارام، لەگەڵ بوونی تەفسیرە ورد و جێی متمانەکان.\n✅ تەنها سنووردارە بە حەدیس و زیکرە جێگیر و ڕاستەکان بەپێی سوننەت.\n✅ ڕوونکردنەوە بۆ حەدیسە نەبەوییەکان بۆ دڵنیابوون لە تێگەیشتنی دروست و ڕێکخراو.\n✅ کتێبخانەیەکی دەنگی کە ٢٤٠ قاری و ١٧٨ ڕادیۆی ئیسلامی (قورئان و تەفسیر) لەخۆدەگرێت بەدرێژایی شەو و ڕۆژ.\n✅ ئامرازەکانی موسڵمان: کاتەکانی بانگ، قیبلەنما، و ڕۆژمێری کۆچی.\n✅ بەتەواوی بەخۆڕاییە، خێرایە، و بەبێ هیچ ڕیکلامێکی بێزارکەر.\n\nئێستا دایبەزێنە و بەشداربە لە بڵاوکردنەوەیدا (ڕێپیشاندەر بۆ چاکە وەک ئەنجامدەرەکەی وایە):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ckb': '📖 ئەپی خەتمە (Khatmah) | هاوڕێی شەرعیت بۆ ژیانێکی ئیمانی\n\nئەپێکی گشتگیر کە پابەندە بە سەرچاوە ئیسلامییە ڕاستەکان، و هەموو ئەوانەی پێویستتە لە یەک شوێندا بۆت کۆدەکاتەوە بەپێی سوننەتی پێغەمبەر (د.خ):\n\n✅ خوێندنەوەی قورئانی پیرۆز بە دیزاینێکی شیک و ئارام، لەگەڵ بوونی تەفسیرە ورد و جێی متمانەکان.\n✅ تەنها سنووردارە بە حەدیس و زیکرە جێگیر و ڕاستەکان بەپێی سوننەت.\n✅ ڕوونکردنەوە بۆ حەدیسە نەبەوییەکان بۆ دڵنیابوون لە تێگەیشتنی دروست و ڕێکخراو.\n✅ کتێبخانەیەکی دەنگی کە ٢٤٠ قاری و ١٧٨ ڕادیۆی ئیسلامی (قورئان و تەفسیر) لەخۆدەگرێت بەدرێژایی شەو و ڕۆژ.\n✅ ئامرازەکانی موسڵمان: کاتەکانی بانگ، قیبلەنما، و ڕۆژمێری کۆچی.\n✅ بەتەواوی بەخۆڕاییە، خێرایە، و بەبێ هیچ ڕیکلامێکی بێزارکەر.\n\nئێستا دایبەزێنە و بەشداربە لە بڵاوکردنەوەیدا (ڕێپیشاندەر بۆ چاکە وەک ئەنجامدەرەکەی وایە):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'en': '📖 Khatmah App | Your authentic spiritual companion for a faithful life\n\nA comprehensive app committed to authentic Islamic sources, bringing everything you need together in one place according to the Sunnah:\n\n✅ Read the Holy Quran with an elegant and calm design, featuring accurate and reliable interpretations.\n✅ Limited to authentic Hadiths and Dhikr verified according to the Sunnah.\n✅ Explanations for Hadiths to ensure correct and disciplined understanding.\n✅ An audio library featuring 240 reciters and 178 Islamic radio stations (Quran and Tafsir) 24/7.\n✅ Muslim Tools: Accurate Prayer Times, Qibla Finder, and Hijri Calendar.\n✅ Completely free, fast, and without any annoying ads.\n\nDownload now and share the goodness (The one who guides to good is like the one who does it):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'de': '📖 Khatmah App | Dein authentischer spiritueller Begleiter für ein gläubiges Leben\n\nEine umfassende App, die sich an authentische islamische Quellen hält und alles, was du brauchst, an einem Ort gemäß der Sunna vereint:\n\n✅ Lies den Heiligen Koran in einem eleganten und ruhigen Design mit präzisen und zuverlässigen Interpretationen.\n✅ Beschränkt auf authentische Hadithe und Dhikr, die gemäß der Sunna verifiziert wurden.\n✅ Erläuterungen zu Hadithen, um ein korrektes und diszipliniertes Verständnis zu gewährleisten.\n✅ Eine Audio-Bibliothek mit 240 Rezitatoren und 178 islamischen Radiosendern (Koran und Tafsir) rund um die Uhr.\n✅ Muslim-Tools: Genaue Gebetszeiten, Qibla-Finder und Hijri-Kalender.\n✅ Völlig kostenlos, schnell und ohne störende Werbung.\n\nJetzt herunterladen und das Gute teilen (Wer zum Guten führt, ist wie der, der es tut):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'am': '📖 የኸትማህ መተግበሪያ | ለእምነት ህይወት የእርስዎ እውነተኛ መንፈሳዊ ጓደኛ\n\nበሱና መሠረት የሚፈልጉትን ሁሉ በአንድ ቦታ የሚያሰባስብ፣ ለትክክለኛ ኢስላማዊ ምንጮች ቁርጠኛ የሆነ አጠቃላይ መተግበሪያ፡\n\n✅ ቅዱስ ቁርኣንን በሚያምር እና ረጋ ባለ ዲዛይን፣ ትክክለኛ እና አስተማማኝ ትርጓሜዎችን ያንብቡ።\n✅ በሱና መሠረት በተረጋገጡ ትክክለኛ ሀዲሶች እና ዚክር የተገደበ።\n✅ ትክክለኛ እና የተስተካከለ ግንዛቤን ለማረጋገጥ የሀዲሶች ማብራሪያ።\n✅ 240 ቃሪዎችን እና 178 የእስልምና ሬዲዮ ጣቢያዎችን (ቁርአን እና ተፍሲር) 24/7 የያዘ የድምጽ ቤተ-መጽሐፍት።\n✅ የሙስሊም መሳሪያዎች፡ ትክክለኛ የጸሎት ጊዜያት፣ የቂብላ አቅጣጫ እና የሂጅራ የቀን መቁጠሪያ።\n✅ ሙሉ በሙሉ ነፃ ፣ ፈጣን እና ያለ ምንም የሚያበሳጩ ማስታወቂያዎች።\n\nአሁን ያውርዱ እና መልካሙን ያካፍሉ (ወደ መልካም የሚመራ እንደ ሰሪው ነው):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ms': '📖 Aplikasi Khatmah | Teman rohani anda yang sahih untuk kehidupan beriman\n\nAplikasi komprehensif yang komited kepada sumber Islam yang sahih, menghimpunkan semua yang anda perlukan di satu tempat mengikut Sunnah:\n\n✅ Baca Al-Quran dengan reka bentuk yang elegan dan tenang, menampilkan tafsiran yang tepat dan boleh dipercayai.\n✅ Terhad kepada Hadis dan Zikir sahih yang disahkan mengikut Sunnah.\n✅ Penjelasan untuk Hadis bagi memastikan pemahaman yang betul och berdisiplin.\n✅ Perpustakaan audio yang menampilkan 240 qari och 178 stesen radio Islam (Quran dan Tafsir) 24/7.\n✅ Alat Muslim: Waktu Solat Tepat, Pencari Kiblat, dan Kalendar Hijriah.\n✅ Sepenuhnya percuma, pantas, dan tanpa sebarang iklan yang menjengkelkan.\n\nMuat turun sekarang dan kongsi kebaikan (Sesiapa yang menunjukkan kebaikan, baginya pahala seperti orang yang melakukannya):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'pt': '📖 App Khatmah | Seu companheiro espiritual autêntico para uma vida de fé\n\nUm aplicativo abrangente comprometido com fontes islâmicas autênticas, reunindo tudo o que você precisa em um só lugar de acordo com a Sunnah:\n\n✅ Leia o Alcorão Sagrado com um design elegante e calmo, com interpretações precisas e confiáveis.\n✅ Limitado a Hadiths autênticos e Dhikr verificados de acordo com a Sunnah.\n✅ Explicações para Hadiths para garantir uma compreensão correta e disciplinada.\n✅ Uma biblioteca de áudio com 240 recitadores e 178 estações de rádio islâmicas (Alcorão e Tafsir) 24 horas por dia, 7 dias por semana.\n✅ Ferramentas do Muçulmano: Horários de Oração Precisos, Localizador de Qibla e Calendário Islâmico.\n✅ Completamente gratuito, rápido e sem anúncios irritantes.\n\nBaixe agora e compartilhe o bem (Aquele que guia para o bem é como aquele que o faz):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'tr': '📖 Khatmah Uygulaması | İmanlı bir yaşam için sahih manevi rehberiniz\n\nSünnete uygun olarak ihtiyacınız olan her şeyi tek bir yerde toplayan, sahih İslami kaynaklara bağlı kapsamlı bir uygulama:\n\n✅ Kur\'an-ı Kerim\'i zarif ve sakin bir tasarımla, doğru ve güvenilir tefsirlerle okuyun.\n✅ Sünnete göre doğrulanmış sahih Hadisler ve Zikirler ile sınırlıdır.\n✅ Doğru ve disiplinli bir anlayış sağlamak için Hadis açıklamaları.\n✅ 7/24 240 hafız ve 178 İslami radyo istasyonunu (Kur\'an ve Tefsir) içeren ses kütüphanesi.\n✅ Müslüman Araçları: Doğru Namaz Vakitleri, Kıble Bulucu ve Hicri Takvim.\n✅ Tamamen ücretsiz, hızlı ve sinir bozucu reklamlar içermez.\n\nŞimdi indirin ve hayra vesile olun (Hayra vesile olan, hayrı yapan gibidir):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
      'ru': '📖 Приложение Khatmah | Ваш подлинный духовный спутник для верующей жизни\n\nВсеобъемлющее приложение, придерживающееся достоверных исламских источников и объединяющее всё необходимое в одном месте согласно Сунне:\n\n✅ Читайте Священный Коран в элегантном и спокойном дизайне с точными и надежными толкованиями.\n✅ Ограничено достоверными хадисами и зикрами, проверенными согласно Сунне.\n✅ Пояснения к хадисам для обеспечения правильного и дисциплинированного понимания.\n✅ Аудиобиблиотека с 240 чтецами и 178 исламскими радиостанциями (Коран и Тафсир) 24/7.\n✅ Инструменты мусульманина: точное время молитв, поиск Киблы и календарь Хиджры.\n✅ Полностью бесплатно, быстро и без навязчивой рекламы.\n\nСкачайте сейчас и делитесь добром (Указавший на благое подобен совершившему его):\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app',
    },
  };

  final map = dict[key];
  if (map == null) return key;
  return map[langCode] ?? map['en'] ?? key;
}
