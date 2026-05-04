import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart' as j;
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/GlobalHelpers/translations.dart';
import 'jhijri_picker/jhijri_picker.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late TabController _tabCtrl;
  final ValueNotifier<DateTime> _dateNotifier = ValueNotifier(DateTime.now());
  var _selectedDate = DateTime.now();

  // Gold / Islamic palette
  static const Color _gold = Color(0xffC5A053);
  static const Color _darkBg = Color(0xff1C1815);
  static const Color _darkCard = Color(0xff2A2520);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) {
        setState(() => _tabIndex = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _dateNotifier.dispose();
    super.dispose();
  }

  String _fmtN(String s) {
    final lang = context.locale.languageCode;
    if (lang != 'ar') return s;
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(western[i], arabic[i]);
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = getValue("darkMode");
    final bg = isDark ? _darkBg : const Color(0xffFFFDF7);
    final textColor = isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E);

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // --- Sliver AppBar ---
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? _darkCard : const Color(0xff2A6048),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xff1E4A38), const Color(0xff162E24)]
                        : [const Color(0xff2A6048), const Color(0xff1B5E3B)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30.w,
                      top: -20.h,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20.w,
                      bottom: 30.h,
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 0),
                        child: ValueListenableBuilder<DateTime>(
                          valueListenable: _dateNotifier,
                          builder: (context, currentDate, _) {
                            final hijri = j.HijriCalendar.fromDate(currentDate);
                            final hijriStr = hijri.toFormat("dd MMMM yyyy");
                            final gregStr = DateFormat.yMMMMEEEEd(
                                    context.locale.languageCode)
                                .format(currentDate);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Hijri date big
                                Text(
                                  _fmtN(hijriStr),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo',
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                // Gregorian date smaller
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    _fmtN(gregStr),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13.sp,
                                      fontFamily: 'cairo',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.h),
              child: Container(
                color: isDark ? _darkCard : const Color(0xff2A6048),
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: _gold,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: tGlobal('hijri_calendar', context.locale.languageCode)),
                    Tab(text: "normalCalender".tr()),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // --- Hijri Tab ---
            _buildCalendarTab(isDark, bg, textColor, PickerType.JHijri),
            // --- Normal Tab ---
            _buildCalendarTab(isDark, bg, textColor, PickerType.JNormal),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab(
      bool isDark, Color bg, Color textColor, PickerType type) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      children: [
        // Calendar picker card
        Container(
          decoration: BoxDecoration(
            color: isDark ? _darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? _gold.withOpacity(0.2)
                  : const Color(0xffD4C4A0).withOpacity(0.5),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xff8B6914).withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: type == PickerType.JHijri
                    ? Theme.of(context).textTheme.copyWith(
                        bodyMedium: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        bodyLarge: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        bodySmall: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        labelSmall: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        labelLarge: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        titleSmall: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                        titleMedium: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold),
                      )
                    : Theme.of(context).textTheme.copyWith(
                        bodyMedium: const TextStyle(fontFamily: 'cairo'),
                        bodySmall: const TextStyle(fontFamily: 'cairo'),
                      ),
              ),
              child: JGlobalDatePicker(
                widgetType: WidgetType.JContainer,
                pickerType: type,
                buttons: const SizedBox(),
                primaryColor: _gold,
                calendarTextColor: isDark ? Colors.white : Colors.black,
                backgroundColor: isDark ? _darkCard : Colors.white,
                borderRadius: const Radius.circular(0),
                headerTitle: const SizedBox(),
                startDate:
                    JDateModel(dateTime: DateTime.parse("1984-12-24")),
                selectedDate: JDateModel(dateTime: _selectedDate),
                endDate:
                    JDateModel(dateTime: DateTime.parse("2030-09-20")),
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
        ),

        SizedBox(height: 16.h),

        // Selected date info card
        ValueListenableBuilder<DateTime>(
          valueListenable: _dateNotifier,
          builder: (context, currentDate, _) {
            final hijri = j.HijriCalendar.fromDate(currentDate);
            final hijriStr = hijri.toFormat("dd MMMM yyyy");
            final gregStr = DateFormat.yMMMMEEEEd(context.locale.languageCode)
                .format(currentDate);

            return Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xff2A2520), const Color(0xff1C1815)]
                      : [Colors.white, const Color(0xffFFFDF7)],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark
                      ? _gold.withOpacity(0.3)
                      : const Color(0xffD4C4A0).withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xff8B6914).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(isDark ? 0.15 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: _gold,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Hijri
                  Text(
                    _fmtN(hijriStr),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xff2C1810),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'cairo',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Divider
                  Container(
                    width: 40.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Gregorian
                  Text(
                    _fmtN(gregStr),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xff755C26),
                      fontSize: 14.sp,
                      fontFamily: 'cairo',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
