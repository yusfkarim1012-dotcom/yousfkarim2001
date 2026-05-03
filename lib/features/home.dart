import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
// import 'package:alert_system/alert_overlay_plugin.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:khatmah/blocs/bloc/hadith_bloc.dart';
import 'package:khatmah/blocs/bloc/player_bloc_bloc.dart';
import 'package:khatmah/blocs/bloc/quran_page_player_bloc.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/initializeData.dart';
import 'package:khatmah/features/QuranPages/helpers/convertNumberToAr.dart';
import 'package:khatmah/features/QuranPages/views/quran_sura_list.dart';
import 'package:khatmah/features/QuranPages/views/quranDetailsPage.dart';
import 'package:khatmah/features/QuranPages/views/screenshot_preview.dart';
import 'package:khatmah/features/allah_names/allah_names_page.dart';
import 'package:khatmah/features/audiopage/player/player_bar.dart';
import 'package:khatmah/features/audiopage/views/audio_home_page.dart';
import 'package:khatmah/features/azkar/views/azkar_homepage.dart';
import 'package:khatmah/features/calender/calender.dart';

import 'package:khatmah/features/hadith/views/hadithbookspage.dart';
import 'package:khatmah/features/live_tv/live_tv_page.dart';
import 'package:khatmah/features/notifications/data/40hadith.dart';
import 'package:khatmah/features/notifications/views/all_notification_page.dart';
import 'package:khatmah/features/qibla/q_compass.dart';
import 'package:khatmah/features/home_widgets.dart';
import 'package:khatmah/features/prayer_times/prayer_times_page.dart';
import 'package:khatmah/features/calender/calender.dart';
import 'package:khatmah/features/qibla/qibla_page.dart';
import 'package:khatmah/features/radio_page/radio_page.dart';
import 'package:khatmah/features/shortvideos/shortvideos.dart';
import 'package:khatmah/features/sibha/sibha_page.dart';
import 'package:khatmah/features/support/support_page.dart';
// import 'package:periodic_alarm/model/alarms_model.dart';
// import 'package:periodic_alarm/periodic_alarm.dart';
// import 'package:periodic_alarm/services/alarm_notification.dart';
// import 'package:periodic_alarm/services/alarm_storage.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:string_validator/string_validator.dart';

import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:after_layout/after_layout.dart';
import 'package:workmanager/workmanager.dart';
import 'package:khatmah/features/widgets/animated_islamic_decorations.dart';
// import 'package:periodic_alarm/src/android_alarm.dart';

final qurapPagePlayerBloc = QuranPagePlayerBloc();
final playerPageBloc = PlayerBlocBloc();
final playerbarBloc = PlayerBarBloc();
final hadithPageBloc = HadithBloc();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with
        AfterLayoutMixin,
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  var widgejsonData;
  var quarterjsonData;
  // BoxController boxController = BoxController();
  // StreamController<AlarmSettings> alarmStream = Alarm.ringStream;
  getAndStoreRadioData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response response;

    try {
      if (context.locale.languageCode == "ms") {
        response =
            await Dio().get('http://mp3quran.net/api/v3/radios?language=eng');
      } else {
        response = await Dio().get(
            'http://mp3quran.net/api/v3/radios?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      }
      if (response.data != null) {
        final jsonData = json.encode(response.data['radios']);
        prefs.setString(
            "radios-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData);
      }
    } catch (error) {
      print('Error while storing data: $error');
    }
  }

  StreamSubscription? _subscription;

  bool alarm = false;
  bool alarm1 = false;
  int? id;
  late int indexOfHadith = Random().nextInt(hadithes.length);
  Future<void> loadJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/surahs.json');
    var data = jsonDecode(jsonString);
    setState(() {
      widgejsonData = data;
    });
    final String jsonString2 =
        await rootBundle.loadString('assets/json/quarters.json');
    var data2 = jsonDecode(jsonString2);
    setState(() {
      quarterjsonData = data2;
    });

    //print(widgejsonData);
  }

  checkSalahNotification() {
    if (getValue("shouldShowSallyNotification") == true) {
      Workmanager().registerOneOffTask("sallahEnable", "sallahEnable");
    } else {
      Workmanager().registerOneOffTask("sallahDisable", "sallahDisable");
    }
  }

  late Timer _timer;
  // static StreamSubscription<AlarmSettings>? subscription;
  // configureSelectNotificationSubject() {
  //   _subscription2 ??= AlarmNotification.selectNotificationStream.stream
  //       .listen((String? payload) async {
  //     print("payload");
  //     print(payload);
  //     List<String> payloads = [];
  //     AlarmModel? alarmModel;
  //     payloads.add(payload!);
  //     for (var element in payloads) {
  //       if (int.tryParse(element) != null) {
  //         id = int.tryParse(element);
  //         alarmModel = PeriodicAlarm.getAlarmWithId(id!);
  //         print(id);

  //         setState(() {});
  //       } else if (element == 'Stop') {
  //         print(id);

  //         PeriodicAlarm.stop(id!);
  //       } else if (element == "") {
  //         print("------------------ ERROR");
  //         openAlarmScreen();
  //       }
  //     }
  //   });
  // }

  var _today = HijriCalendar.now();
  // Future<void> setAlarm(int id, DateTime dt, String azan, String locale) async {
  //   AlarmModel alarmModel = AlarmModel(
  //       id: id,
  //       dateTime: dt,
  //       assetAudioPath: 'assets/audio/azan.mp3',
  //       notificationTitle: locale == "ar" ? "المؤزن" : "Prayer Alarm",
  //       notificationBody: locale == "ar"
  //           ? "حان الأن موعد أذان ${prayers.where((element) => element[0] == azan).first[1]}"
  //           : 'Now is $azan time',
  //       // monday: true,
  //       // tuesday: true,
  //       // wednesday: true,
  //       // thursday: true,
  //       // friday: true,
  //       active: false,
  //       musicTime: 0,
  //       loopAudio: false,
  //       incMusicTime: 0,
  //       musicVolume: .5,
  //       incMusicVolume: .5);

  //   if (alarmModel.days.contains(true)) {
  //     PeriodicAlarm.setPeriodicAlarm(alarmModel: alarmModel);
  //   } else {
  //     PeriodicAlarm.setOneAlarm(alarmModel: alarmModel);
  //   }
  // }

  // openAlarmScreen() async {
  //   Future.delayed(const Duration(seconds: 1), () async {
  //     var alarms = await AlarmStorage.getAlarmRinging();
  //     if (alarms.isNotEmpty) {
  //       Navigator.of(context).push(
  //           CupertinoPageRoute(builder: (builder) => const AlarmScreen()));
  //     }
  //   });
  // }

  // onRingingControl() {
  //   _subscription = PeriodicAlarm.ringStream.stream.listen(
  //     (alarmModel) async {
  //       print("start listening for");
  //       openAlarmScreen();
  //       // if (alarmModel.days.contains(true)) {
  //       //   alarmModel.setDateTime = alarmModel.dateTime.add(Duration(days: 1));
  //       //   PeriodicAlarm.setPeriodicAlarm(alarmModel: alarmModel);
  //       // }
  //     },
  //   );

  //   setState(() {});
  // }

  showDialogForRate() async {
    if (getValue("timesOfAppOpen") > 2 && getValue("showedDialog") == false) {
      if (await InAppReview.instance.isAvailable()) {
        await InAppReview.instance.requestReview();
        updateValue("showedDialog", true);
      }
    }
  }

  checkInAppUpdate() async {
//   AppUpdateInfo appUpdateInfo=
// await InAppUpdate.checkForUpdate();
// appUpdateInfo.updateAvailability ==
//             UpdateAvailability.updateAvailable
//         ? () async{
//         await    InAppUpdate.performImmediateUpdate()
//                 .catchError((e) => print(e));
//           }
//         : null;
  }
  @override
  void initState() {
    showDialogForRate();
    checkInAppUpdate();
    //checkAzanRinging() ;
    checkSalahNotification();
    downloadAndStoreHadithData();
    getAndStoreRecitersData();
    updateDateData();
    getAndStoreRadioData();
    //boxController.hideBox();
    initHiveValues(); // TODO: implement initState
    super.initState();
    // boxController.hideBox();
    // AlertWindowHelper.requestPermission();
    loadJsonAsset();
    updateValue("timesOfAppOpen", getValue("timesOfAppOpen") + 1);

    // subscription = Alarm.ringStream.stream.listen((event) {
    //   print(event.notificationBody);
    // });
    // subscription!.onData((data) {
    //   print(data.notificationTitle);
    // });
    // getPrayerTimesData();

    // _timeLeftController = StreamController<Duration>();
    // _timeLeftStream = _timeLeftController.stream.asBroadcastStream();

    // // Update the time left every second
    // _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   _updateTimeLeft();
    // });
    // configureSelectNotificationSubject();
    // onRingingControl();
  }

  @override
  void dispose() {
    // AndroidAlarm.audioPlayer.dispose();

    // subscription!.cancel();
    // alarmStream.close();
    // _timeLeftController.close();
    // _timer.cancel(); // Cancel the timer

    super.dispose();
  }

  String getNativeLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'am':
        return 'አማርኛ';
      case 'jp':
        return '日本語';
      case 'ms':
        return 'Melayu';
      case 'pt':
        return 'Português';
      case 'tr':
        return 'Türkçe';
      case 'ru':
        return 'Русский';
      case 'ku':
        return 'کوردی';
      default:
        return languageCode; // Return the language code if not found
    }
  }

  late StreamController<Duration> _timeLeftController;
  late Stream<Duration> _timeLeftStream;
  downloadAndStoreHadithData() async {
    await Future.delayed(const Duration(seconds: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs
            .getString("hadithlist-v2-100000-${context.locale.languageCode}") ==
        null) {
      Response response = await Dio().get(
          "https://hadeethenc.com/api/v1/categories/roots/?language=${context.locale.languageCode}");

      if (response.data != null) {
        final jsonData = json.encode(response.data);
        prefs.setString(
            "categories-v2-${context.locale.languageCode}", jsonData);

        response.data.forEach((category) async {
          Response response2 = await Dio().get(
              "https://hadeethenc.com/api/v1/hadeeths/list/?language=${context.locale.languageCode}&category_id=${category["id"]}&per_page=699999");

          if (response2.data != null) {
            final jsonData = json.encode(response2.data["data"]);
            prefs.setString(
                "hadithlist-v2-${category["id"]}-${context.locale.languageCode}",
                jsonData);

            ///add to category of all hadithlist
            if (prefs.getString(
                    "hadithlist-v2-100000-${context.locale.languageCode}") ==
                null) {
              prefs.setString(
                  "hadithlist-v2-100000-${context.locale.languageCode}",
                  jsonData);
            } else {
              final dataOfOldHadithlist = json.decode(prefs.getString(
                      "hadithlist-v2-100000-${context.locale.languageCode}")!)
                  as List<dynamic>;
              dataOfOldHadithlist.addAll(json.decode(jsonData));
              prefs.setString(
                  "hadithlist-v2-100000-${context.locale.languageCode}",
                  json.encode(dataOfOldHadithlist));
            }
          }
        });
      }
    }

    //  if (response.data != null) {
    //       final jsonData = json.encode(response.data['reciters']);
    //       prefs.setString(
    //           "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
    //           jsonData);
    //     }
  }

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("working");
    Response response;
    Response response2;
    Response response3;
    try {
      if (context.locale.languageCode == "ms") {
        response =
            await Dio().get('http://mp3quran.net/api/v3/reciters?language=eng');
        response2 =
            await Dio().get('http://mp3quran.net/api/v3/moshaf?language=eng');
        response3 =
            await Dio().get('http://mp3quran.net/api/v3/suwar?language=eng');
      } else {
        response = await Dio().get(
            'http://mp3quran.net/api/v3/reciters?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
        response2 = await Dio().get(
            'http://mp3quran.net/api/v3/moshaf?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
        response3 = await Dio().get(
            'http://mp3quran.net/api/v3/suwar?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      }

      if (response.data != null) {
        final jsonData = json.encode(response.data['reciters']);
        prefs.setString(
            "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData);
      }
      if (response2.data != null) {
        final jsonData2 = json.encode(response2.data);
        prefs.setString(
            "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData2);
      }
      if (response3.data != null) {
        final jsonData3 = json.encode(response3.data['suwar']);
        prefs.setString(
            "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData3);
      }
      print("worked");
    } catch (error) {
      print('Error while storing data: $error');
    }

    prefs.setInt("zikrNotificationindex", 0);
  }

  DateTime dateTime = DateTime.now();

  var prayerTimes;
  bool isLoading = true;
  bool reload = false;
  getPrayerTimesData() async {
    DateTime dateTime = DateTime.now();
    if (getValue("prayerTimes/${dateTime.year}/${dateTime.month}") == null ||
        reload) {
/*
      await Geolocator.requestPermission();
      Position geolocation = await Geolocator.getCurrentPosition();
      await placemarkFromCoordinates(
              geolocation.latitude, geolocation.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        updateValue("currentCity", place.subAdministrativeArea!);
        updateValue("currentCountry", place.country!);
      });
      Response response = await Dio().get(
          "https://api.aladhan.com/v1/calendar/${dateTime.year}/${dateTime.month}?latitude=${geolocation.latitude}&longitude=${geolocation.longitude}");
      updateValue(
          "prayerTimes/${dateTime.year}/${dateTime.month}", response.data);
*/
    }
    prayerTimes = getValue("prayerTimes/${dateTime.year}/${dateTime.month}");
    if (prayerTimes == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final currentDateTime = DateTime.now();
    final currentFormattedTime =
        DateFormat('HH:mm').format(currentDateTime.toUtc());
    // setAllarmsForTheMonth();
    var prayerTimings = prayerTimes["data"][dateTime.day]["timings"];
    for (var prayer in prayerTimings.keys) {
      if (currentFormattedTime.compareTo(prayerTimings[prayer]!) < 0) {
        nextPrayer = prayer;
        nextPrayerTime = prayerTimings[prayer]!;
        break;
      }
    }

    if (nextPrayer.isEmpty ||
        nextPrayer == "Imsak" ||
        nextPrayer == "Firstthird" ||
        nextPrayer == "Midnight" ||
        nextPrayer == "Lastthird") {
      nextPrayer = 'Fajr';
      nextPrayerTime = prayerTimings['Fajr']!;
    }
    print("nextPrayer: $nextPrayer");
    print("nextPrayerTime: $nextPrayerTime");

    setState(() {
      isLoading = false;
    });
    setAllarmsForTheMonth();
    print(nextPrayer);
  }

  setAllarmsForTheMonth() async {
    await Future.delayed(const Duration(seconds: 1));
    // Loop through each data entry
    for (var entry in prayerTimes["data"]) {
      var dateInfo = entry["date"];
      var gregorianDate = dateInfo["gregorian"];
      var timings = entry["timings"];

      // Specify the prayer times you want to use
      var prayerTimesToUse = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

      // Filter out unwanted prayer times
      var filteredTimings = timings.entries
          .where((entry) => prayerTimesToUse.contains(entry.key));

      // Loop through each filtered prayer time
      for (var prayerEntry in filteredTimings) {
        var prayer = prayerEntry.key;
        var time = prayerEntry.value;
        print("prayer time: " + time);
        print("prayer" + prayer);
        // Parse the time string
        var timeComponents = time.split(' ')[0].split(':');
        var hour = int.parse(timeComponents[0]);
        var minute = int.parse(timeComponents[1].split(' ')[0]);

        // Create the DateTime object using the date and time information
        var prayerDateTime = DateTime.utc(
          int.parse(gregorianDate["year"]),
          gregorianDate["month"]["number"],
          int.parse(gregorianDate["day"]),
          hour,
          minute,
        );

        if (prayerDateTime.isBefore(DateTime.now())) {
        } else {
          // setAlarm(dateTime.month * 100 + dateTime.day+prayers.indexOf((element) => element[0]==prayer), prayerDateTime,prayer, context.locale.languageCode);
          // setAlarm(
          //     (prayerDateTime.month * prayerDateTime.month) * 10 +
          //         (prayerDateTime.day * prayerDateTime.day) * 10 +
          //         (prayers.indexWhere((element) => element[0] == prayer) + 1) *
          //             10,
          //     prayerDateTime,
          //     prayer,
          //     context.locale.languageCode);
        }

        // var alarmSettings = AlarmSettings(
        //   id: dateTime.month * 100 + dateTime.day,
        //   dateTime: prayerDateTime,
        //   assetAudioPath: 'assets/images/azan.mp3',
        //   loopAudio: false,
        //   vibrate: false,
        //   volume: 0.8,
        //   fadeDuration: 3.0,
        //   notificationTitle: 'المؤزن',
        //   notificationBody:
        //       '${prayers.where((element) => element[0] == prayer).first[1]} حان الان موعد اذان',
        //   enableNotificationOnKill: false,
        // );
        // await Alarm.set(alarmSettings: alarmSettings);
        // Print or use the prayerDateTime as needed
        // print('$prayer: $prayerDateTime');
      }
    }
    getAlarms();
    final currentDateTime = DateTime.now();
    final nextPrayerTim = DateTime.parse(
        "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}");

    prayerTimes = getValue("prayerTimes/${dateTime.year}/${dateTime.month}");
    for (var i = dateTime.day; i < prayerTimes["data"].length; i++) {
      var prayerTimings = prayerTimes["data"][i]["timings"];
    }
  }

  String nextPrayer = '';
  String nextPrayerTime = '';
  int index = 1;
  void _updateTimeLeft() {
    final currentDateTime = DateTime.now();
    final nextPrayerTim = DateTime.parse(
        "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}");
    if (nextPrayer == "Fajr") {
      if (currentDateTime.isAfter(nextPrayerTim)) {
        final currentDateTime2 = DateTime.now();
        final nextPrayerTim2 = DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}")
            .add(const Duration(days: 1));
        final timeLeft = nextPrayerTim2.difference(currentDateTime2);
        _timeLeftController.add(timeLeft);
      } else {
        if (currentDateTime.isBefore(nextPrayerTim)) {
          final timeLeft = nextPrayerTim.difference(currentDateTime);
          _timeLeftController.add(timeLeft);
        }
      }
    } else {
      if (currentDateTime.isBefore(nextPrayerTim)) {
        final timeLeft = nextPrayerTim.difference(currentDateTime);
        _timeLeftController.add(timeLeft);
      }
    }
  }

  List prayers = [
    ["Fajr", "الفجر"],
    ["Sunrise", "الشروق"],
    ["Dhuhr", "الظهر"],
    ["Asr", "العصر"],
    ["Maghrib", "المغرب"],
    ["Isha", "العشاء"]
  ];

  void _fastPush(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    ).then((value) => setState(() {}));
  }

  getLocationData() {}
  String currentCity = "";

  String currentCountry = "";
  getAlarms() async {
    // List<AlarmModel> alarms = AlarmStorage.getSavedAlarms();
    // print("alarms.length");
    // print(alarms.length);
  }

  updateDateData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    HijriCalendar.setLocal(
        rtlLanguages.contains(context.locale.languageCode) ? "ar" : "en");
    _today = HijriCalendar.now();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // print(screenSize.height);
    // print(screenSize.width);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (builder) {
            bool isDark = getValue("darkMode") ?? false;
            return Container(
              color: index == 1
                  ? (isDark ? const Color(0xff12100E) : const Color(0xffFFF8EE))
                  : darkPrimaryColor,
              child: Stack(
                children: [
                  if (index == 1)
                    Positioned.fill(
                      child: Opacity(
                        opacity: isDark ? 0.2 : 0.15,
                        child: Image.asset(
                          "assets/images/islamic_pattern_bg.png",
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          (DateTime.now().hour < 17 && DateTime.now().hour > 6)
                              ? "assets/images/daytimetry2.png"
                              : "assets/images/prayerbackgroundnight.png",
                          fit: (DateTime.now().hour < 17 &&
                                  DateTime.now().hour > 6)
                              ? BoxFit.fill
                              : BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),

                  // 2. Top Arch (Only for main screens)
                  if (index == 1)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Opacity(
                        opacity: isDark ? 0.25 : 0.5,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            "assets/images/islamic_top_bg.png",
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),

                  // 3. Bottom Mandala (Only for main screens)
                  if (index == 1)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Opacity(
                        opacity: isDark ? 0.25 : 0.5,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            "assets/images/islamic_bottom_bg.png",
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                  // 4. Floating decorations
                  if (index == 1)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: AnimatedIslamicDecorations(),
                      ),
                    ),

                  // 5. Scaffold content
                  Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 0,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                    ),
                    extendBodyBehindAppBar: true,
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      child: Container(
                        width: screenSize.width,
                        // height: screenSize.height,
                        decoration: const BoxDecoration(),
                        child: Column(
                          children: [
                            HomeHeader(
                              screenSize: screenSize,
                              onDarkModeToggle: () {
                                updateValue("darkMode", !getValue("darkMode"));
                                setState(() {});
                              },
                              onLanguageChanged: (val) {
                                context.setLocale(val);
                                getAndStoreRecitersData();
                                getAndStoreRadioData();
                                downloadAndStoreHadithData();
                                updateDateData();
                              },
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (_today != null) ...[
                                      // Date Display
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 10.h),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                              color: getValue("darkMode")
                                                  ? const Color(0xff2A2520)
                                                      .withOpacity(0.8)
                                                  : Colors.white
                                                      .withOpacity(0.85),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: getValue("darkMode")
                                                      ? Colors.black26
                                                      : const Color(0xff8B6914)
                                                          .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: getValue("darkMode")
                                                    ? const Color(0xffC5A053)
                                                        .withOpacity(0.3)
                                                    : const Color(0xffD4C4A0)
                                                        .withOpacity(0.5),
                                                width: 1,
                                              )),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Builder(builder: (context) {
                                                try {
                                                  return Text(
                                                    _today.toFormat(
                                                        "dd - MMMM - yyyy"),
                                                    style: TextStyle(
                                                        color:
                                                            getValue("darkMode")
                                                                ? const Color(
                                                                    0xffF0E0C0)
                                                                : const Color(
                                                                    0xff755C26),
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: "cairo"),
                                                  );
                                                } catch (e) {
                                                  return Container();
                                                }
                                              }),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                child: Text(
                                                  " | ",
                                                  style: TextStyle(
                                                    color: getValue("darkMode")
                                                        ? const Color(
                                                                0xffC5A053)
                                                            .withOpacity(0.5)
                                                        : const Color(
                                                            0xffD4C4A0),
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                              Builder(builder: (context) {
                                                String formattedDate;
                                                try {
                                                  formattedDate =
                                                      DateFormat.yMMMEd(context
                                                              .locale
                                                              .languageCode)
                                                          .format(
                                                              DateTime.now());
                                                } catch (e) {
                                                  formattedDate =
                                                      DateFormat.yMMMEd("en")
                                                          .format(
                                                              DateTime.now());
                                                }
                                                return Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                      color:
                                                          getValue("darkMode")
                                                              ? const Color(
                                                                  0xffF0E0C0)
                                                              : const Color(
                                                                  0xff755C26),
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: "cairo"),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Last Read & Last Bookmark Section
                                      Builder(builder: (context) {
                                        // Last Read Data
                                        int lastReadPage =
                                            getValue("lastRead") == "non"
                                                ? 1
                                                : getValue("lastRead");
                                        var pageData =
                                            quran.getPageData(lastReadPage);
                                        int surahNum = pageData[0]["surah"];
                                        String surahName = rtlLanguages
                                                .contains(
                                                    context.locale.languageCode)
                                            ? quran.getSurahNameArabic(surahNum)
                                            : quran.getSurahName(surahNum);
                                        int juzNum = quran.getJuzNumber(
                                            surahNum, pageData[0]["start"]);

                                        // Last Bookmark Data
                                        List bookmarksList =
                                            json.decode(getValue("bookmarks"));
                                        var lastBookmark =
                                            bookmarksList.isNotEmpty
                                                ? bookmarksList.last
                                                : null;

                                        if (lastBookmark != null) {
                                          // Show side by side
                                          int bSurahNum = int.parse(
                                              (lastBookmark["suraNumber"] ?? 1)
                                                  .toString());
                                          int bVerseNum = int.parse(
                                              (lastBookmark["verseNumber"] ?? 1)
                                                  .toString());
                                          int bPageNum = quran.getPageNumber(
                                              bSurahNum, bVerseNum);
                                          String bSurahName = rtlLanguages
                                                  .contains(context
                                                      .locale.languageCode)
                                              ? quran
                                                  .getSurahNameArabic(bSurahNum)
                                              : quran.getSurahName(bSurahNum);

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: LastReadCard(
                                                    surahName: surahName,
                                                    pageNumber: lastReadPage,
                                                    juzNumber: juzNum,
                                                    isHalfWidth: true,
                                                    onTap: () {
                                                      _fastPush(
                                                          QuranDetailsPage(
                                                        pageNumber:
                                                            lastReadPage,
                                                        jsonData: widgejsonData,
                                                        shouldHighlightText:
                                                            false,
                                                        highlightVerse: "",
                                                        quarterJsonData:
                                                            quarterjsonData,
                                                        shouldHighlightSura:
                                                            false,
                                                      ));
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: BookmarkCard(
                                                    surahName: bSurahName,
                                                    bookmarkName:
                                                        lastBookmark["name"] ??
                                                            "",
                                                    verseNumber: bVerseNum,
                                                    isHalfWidth: true,
                                                    onTap: () {
                                                      _fastPush(
                                                          QuranDetailsPage(
                                                        pageNumber: bPageNum,
                                                        jsonData: widgejsonData,
                                                        shouldHighlightText:
                                                            true,
                                                        highlightVerse:
                                                            quran.getVerse(
                                                                bSurahNum,
                                                                bVerseNum),
                                                        quarterJsonData:
                                                            quarterjsonData,
                                                        shouldHighlightSura:
                                                            false,
                                                      ));
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          // Show only Last Read full width
                                          return LastReadCard(
                                            surahName: surahName,
                                            pageNumber: lastReadPage,
                                            juzNumber: juzNum,
                                            onTap: () {
                                              _fastPush(QuranDetailsPage(
                                                pageNumber: lastReadPage,
                                                jsonData: widgejsonData,
                                                shouldHighlightText: false,
                                                highlightVerse: "",
                                                quarterJsonData:
                                                    quarterjsonData,
                                                shouldHighlightSura: false,
                                              ));
                                            },
                                          );
                                        }
                                      }),
                                    ],

                                    SizedBox(height: 20.h),

                                    // Feature Grid
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.9,
                                        children: [
                                          HomeGridItem(
                                              text: "quran".tr(),
                                              imagePath:
                                                  "assets/images/qlogo.png",
                                              onPressed: () {
                                                _fastPush(SurahListPage(
                                                    jsonData: widgejsonData,
                                                    quarterjsonData:
                                                        quarterjsonData));
                                              }),
                                          HomeGridItem(
                                              text: "audios".tr(),
                                              imagePath:
                                                  "assets/images/quranlogo.png",
                                              onPressed: () {
                                                _fastPush(BlocProvider.value(
                                                    value: playerPageBloc,
                                                    child: RecitersPage(
                                                        jsonData:
                                                            widgejsonData)));
                                              }),
                                          HomeGridItem(
                                              text: "Hadith".tr(),
                                              imagePath:
                                                  "assets/images/muhammed.png",
                                              onPressed: () {
                                                _fastPush(BlocProvider.value(
                                                    value: hadithPageBloc,
                                                    child: HadithBooksPage(
                                                        locale: context.locale
                                                            .languageCode)));
                                              }),
                                          HomeGridItem(
                                              text: rtlLanguages.contains(context.locale.languageCode)
                                                  ? "القبلة" : "Qibla",
                                              imagePath:
                                                  "assets/images/kabaa.png",
                                              onPressed: () {
                                                _fastPush(
                                                    const QiblaPage());
                                              }),

                                          HomeGridItem(
                                              text: rtlLanguages.contains(context.locale.languageCode)
                                                  ? "مواقيت الصلاة" : "Prayer Times",
                                              imagePath:
                                                  "assets/images/prayer_times_icon.png",
                                              onPressed: () {
                                                _fastPush(
                                                    const PrayerTimesPage());
                                              }),

                                          HomeGridItem(
                                              text: "calender".tr(),
                                              imagePath:
                                                  "assets/images/hijri_calendar_icon.png",
                                              onPressed: () {
                                                _fastPush(
                                                    const CalenderPage());
                                              }),

                                          HomeGridItem(
                                              text: "azkar".tr(),
                                              imagePath:
                                                  "assets/images/azkar.png",
                                              onPressed: () {
                                                _fastPush(
                                                    const AzkarHomePage());
                                              }),

                                          HomeGridItem(
                                              text: "sibha".tr(),
                                              imagePath:
                                                  "assets/images/sibha.png",
                                              onPressed: () {
                                                _fastPush(const SibhaPage());
                                              }),

                                          HomeGridItem(
                                              text: "radios".tr(),
                                              imagePath:
                                                  "assets/images/radio.png",
                                              onPressed: () {
                                                _fastPush(const RadioPage());
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 100.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // boxController.hideBox();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  // AlarmModel? alarmModel;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getAlarm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getAlarm() async {
    // List<String> alarms = await AlarmStorage.getAlarmRinging();
    // AlarmModel? alarm = AlarmStorage.getAlarm(int.parse(alarms.last));

    // alarmModel = alarm;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final alarmModel = ModalRoute.of(context)!.settings.arguments as AlarmModel;
    return Scaffold(
      body: Container(
        child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/praying.png"))),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              // alarmModel!.notificationTitle!,
                              "",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "armModel!.notificationBody!",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EasyContainer(
                                borderRadius: 25,
                                customPadding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                onTap: () {
                                  // PeriodicAlarm.stop(alarmModel!.id);
                                  Navigator.of(context)
                                      .popUntil(ModalRoute.withName('/'));
                                },
                                child: const Text('Stop the Azan')),
                          ],
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }
}
