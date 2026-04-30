import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode") ?? false;
    Color iconColor = isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? const Color(0xffC5A053).withOpacity(0.3) : const Color(0xffD4C4A0).withOpacity(0.6),
          ),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: iconColor,
            size: 20.sp,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
