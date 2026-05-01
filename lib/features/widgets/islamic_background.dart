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
      color: isDark ? const Color(0xff12100E) : const Color(0xffFFF8EE),
      child: Stack(
        children: [
          // 1. Pattern (Full fill)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.2 : 0.15,
              child: Image.asset(
                "assets/images/islamic_pattern_bg.png",
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          // 2. Top Arch
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
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
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
          // 3. Bottom Mandala
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
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
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
          // 4. Content
          child,
        ],
      ),
    );
  }
}
