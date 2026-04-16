import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/features/qibla/q_compass.dart';
import 'package:khatmah/features/qibla/qibla_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _isCustomCompass = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: darkPrimaryColor,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/images/tasbeehbackground.png",
              ),
              alignment: Alignment.center,
              opacity: .05)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'qibla'.tr(),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white.withOpacity(.9)),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 20.h),
            // Toggle Switch
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50.w),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.black26, 
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCustomCompass = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                            color: _isCustomCompass ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Compass", // Localization key if needed
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: _isCustomCompass ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCustomCompass = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                            color: !_isCustomCompass ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Native", // Localization key if needed
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: !_isCustomCompass ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Expanded(
            //   child: _isCustomCompass 
            //       ? const CustomCompassBody() 
            //       : const NativeCompass(),
            // ),
          ],
        ),
      ),
    );
  }
}
