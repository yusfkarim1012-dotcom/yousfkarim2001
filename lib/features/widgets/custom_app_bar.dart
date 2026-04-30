import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/features/widgets/custom_back_button.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode") ?? false;
    Color iconColor = isDark ? const Color(0xffF0E0C0) : const Color(0xff5C4A1E);
    Color titleColor = isDark ? Colors.white : const Color(0xff2C1810);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontFamily: 'cairo',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const CustomBackButton(),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
