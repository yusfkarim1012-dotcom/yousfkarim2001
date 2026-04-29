import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lottie/lottie.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/initializeData.dart';
import 'package:khatmah/GlobalHelpers/messaging_helper.dart';
import 'package:khatmah/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:khatmah/features/audiopage/player/player_bar.dart';
import 'package:khatmah/features/home.dart';
import 'package:khatmah/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart' as ez;

final mediaStorePlugin = MediaStore();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _swingController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatAnimation;

  checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print(true);
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  navigateToHome(context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (builder) => const Home()),
        (route) => false);
  }

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response;
    Response response2;
    Response response3;
    if (prefs.getString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") == null ||
        prefs.getString("moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") == null ||
        prefs.getString("suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") == null) {
      try {
        if (context.locale.languageCode == "ms") {
          response = await Dio().get('http://mp3quran.net/api/v3/reciters?language=eng');
          response2 = await Dio().get('http://mp3quran.net/api/v3/moshaf?language=eng');
          response3 = await Dio().get('http://mp3quran.net/api/v3/suwar?language=eng');
        } else {
          response = await Dio().get('http://mp3quran.net/api/v3/reciters?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
          response2 = await Dio().get('http://mp3quran.net/api/v3/moshaf?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
          response3 = await Dio().get('http://mp3quran.net/api/v3/suwar?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
        }
        if (response.data != null) {
          final jsonData = json.encode(response.data['reciters']);
          prefs.setString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData);
        }
        if (response2.data != null) {
          final jsonData2 = json.encode(response2.data);
          prefs.setString("moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData2);
        }
        if (response3.data != null) {
          final jsonData3 = json.encode(response3.data['suwar']);
          prefs.setString("suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}", jsonData3);
        }
      } catch (error) {
        print('Error while storing data: $error');
      }
    }
    prefs.setInt("zikrNotificationindex", 0);
  }

  downloadAndStoreHadithData() async {
    await Future.delayed(const Duration(seconds: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("hadithlist-v2-100000-${context.locale.languageCode}") == null) {
      Response response = await Dio().get("https://hadeethenc.com/api/v1/categories/roots/?language=${context.locale.languageCode}");
      if (response.data != null) {
        final jsonData = json.encode(response.data);
        prefs.setString("categories-v2-${context.locale.languageCode}", jsonData);
        response.data.forEach((category) async {
          Response response2 = await Dio().get("https://hadeethenc.com/api/v1/hadeeths/list/?language=${context.locale.languageCode}&category_id=${category["id"]}&per_page=699999");
          if (response2.data != null) {
            final jsonData = json.encode(response2.data["data"]);
            prefs.setString("hadithlist-v2-${category["id"]}-${context.locale.languageCode}", jsonData);
            if (prefs.getString("hadithlist-v2-100000-${context.locale.languageCode}") == null) {
              prefs.setString("hadithlist-v2-100000-${context.locale.languageCode}", jsonData);
            } else {
              final dataOfOldHadithlist = json.decode(prefs.getString("hadithlist-v2-100000-${context.locale.languageCode}")!) as List<dynamic>;
              dataOfOldHadithlist.addAll(json.decode(jsonData));
              prefs.setString("hadithlist-v2-100000-${context.locale.languageCode}", json.encode(dataOfOldHadithlist));
            }
          }
        });
      }
    }
  }

  initStoragePermission() async {
    List<Permission> permissions = [Permission.storage];
    if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
      permissions.add(Permission.photos);
      permissions.add(Permission.audio);
    }
    await permissions.request();
    MediaStore.appFolder = "Khatmah";
    initMessaging();
    setOptimalDisplayMode();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _swingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _shimmerAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });
    _swingController.repeat(reverse: true);
    _shimmerController.repeat(reverse: true);
    _floatController.repeat(reverse: true);

    initHiveValues();
    checkNotificationPermission();
    downloadAndStoreHadithData();
    getAndStoreRecitersData();
    initStoragePermission();
    navigateToHome(context);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _swingController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffFFF8EE),
        body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Image.asset(
                  "assets/images/islamic_pattern_bg.png",
                  repeat: ImageRepeat.repeat,
                  opacity: const AlwaysStoppedAnimation(0.08),
                ),
              ),
              // Islamic top arch background
              Positioned(
                top: 0, left: 0, right: 0,
                child: Image.asset(
                  "assets/images/islamic_top_bg.png",
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  opacity: const AlwaysStoppedAnimation(0.65),
                ),
              ),
              // Islamic bottom mandala background
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Image.asset(
                  "assets/images/islamic_bottom_bg.png",
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  opacity: const AlwaysStoppedAnimation(0.45),
                ),
              ),

              // ── Hanging decorations from top ──
              _buildHangingDecoration(left: screenWidth * 0.12, chainLength: screenHeight * 0.08, delay: 0.0, child: _buildStar(14)),
              _buildHangingDecoration(left: screenWidth * 0.30, chainLength: screenHeight * 0.12, delay: 0.3, child: _buildStar(18)),
              _buildHangingDecoration(left: screenWidth * 0.5 - 16, chainLength: screenHeight * 0.10, delay: 0.5, child: _buildCrescent(30)),
              _buildHangingDecoration(left: screenWidth * 0.68, chainLength: screenHeight * 0.13, delay: 0.2, child: _buildStar(16)),
              _buildHangingDecoration(left: screenWidth * 0.85, chainLength: screenHeight * 0.07, delay: 0.7, child: _buildStar(12)),

              // ── Main content ──
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_fadeController, _scaleController, _floatController]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Basmala text with scale animation
                            Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Text(
                                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                                style: TextStyle(
                                  color: const Color(0xffC5A053),
                                  fontSize: 28.sp,
                                  fontFamily: 'quran',
                                  shadows: [
                                    Shadow(color: const Color(0xffC5A053).withOpacity(0.3), blurRadius: 10),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // App icon - professional rounded with golden border and glow
                            Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.r),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xffC5A053).withOpacity(0.4), blurRadius: 25, spreadRadius: 3),
                                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xffD4AF37), Color(0xffC5A053), Color(0xffB8860B)],
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(29.r),
                                    child: Image.asset(
                                      "assets/images/app_icon_new.png",
                                      height: 150.h,
                                      width: 150.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // Loading animation
                            LottieBuilder.asset(
                              "assets/images/loading.json",
                              repeat: true,
                              height: 60.h,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Floating sparkles ──
              ..._buildSparkles(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a hanging decoration (star/crescent) from the top with swing animation
  Widget _buildHangingDecoration({
    required double left,
    required double chainLength,
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _swingController,
      builder: (context, _) {
        final swingValue = sin((_swingController.value + delay) * pi * 2) * 0.06;
        return Positioned(
          top: 0,
          left: left,
          child: Transform.rotate(
            angle: swingValue,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                // Chain line
                Container(
                  width: 1.2,
                  height: chainLength,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xffC5A053).withOpacity(0.1),
                        const Color(0xffC5A053).withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                // The hanging decoration with shimmer
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: 0.4 + (_shimmerAnimation.value * 0.6),
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStar(double size) {
    return Icon(
      Icons.star_rounded,
      color: const Color(0xffC5A053),
      size: size,
      shadows: [Shadow(color: const Color(0xffC5A053).withOpacity(0.5), blurRadius: 8)],
    );
  }

  Widget _buildCrescent(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.nightlight_round,
          color: const Color(0xffC5A053),
          size: size,
          shadows: [Shadow(color: const Color(0xffC5A053).withOpacity(0.5), blurRadius: 12)],
        ),
        Positioned(
          top: -2,
          right: 2,
          child: Icon(Icons.star_rounded, color: const Color(0xffC5A053), size: size * 0.35),
        ),
      ],
    );
  }

  List<Widget> _buildSparkles(double screenWidth, double screenHeight) {
    final random = Random(42);
    return List.generate(12, (index) {
      final left = random.nextDouble() * screenWidth;
      final top = screenHeight * 0.2 + random.nextDouble() * screenHeight * 0.6;
      final size = 3.0 + random.nextDouble() * 5.0;
      final phaseDelay = random.nextDouble();
      return AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          final shimmerVal = sin((_shimmerController.value + phaseDelay) * pi * 2) * 0.5 + 0.5;
          return Positioned(
            left: left,
            top: top,
            child: Opacity(
              opacity: shimmerVal * 0.5,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffC5A053),
                  boxShadow: [BoxShadow(color: const Color(0xffC5A053).withOpacity(0.4), blurRadius: size * 2)],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
