import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

class AnimatedIslamicDecorations extends StatefulWidget {
  const AnimatedIslamicDecorations({Key? key}) : super(key: key);

  @override
  State<AnimatedIslamicDecorations> createState() => _AnimatedIslamicDecorationsState();
}

class _AnimatedIslamicDecorationsState extends State<AnimatedIslamicDecorations> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 3500 + (index * 700)),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = getValue("darkMode") ?? false;
    
    // Adjusted colors based on user request: White for night, soft bronze for day
    Color ropeColor = isDark 
        ? Colors.white.withOpacity(0.4) 
        : const Color(0xffA08040).withOpacity(0.5);
    
    Color iconColor = isDark 
        ? Colors.white // White for night as requested
        : const Color(0xff705820); // Harmonious bronze for day (not too black)

    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Stack(
          children: [
            // 1. Moon (Left)
            _buildHangingItem(
              left: 45,
              ropeLength: 85,
              controller: _controllers[0],
              icon: Icons.brightness_2_rounded, // Better crescent shape
              size: 28,
              ropeColor: ropeColor,
              iconColor: iconColor,
              delayPhase: 0.0,
            ),
            // 2. Star (Mid-Left)
            _buildHangingItem(
              left: MediaQuery.of(context).size.width * 0.32,
              ropeLength: 130,
              controller: _controllers[1],
              icon: Icons.star_rounded,
              size: 22,
              ropeColor: ropeColor,
              iconColor: iconColor,
              delayPhase: 1.2,
            ),
            // 3. Star (Mid-Right)
            _buildHangingItem(
              right: MediaQuery.of(context).size.width * 0.32,
              ropeLength: 150,
              controller: _controllers[2],
              icon: Icons.star_rounded,
              size: 24,
              ropeColor: ropeColor,
              iconColor: iconColor,
              delayPhase: 0.7,
            ),
            // 4. Moon (Right)
            _buildHangingItem(
              right: 45,
              ropeLength: 75,
              controller: _controllers[3],
              icon: Icons.brightness_2_rounded,
              size: 30,
              ropeColor: ropeColor,
              iconColor: iconColor,
              delayPhase: 1.8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHangingItem({
    double? left,
    double? right,
    required double ropeLength,
    required AnimationController controller,
    required IconData icon,
    required double size,
    required Color ropeColor,
    required Color iconColor,
    required double delayPhase,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: -10,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          double value = Curves.easeInOutSine.transform(controller.value);
          double swingAngle = math.sin((value * 2 * math.pi) + delayPhase) * 0.06;
          
          return Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.rotationZ(swingAngle),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 1.2,
                  height: ropeLength,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ropeColor.withOpacity(0.0),
                        ropeColor,
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: size,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
