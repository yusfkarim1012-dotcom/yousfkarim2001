import 'package:flutter/material.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

class IslamicBackground extends StatelessWidget {
  final Widget child;

  const IslamicBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode") ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1C1815) : const Color(0xffFFF8EE),
        image: DecorationImage(
          image: const AssetImage("assets/images/islamic_pattern_bg.png"),
          repeat: ImageRepeat.repeat,
          opacity: isDark ? 0.05 : 0.15,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/islamic_top_bg.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            opacity: isDark ? 0.15 : 0.4,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/images/islamic_bottom_bg.png"),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              opacity: isDark ? 0.15 : 0.4,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
