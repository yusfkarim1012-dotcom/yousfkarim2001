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
      'ar': 'تطبيق ختمة رفيقك الإيماني في كل وقت\n\nتطبيق إسلامي شامل وموثوق يجمع لك كل ما تحتاجه من عبادات في مكان واحد وبدون إعلانات مزعجة\n\n📖 قراءة القرآن الكريم بتصميم هادئ ومريح مع تفاسير دقيقة\n🕌 مواقيت الصلاة واتجاه القبلة والتقويم الهجري بدقة عالية\n📜 أحاديث نبوية صحيحة وأذكار ثابتة مع شروحات مبسطة\n🎧 مكتبة صوتية ضخمة تضم ٢٤٠ قارئا و١٧٨ إذاعة إسلامية\n📿 سبحة إلكترونية وواجهة عصرية سهلة الاستخدام\n\nالتطبيق مجاني تماما لوجه الله ساهم معنا في نشره (والدال على الخير كفاعله) 🚀\n\n📱 تحميل 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nلا تنسى تدعمنا وتقيم التطبيق بخمس نجوم في المتجر عشان يوصل لكل الناس وتكون شريك معنا في الأجر الله يكتب أجرك ويرفع قدرك ⭐⭐⭐⭐⭐',
      'ku': 'ئەپی خەتمە هاوڕێی ئیمانیت لە هەموو کاتێکدا\n\nئەپێکی ئیسلامی گشتگیر و متمانەپێکراو هەموو ئەو عیبادانەی پێویستتە لە یەک شوێندا بۆت کۆدەکاتەوە بەبێ هیچ ڕیکلامێکی بێزارکەر\n\n📖 خوێندنەوەی قورئانی پیرۆز بە دیزاینێکی ئارام و ڕاحەت لەگەڵ تەفسیرە وردەکان\n🕌 کاتەکانی بانگ و ئاڕاستەی قیبلە و ڕۆژمێری کۆچی بە وردی بەرز\n📜 حەدیسە نەبەوییە ڕاستەکان و ئەزکاری جێگیر لەگەڵ ڕوونکردنەوەی ئاسان\n🎧 کتێبخانەیەکی دەنگی گەورە ٢٤٠ قاری و ١٧٨ ڕادیۆی ئیسلامی لەخۆدەگرێت\n📿 تەسبیحی ئەلیکترۆنی و ڕووکارێکی سەردەمیانە و ئاسان بۆ بەکارهێنان\n\nئەپەکە بەتەواوی بەخۆڕاییە بۆ ڕەزای خودا بەشداربە لە بڵاوکردنەوەیدا (ڕێنمایی بۆ چاکە وەک چاکەکارەکەیە) 🚀\n\n📱 دابەزاندن 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nلەبیرت نەچێت پشتگیریمان بکەیت و ئەپەکە بە پێنج ئەستێرە هەڵبسەنگێنیت لە فرۆشگاکە تاکو بگاتە هەموو خەڵک و هاوبەشی ئەجر بیت خودا ئەجرت بنووسێت و پلەت بەرز بکاتەوە ⭐⭐⭐⭐⭐',
      'ckb': 'ئەپی خەتمە هاوڕێی ئیمانیت لە هەموو کاتێکدا\n\nئەپێکی ئیسلامی گشتگیر و متمانەپێکراو هەموو ئەو عیبادانەی پێویستتە لە یەک شوێندا بۆت کۆدەکاتەوە بەبێ هیچ ڕیکلامێکی بێزارکەر\n\n📖 خوێندنەوەی قورئانی پیرۆز بە دیزاینێکی ئارام و ڕاحەت لەگەڵ تەفسیرە وردەکان\n🕌 کاتەکانی بانگ و ئاڕاستەی قیبلە و ڕۆژمێری کۆچی بە وردی بەرز\n📜 حەدیسە نەبەوییە ڕاستەکان و ئەزکاری جێگیر لەگەڵ ڕوونکردنەوەی ئاسان\n🎧 کتێبخانەیەکی دەنگی گەورە ٢٤٠ قاری و ١٧٨ ڕادیۆی ئیسلامی لەخۆدەگرێت\n📿 تەسبیحی ئەلیکترۆنی و ڕووکارێکی سەردەمیانە و ئاسان بۆ بەکارهێنان\n\nئەپەکە بەتەواوی بەخۆڕاییە بۆ ڕەزای خودا بەشداربە لە بڵاوکردنەوەیدا (ڕێنمایی بۆ چاکە وەک چاکەکارەکەیە) 🚀\n\n📱 دابەزاندن 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nلەبیرت نەچێت پشتگیریمان بکەیت و ئەپەکە بە پێنج ئەستێرە هەڵبسەنگێنیت لە فرۆشگاکە تاکو بگاتە هەموو خەڵک و هاوبەشی ئەجر بیت خودا ئەجرت بنووسێت و پلەت بەرز بکاتەوە ⭐⭐⭐⭐⭐',
      'en': 'Khatmah App - Your faithful companion at all times\n\nA comprehensive and trusted Islamic app that brings together all the worship you need in one place without annoying ads\n\n📖 Read the Holy Quran with a calm and comfortable design with accurate interpretations\n🕌 Prayer times, Qibla direction, and Hijri calendar with high accuracy\n📜 Authentic Prophetic hadiths and verified dhikr with simplified explanations\n🎧 A massive audio library featuring 240 reciters and 178 Islamic radio stations\n📿 Electronic tasbeeh and a modern, easy-to-use interface\n\nThe app is completely free for the sake of Allah. Help us spread it (The one who guides to good is like the one who does it) 🚀\n\n📱 Download 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nDon\'t forget to support us and rate the app with five stars in the store so it reaches everyone and you become a partner in the reward. May Allah write your reward and raise your status ⭐⭐⭐⭐⭐',
      'de': 'Khatmah App - Dein treuer Begleiter zu jeder Zeit\n\nEine umfassende und vertrauenswürdige islamische App, die alle Gottesdienste, die du brauchst, an einem Ort ohne lästige Werbung vereint\n\n📖 Lies den Heiligen Koran in einem ruhigen und komfortablen Design mit genauen Interpretationen\n🕌 Gebetszeiten, Qibla-Richtung und Hijri-Kalender mit hoher Genauigkeit\n📜 Authentische prophetische Hadithe und verifizierter Dhikr mit vereinfachten Erklärungen\n🎧 Eine riesige Audiobibliothek mit 240 Rezitatoren und 178 islamischen Radiosendern\n📿 Elektronischer Tasbeeh und eine moderne, benutzerfreundliche Oberfläche\n\nDie App ist völlig kostenlos um Allahs willen. Hilf uns, sie zu verbreiten (Wer zum Guten führt, ist wie der, der es tut) 🚀\n\n📱 Herunterladen 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nVergiss nicht, uns zu unterstützen und die App mit fünf Sternen im Store zu bewerten, damit sie jeden erreicht und du an der Belohnung teilhast. Möge Allah deine Belohnung schreiben und deinen Status erhöhen ⭐⭐⭐⭐⭐',
      'am': 'የኸትማህ መተግበሪያ - በማንኛውም ጊዜ ታማኝ ጓደኛዎ\n\nየሚፈልጉትን ሁሉንም አምልኮዎች ያለ ምንም የሚያበሳጩ ማስታወቂያዎች በአንድ ቦታ የሚያሰባስብ አጠቃላይ እና አስተማማኝ ኢስላማዊ መተግበሪያ\n\n📖 ቅዱስ ቁርኣንን በተረጋጋ እና ምቹ ንድፍ ትክክለኛ በሆኑ ትርጓሜዎች ያንብቡ\n🕌 የጸሎት ጊዜያት፣ የቂብላ አቅጣጫ እና የሂጅራ የቀን መቁጠሪያ በከፍተኛ ትክክለኛነት\n📜 ትክክለኛ የነብዩ ሀዲሶች እና የተረጋገጠ ዚክር ከተብራሩ ማብራሪያዎች ጋር\n🎧 240 አንባቢዎችን እና 178 ኢስላማዊ የሬዲዮ ጣቢያዎችን ያካተተ ግዙፍ የድምጽ ቤተ-መጽሐፍት\n📿 የኤሌክትሮኒክ ተስቢህ እና ዘመናዊ፣ ለመጠቀም ቀላል የሆነ በይነገጽ\n\nመተግበሪያው ለአላህ ሲባል ሙሉ በሙሉ ነፃ ነው። እንድናሰራጨው እርዱን (ወደ መልካም የሚመራ እንደ ሰሪው ነው) 🚀\n\n📱 ያውርዱ 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nሁሉንም ሰው እንዲደርስ እና በምንዳው ተካፋይ እንዲሆኑ እኛን መደገፍዎን እና መተግበሪያውን በመደብሩ ውስጥ በአምስት ኮከቦች ደረጃ መስጠትዎን አይርሱ። አላህ ምንዳችሁን ይፃፍ ደረጃችሁንም ከፍ ያድርገው ⭐⭐⭐⭐⭐',
      'ms': 'Aplikasi Khatmah - Teman setia anda pada setiap masa\n\nAplikasi Islam yang komprehensif dan dipercayai yang menghimpunkan semua ibadah yang anda perlukan di satu tempat tanpa iklan yang menjengkelkan\n\n📖 Baca Al-Quran dengan reka bentuk yang tenang dan selesa dengan tafsiran yang tepat\n🕌 Waktu solat, arah Kiblat, dan kalendar Hijrah dengan ketepatan yang tinggi\n📜 Hadis Nabawi yang sahih dan zikir yang disahkan dengan penjelasan yang mudah\n🎧 Perpustakaan audio yang besar yang menampilkan 240 qari dan 178 stesen radio Islam\n📿 Tasbih elektronik dan antara muka yang moden serta mudah digunakan\n\nAplikasi ini adalah percuma sepenuhnya kerana Allah. Bantu kami menyebarkannya (Sesiapa yang menunjukkan kebaikan, baginya pahala seperti orang yang melakukannya) 🚀\n\n📱 Muat turun 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nJangan lupa untuk menyokong kami dan menilai aplikasi ini dengan lima bintang di stor supaya ia mencapai semua orang dan anda menjadi rakan kongsi dalam pahala. Semoga Allah menulis pahala anda dan meninggikan darjat anda ⭐⭐⭐⭐⭐',
      'pt': 'App Khatmah - Seu companheiro fiel em todos os momentos\n\nUm aplicativo islâmico abrangente e confiável que reúne toda a adoração de que você precisa em um só lugar, sem anúncios irritantes\n\n📖 Leia o Alcorão Sagrado com um design calmo e confortável com interpretações precisas\n🕌 Horários de oração, direção de Qibla e calendário islâmico com alta precisão\n📜 Hadiths proféticos autênticos e dhikr verificados com explicações simplificadas\n🎧 Uma enorme biblioteca de áudio com 240 recitadores e 178 estações de rádio islâmicas\n📿 Tasbeeh eletrônico e uma interface moderna e fácil de usar\n\nO aplicativo é totalmente gratuito por amor a Allah. Ajude-nos a espalhá-lo (Aquele que guia para o bem é como aquele que o faz) 🚀\n\n📱 Baixar 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nNão se esqueça de nos apoiar e avaliar o aplicativo com cinco estrelas na loja para que ele alcance a todos e você se torne um parceiro na recompensa. Que Allah escreva sua recompensa e eleve seu status ⭐⭐⭐⭐⭐',
      'tr': 'Khatmah Uygulaması - Her zaman sadık yoldaşınız\n\nİhtiyacınız olan tüm ibadetleri can sıkıcı reklamlar olmadan tek bir yerde toplayan kapsamlı ve güvenilir bir İslami uygulama\n\n📖 Doğru tefsirlerle sakin ve rahat bir tasarımla Kur\'an-ı Kerim okuyun\n🕌 Yüksek doğrulukla Namaz vakitleri, Kıble yönü ve Hicri takvim\n📜 Basitleştirilmiş açıklamalarla sahih Peygamber hadisleri ve doğrulanmış zikirler\n🎧 240 hafız ve 178 İslami radyo istasyonunu içeren devasa bir ses kütüphanesi\n📿 Elektronik tespih ve modern, kullanımı kolay bir arayüz\n\nUygulama Allah rızası için tamamen ücretsizdir. Yaymamıza yardım edin (Hayra vesile olan, yapan gibidir) 🚀\n\n📱 İndir 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nBize destek olmayı ve herkesin ulaşabilmesi ve sevaplara ortak olabilmeniz için mağazada uygulamayı beş yıldızla derecelendirmeyi unutmayın. Allah mükafatınızı yazsın ve derecenizi yükseltsin ⭐⭐⭐⭐⭐',
      'ru': 'Приложение Khatmah - Ваш верный спутник во все времена\n\nКомплексное и надежное исламское приложение, которое объединяет все необходимые вам богослужения в одном месте без навязчивой рекламы\n\n📖 Читайте Священный Коран в спокойном и удобном дизайне с точными толкованиями\n🕌 Время молитв, направление Киблы и календарь Хиджры с высокой точностью\n📜 Достоверные пророческие хадисы и проверенный зикр с упрощенными объяснениями\n🎧 Огромная аудиотека, включающая 240 чтецов и 178 исламских радиостанций\n📿 Электронный тасбих и современный, простой в использовании интерфейс\n\nПриложение совершенно бесплатно ради Аллаха. Помогите нам распространить его (Указавший на благое подобен совершившему его) 🚀\n\n📱 Скачать 📱\nhttps://play.google.com/store/apps/details?id=com.khatmah.quran.yusf.app\n\nНе забудьте поддержать нас и оценить приложение в пять звезд в магазине, чтобы оно дошло до всех, и вы стали соучастником в награде. Пусть Аллах запишет вашу награду и возвысит ваш статус ⭐⭐⭐⭐⭐',
    },
  };

  final map = dict[key];
  if (map == null) return key;
  return map[langCode] ?? map['en'] ?? key;
}
