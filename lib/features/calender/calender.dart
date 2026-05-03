import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart' as j;
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:flutter/material.dart' as m;
import 'package:jhijri_picker/jhijri_picker.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
// import 'package:jhijri_picker/jhijri_picker.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  int index = 1;
  final ValueNotifier<DateTime> _dateNotifier = ValueNotifier(DateTime.now());
  var _selectedDate = DateTime.now();
  var date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
      appBar: AppBar(
        title: Text(
          "calender".tr(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:  getValue("darkMode")
              ? darkModeSecondaryColor
              :  blueColor,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30.h,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: index == 0 ? Theme.of(context).textTheme.copyWith(
                  bodyMedium: TextStyle(fontSize: 20.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  bodyLarge: TextStyle(fontSize: 20.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  bodySmall: TextStyle(fontSize: 18.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  labelSmall: TextStyle(fontSize: 18.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  labelLarge: TextStyle(fontSize: 20.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  titleSmall: TextStyle(fontSize: 20.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                  titleMedium: TextStyle(fontSize: 20.sp, fontFamily: 'cairo', fontWeight: FontWeight.bold),
                ) : Theme.of(context).textTheme.copyWith(
                  bodyMedium: const TextStyle(fontFamily: 'cairo'),
                  bodySmall: const TextStyle(fontFamily: 'cairo'),
                ),
              ),
              child: JGlobalDatePicker(
                widgetType: WidgetType.JContainer,
                pickerType: index == 0 ? PickerType.JHijri : PickerType.JNormal,
                buttons: const SizedBox(),
                primaryColor: blueColor,
                calendarTextColor: getValue("darkMode") ? Colors.white : Colors.black,
                backgroundColor: getValue("darkMode") ? const Color(0xff1C1815) : Colors.white,
                borderRadius: const Radius.circular(10),
              headerTitle: Container(
                decoration:  BoxDecoration(color:  getValue("darkMode")
              ? darkModeSecondaryColor
              : blueColor),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            index = 0;
                          });
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "calender".tr(),
                              style: TextStyle(
                                  color: index == 0 
                                      ? getValue("darkMode")
              ? Colors.white
              :  Colors.black
                                      : getValue("darkMode")
              ? Colors.white24
              :  Colors.black26,
                                  fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            index = 1;
                          });
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "normalCalender".tr(),
                              style: TextStyle(
                                  color: index == 1
                                      ? getValue("darkMode")
              ? Colors.white
              :  Colors.black
                                      : getValue("darkMode")
              ? Colors.white24
              :  Colors.black26,
                                  fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              startDate: JDateModel(dateTime: DateTime.parse("1984-12-24")),
              selectedDate: JDateModel(dateTime: _selectedDate),
              endDate: JDateModel(dateTime: DateTime.parse("2030-09-20")),
              pickerMode: DatePickerMode.day,
              pickerTheme: Theme.of(context),
              locale: context.locale,
              onChange: (val) {
                _selectedDate = val.date;
                _dateNotifier.value = val.date;
              },
            ),
            ),
          ),
          SizedBox(
            height: 50.h,
          ),
          Container(
            decoration: BoxDecoration(
              color: getValue("darkMode") ? const Color(0xff1C1815) : Colors.white,
              borderRadius: BorderRadius.circular(20.r)
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: getValue("darkMode") ? Colors.white.withOpacity(0.05) : const Color(0x3BFFDC69),
                  borderRadius: BorderRadius.circular(20.r)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _dateNotifier,
                    builder: (context, currentDate, child) {
                      String hijriDate = j.HijriCalendar.fromDate(currentDate).toFormat("dd - MMMM - yyyy");
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            hijriDate,
                            style: TextStyle(
                              color: getValue("darkMode") ? Colors.white : Colors.black, 
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'cairo'
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DateFormat.yMMMEd(context.locale.languageCode).format(currentDate),
                            style: TextStyle(
                              color: getValue("darkMode") ? Colors.white70 : Colors.black87, 
                              fontSize: 16.sp,
                              fontFamily: 'cairo'
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
