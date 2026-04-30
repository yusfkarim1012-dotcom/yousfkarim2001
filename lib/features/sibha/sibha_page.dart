import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/sibha/models/tasbeh.dart';
import 'package:khatmah/features/sibha/widgets/add_tasbeeh_dialog.dart';
import 'package:khatmah/features/widgets/custom_app_bar.dart';
import 'package:khatmah/features/widgets/islamic_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SibhaPage extends StatefulWidget {
  const SibhaPage({super.key});

  @override
  State<SibhaPage> createState() => _SibhaPageState();
}

class _SibhaPageState extends State<SibhaPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  // All 6 tally counter skin images
  final List<String> _skinImages = [
    "assets/images/20.png",  // brick/fiery (moved to first as requested)
    "assets/images/18.png",  // roses
    "assets/images/3.png",   // pink/blue floral
    "assets/images/4.png",   // wood
    "assets/images/7.png",   // marble
    "assets/images/9.png",   // green islamic
  ];

  int _currentSkinIndex = 0;
  bool _isCountPressed = false;
  bool _isResetPressed = false;

  List<Tasbeeh> tasbeehList = [
    Tasbeeh(id: 0, arabic: 'الحمد لله', translation: 'Praise be to Allah', pronunciation: 'Al-ham-du li-lah'),
    Tasbeeh(id: 1, arabic: 'الله اكبر', translation: 'Allah is the Greatest', pronunciation: 'Al-lah-hu Ak-bar'),
    Tasbeeh(id: 2, arabic: 'استغفر الله', translation: 'I seek forgiveness from Allah', pronunciation: 'As-tag-fir-ul-lah'),
    Tasbeeh(id: 3, arabic: 'لا اله الا الله', translation: 'There is no god but Allah', pronunciation: 'La ila-ha ill-al-lah'),
    Tasbeeh(id: 4, arabic: 'سبحان الله', translation: 'Glory be to Allah', pronunciation: 'Sub-han Allah'),
    Tasbeeh(id: 5, arabic: 'سبحان الله وبحمده سبحان الله العظيم', translation: 'Glory be to Allah, and praise is due to Him, glory be to Allah the Great', pronunciation: 'Sub-han Allah wa bi-ham-di-hi Sub-han Allah al-a-zeem'),
    Tasbeeh(id: 6, arabic: 'سبحان الله والحمد لله ولا اله الا الله والله اكبر', translation: 'Glory be to Allah, and praise is due to Allah, and there is no god but Allah, and Allah is the Greatest', pronunciation: 'Sub-han Allah wa al-ham-du li-lah wa la ila-ha ill-al-lah wa Al-lah Ak-bar'),
    Tasbeeh(id: 7, arabic: 'لا إله إلا أنت سبحانك إني كنت من الظالمين', translation: 'There is no god but You, glory be to You; surely I am of those who are unjust', pronunciation: 'La ila-ha ill-a an-ta Sub-ha-na-ka in-ni ku-n-tu min az-zal-li-meen'),
    Tasbeeh(id: 8, arabic: 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام', translation: 'O Allah, You are the Peace, and from You comes peace; Blessed are You, O Possessor of Majesty and Honor', pronunciation: 'Al-lah-ma an-ta as-Sa-laam wa min-ka as-Sa-laam ta-ba-ra-kat ya dha al-ja-la-li wal-i-kraam'),
    Tasbeeh(id: 9, arabic: 'اللهم صل وسلم وبارك على سيدنا محمد', translation: 'O Allah, send peace and blessings upon our Master Muhammad', pronunciation: 'Al-lah-ma sal-li wa sal-lim wa ba-rik ala sa-yi-di-na Mu-ham-mad'),
    Tasbeeh(id: 10, arabic: 'الله أكبر كبيرا  والحمد لله كثيرا  وسبحان الله بكرة وأصيلا', translation: 'Allah is the Greatest, greatly, and praise be to Allah abundantly, and glory be to Allah in the morning and the evening', pronunciation: 'Al-lah Ak-bar kabee-ra wa al-ham-du li-lah ka-thee-ra wa Sub-han Al-lah bu-ka-ra wa a-shee-la'),
    Tasbeeh(id: 11, arabic: 'لا إله إلا الله وحده لا شريك له له الملك وله الحمد وهو على كل شيء قدير', translation: 'There is no god but Allah alone, He has no partner, His is the sovereignty, and His is the praise, and He has power over everything', pronunciation: 'La ila-ha ill-a al-lah wa-hda-hu la shar-ee-ka la-hu la-hu al-mul-ku wa la-hu al-ham-du wa hu-wa ala ku-l-lee shay-in qa-deer'),
    Tasbeeh(id: 12, arabic: 'سبحان الله وبحمده  سبحان الله العظيم', translation: 'Glory be to Allah, and praise be to Him; glory be to Allah the Great', pronunciation: 'Sub-han Al-lah wa bi-ham-di-hi  Sub-han Al-lah al-a-zeem'),
  ];

  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  PageController tasbeehScrollController = PageController(initialPage: 0);

  bool _isOverlayActive = false;
  int _overlaySizeIndex = 2; // 0 = Small, 1 = Medium, 2 = Large

  StreamSubscription? _overlaySubscription;

  @override
  void initState() {
    super.initState();
    try {
      _overlaySizeIndex = getValue("overlaySizeIndex") ?? 2;
      _currentSkinIndex = getValue("sibhaSkinIndex") ?? 0;
      if (_currentSkinIndex >= _skinImages.length) _currentSkinIndex = 0;
      tasbeehScrollController = PageController(initialPage: getValue("tasbeehLastIndex") ?? 0);
      loadTasbeehs();
      _tapController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
      );
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
      );
      _syncFromOverlay(); // sync count back from overlay if it was active
      _checkOverlayStatus();
      
      _overlaySubscription = FlutterOverlayWindow.overlayListener.listen((event) {
        if (event is Map) {
          if (event['type'] == 'update_count') {
            final lastIndex = getValue("tasbeehLastIndex") ?? 0;
            updateValue("${lastIndex}number", event['count']);
            if (mounted) setState(() {});
          } else if (event['type'] == 'overlay_closed') {
            _syncFromOverlay();
            if (mounted) setState(() => _isOverlayActive = false);
          }
        }
      }, onError: (e) {
        debugPrint("Overlay stream error: $e");
      });
      WidgetsBinding.instance.addObserver(this);
    } catch (e, stack) {
      debugPrint("InitState Error: $e\n$stack");
    }
  }

  @override
  void dispose() {
    _overlaySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tapController.dispose();
    tasbeehScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkOverlayStatus();
      _syncFromOverlay();
    }
  }

  /// Check if overlay is currently active and update the icon state
  Future<void> _checkOverlayStatus() async {
    final active = await FlutterOverlayWindow.isActive();
    if (mounted) {
      setState(() {
        _isOverlayActive = active;
      });
    }
  }

  /// Sync the counter value back from SharedPreferences (written by overlay)
  Future<void> _syncFromOverlay() async {
    final prefs = await SharedPreferences.getInstance();
    final overlayCount = prefs.getInt('overlay_tasbih_count');
    if (overlayCount != null && overlayCount > 0) {
      final lastIndex = getValue("tasbeehLastIndex") ?? 0;
      updateValue("${lastIndex}number", overlayCount);
      if (mounted) setState(() {});
    }
  }

  /// Toggle the floating Tasbih overlay on/off
  Future<void> _toggleOverlay() async {
    try {
      // 1. Check & request permission
      final bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        final bool? granted = await FlutterOverlayWindow.requestPermission();
        if (granted != true) {
          Fluttertoast.showToast(
            msg: "يرجى السماح بالعرض فوق التطبيقات",
            backgroundColor: Colors.red,
          );
          return;
        }
      }

      // 2. If overlay is already active, close it and sync data back
      final bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 200));
        await _syncFromOverlay();
        if (mounted) setState(() => _isOverlayActive = false);
        return;
      }

      // 3. Write current state to SharedPreferences for the overlay to read
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('overlay_mode', 'tasbih');

      final lastIndex = getValue("tasbeehLastIndex") ?? 0;
      final currentCount = getValue("${lastIndex}number") ?? 0;
      await prefs.setInt('overlay_tasbih_count', currentCount);

      if (lastIndex < tasbeehList.length) {
        await prefs.setString('overlay_tasbih_zikr', tasbeehList[lastIndex].arabic);
      }

      await _saveSkinForOverlay();

      int h = 700;
      int w = 450;
      if (_overlaySizeIndex == 0) { h = 500; w = 320; }
      else if (_overlaySizeIndex == 1) { h = 620; w = 400; }
      else if (_overlaySizeIndex == 2) { h = 700; w = 450; }

      // 4. Show the overlay
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Tasbih",
        overlayContent: 'Tasbih Counter',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.none, // free drag anywhere on screen
        height: h,
        width: w,
      );

      if (mounted) setState(() => _isOverlayActive = true);

    } catch (e, stack) {
      Fluttertoast.showToast(
        msg: "خەبات: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
      debugPrint("OVERLAY ERROR: $e\n$stack");
    }
  }

  Future<void> _saveSkinForOverlay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ByteData imgData = await rootBundle.load(_skinImages[_currentSkinIndex]);
      final Directory tmpDir = Directory.systemTemp;
      final File skinFile = File('${tmpDir.path}/overlay_skin_${_currentSkinIndex}.png');
      await skinFile.writeAsBytes(imgData.buffer.asUint8List());
      await prefs.setString('overlay_skin_path', skinFile.path);
      
      if (_isOverlayActive) {
        await FlutterOverlayWindow.shareData({
          "type": "update_skin",
          "skinPath": skinFile.path,
        });
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('overlay_skin_path');
    }
  }

  void loadTasbeehs() {
    List<Tasbeeh> initialList = [
      Tasbeeh(id: 0, arabic: 'الحمد لله', translation: 'Praise be to Allah', pronunciation: 'Al-ham-du li-lah'),
      Tasbeeh(id: 1, arabic: 'الله اكبر', translation: 'Allah is the Greatest', pronunciation: 'Al-lah-hu Ak-bar'),
      Tasbeeh(id: 2, arabic: 'استغفر الله', translation: 'I seek forgiveness from Allah', pronunciation: 'As-tag-fir-ul-lah'),
      Tasbeeh(id: 3, arabic: 'لا اله الا الله', translation: 'There is no god but Allah', pronunciation: 'La ila-ha ill-al-lah'),
      Tasbeeh(id: 4, arabic: 'سبحان الله', translation: 'Glory be to Allah', pronunciation: 'Sub-han Allah'),
      Tasbeeh(id: 5, arabic: 'سبحان الله وبحمده سبحان الله العظيم', translation: 'Glory be to Allah, and praise is due to Him, glory be to Allah the Great', pronunciation: 'Sub-han Allah wa bi-ham-di-hi Sub-han Allah al-a-zeem'),
      Tasbeeh(id: 6, arabic: 'سبحان الله والحمد لله ولا اله الا الله والله اكبر', translation: 'Glory be to Allah, and praise is due to Allah, and there is no god but Allah, and Allah is the Greatest', pronunciation: 'Sub-han Allah wa al-ham-du li-lah wa la ila-ha ill-al-lah wa Al-lah Ak-bar'),
      Tasbeeh(id: 7, arabic: 'لا إله إلا أنت سبحانك إني كنت من الظالمين', translation: 'There is no god but You, glory be to You; surely I am of those who are unjust', pronunciation: 'La ila-ha ill-a an-ta Sub-ha-na-ka in-ni ku-n-tu min az-zal-li-meen'),
      Tasbeeh(id: 8, arabic: 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام', translation: 'O Allah, You are the Peace, and from You comes peace; Blessed are You, O Possessor of Majesty and Honor', pronunciation: 'Al-lah-ma an-ta as-Sa-laam wa min-ka as-Sa-laam ta-ba-ra-kat ya dha al-ja-la-li wal-i-kraam'),
      Tasbeeh(id: 9, arabic: 'اللهم صل وسلم وبارك على سيدنا محمد', translation: 'O Allah, send peace and blessings upon our Master Muhammad', pronunciation: 'Al-lah-ma sal-li wa sal-lim wa ba-rik ala sa-yi-di-na Mu-ham-mad'),
      Tasbeeh(id: 10, arabic: 'الله أكبر كبيرا  والحمد لله كثيرا  وسبحان الله بكرة وأصيلا', translation: 'Allah is the Greatest, greatly, and praise be to Allah abundantly, and glory be to Allah in the morning and the evening', pronunciation: 'Al-lah Ak-bar kabee-ra wa al-ham-du li-lah ka-thee-ra wa Sub-han Al-lah bu-ka-ra wa a-shee-la'),
      Tasbeeh(id: 11, arabic: 'لا إله إلا الله وحده لا شريك له له الملك وله الحمد وهو على كل شيء قدير', translation: 'There is no god but Allah alone, He has no partner, His is the sovereignty, and His is the praise, and He has power over everything', pronunciation: 'La ila-ha ill-a al-lah wa-hda-hu la shar-ee-ka la-hu la-hu al-mul-ku wa la-hu al-ham-du wa hu-wa ala ku-l-lee shay-in qa-deer'),
      Tasbeeh(id: 12, arabic: 'سبحان الله وبحمده  سبحان الله العظيم', translation: 'Glory be to Allah, and praise be to Him; glory be to Allah the Great', pronunciation: 'Sub-han Al-lah wa bi-ham-di-hi  Sub-han Al-lah al-a-zeem'),
    ];

    var customTasbeehs = getValue("customTasbeehs");
    if (customTasbeehs != null) {
      json.decode(customTasbeehs).forEach((t) {
        initialList.add(Tasbeeh(
          id: t["id"],
          arabic: t["arabic"],
          translation: "",
          pronunciation: "",
        ));
      });
    }

    List deletedIds = getValue("deletedTasbeehIds") ?? [];
    tasbeehList = initialList.where((t) => !deletedIds.contains(t.id)).toList();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  addCustomTasbeeh(arabic) async {
    int id = Random().nextInt(9999999);
    var customTasbeehs = getValue("customTasbeehs");
    List tasbeehs = customTasbeehs != null ? json.decode(customTasbeehs) : [];
    tasbeehs.add({"id": id, "arabic": arabic});
    updateValue("customTasbeehs", json.encode(tasbeehs));
    
    loadTasbeehs();
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 150));
    tasbeehScrollController.animateToPage(tasbeehList.length - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }

  deleteSingleTasbeeh(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete".tr(), style: const TextStyle(fontFamily: "cairo")),
        content: Text("deletezikrconfirm".tr(), style: const TextStyle(fontFamily: "cairo")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: const TextStyle(fontFamily: "cairo")),
          ),
          TextButton(
            onPressed: () {
              List deletedIds = getValue("deletedTasbeehIds") ?? [];
              deletedIds.add(id);
              updateValue("deletedTasbeehIds", deletedIds);
              
              var customTasbeehs = getValue("customTasbeehs");
              if (customTasbeehs != null) {
                List tasbeehs = json.decode(customTasbeehs);
                tasbeehs.removeWhere((t) => t["id"] == id);
                updateValue("customTasbeehs", json.encode(tasbeehs));
              }

              loadTasbeehs();
              Navigator.pop(context);
              if (tasbeehList.isNotEmpty) {
                tasbeehScrollController.jumpToPage(0);
                updateValue("tasbeehLastIndex", 0);
              }
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.red, fontFamily: "cairo")),
          ),
        ],
      ),
    );
  }

  deleteAllCustomTasbeehs() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("deleteallzikr".tr(), style: const TextStyle(fontFamily: "cairo")),
        content: Text("deleteallzikrconfirm".tr(), style: const TextStyle(fontFamily: "cairo")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: const TextStyle(fontFamily: "cairo")),
          ),
          TextButton(
            onPressed: () {
              List deletedIds = getValue("deletedTasbeehIds") ?? [];
              for (var t in tasbeehList) {
                if (!deletedIds.contains(t.id)) deletedIds.add(t.id);
              }
              updateValue("deletedTasbeehIds", deletedIds);
              updateValue("customTasbeehs", null);
              
              tasbeehList = [];
              setState(() {});
              Navigator.pop(context);
              updateValue("tasbeehLastIndex", 0);
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.red, fontFamily: "cairo")),
          ),
        ],
      ),
    );
  }

  void _onTasbeehTap() {
    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    int currentCount = (getValue("${getValue("tasbeehLastIndex")}number") ?? 0) + 1;
    updateValue("${getValue("tasbeehLastIndex")}number", currentCount);
    
    if (_isOverlayActive) {
      FlutterOverlayWindow.shareData({"type": "update_count", "count": currentCount});
    }
    setState(() {});
  }

  void _resetCount() {
    HapticFeedback.mediumImpact();
    updateValue("${getValue("tasbeehLastIndex")}number", 0);
    
    if (_isOverlayActive) {
      FlutterOverlayWindow.shareData({"type": "update_count", "count": 0});
    }
    setState(() {});
  }

  void _showSkinPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              "changeStyle".tr(),
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: "cairo", fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _skinImages.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentSkinIndex;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _currentSkinIndex = index;
                        updateValue("sibhaSkinIndex", index);
                      });
                      await _saveSkinForOverlay();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100.w,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected ? Colors.cyanAccent : Colors.white24,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(_skinImages[index], fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xff1a1a2e),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w, height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Text(
                  "overlay_size".tr(),
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: "cairo", fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSizeOption(setModalState, 0, "small".tr()),
                    _buildSizeOption(setModalState, 1, "medium".tr()),
                    _buildSizeOption(setModalState, 2, "large".tr()),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSizeOption(StateSetter setModalState, int index, String label) {
    bool isSelected = _overlaySizeIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _overlaySizeIndex = index;
          updateValue("overlaySizeIndex", index);
        });
        setModalState(() {});
        Navigator.pop(context);
        
        // If overlay is already active, close it and open it again to apply new size
        if (_isOverlayActive) {
          _toggleOverlay(); // close
          Future.delayed(const Duration(milliseconds: 300), () {
            _toggleOverlay(); // reopen
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffD4AF37) : Colors.white12,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? const Color(0xffD4AF37) : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white,
            fontFamily: "cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = getValue("darkMode") == true;
    
    final int currentCount = getValue("${getValue("tasbeehLastIndex")}number") ?? 0;

    return IslamicBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomAppBar(
              title: "sibha".tr(),
            ),
            body: Column(
              children: [
                SizedBox(height: 5.h),
                // ─── Top Action Buttons ───
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _toggleOverlay,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isOverlayActive
                                  ? [const Color(0xffD4AF37), const Color(0xffB8860B)]
                                  : isDark
                                      ? [Colors.black54, Colors.black38]
                                      : [Colors.black12, Colors.black.withOpacity(0.08)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: _isOverlayActive
                                  ? const Color(0xffD4AF37).withOpacity(0.7)
                                  : (isDark ? Colors.white24 : Colors.black26),
                              width: 1,
                            ),
                            boxShadow: _isOverlayActive
                                ? [BoxShadow(
                                    color: const Color(0xffD4AF37).withOpacity(0.35),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '📿',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'float_tasbih_btn'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  color: _isOverlayActive
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black87),
                                  shadows: _isOverlayActive
                                      ? [const Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 1))]
                                      : (isDark ? [const Shadow(color: Colors.black87, blurRadius: 2, offset: Offset(0, 1))] : []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _showSkinPicker,
                            icon: Icon(Icons.palette_outlined, color: isDark ? Colors.white : Colors.black87),
                            tooltip: "changeStyle".tr(),
                          ),
                          IconButton(
                            onPressed: _showSizePicker,
                            icon: Icon(Icons.aspect_ratio_rounded, color: isDark ? Colors.white : Colors.black87),
                            tooltip: "قەبارە",
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (c) => AddTasbeehDialog(
                                        function: addCustomTasbeeh,
                                      ));
                            },
                            icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black87),
                          ),
                          IconButton(
                            onPressed: deleteAllCustomTasbeehs,
                            icon: Icon(Icons.delete_sweep, color: isDark ? Colors.white : Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                // ─── Zikr Card (PageView) ───
                SizedBox(
                  height: screenSize.height * 0.18,
                  child: PageView.builder(
                    onPageChanged: ((value) {
                      updateValue("tasbeehLastIndex", value);
                      setState(() {});
                    }),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15.r),
                                border: Border.all(
                                  color: const Color(0xffD4AF37), // Islamic Gold
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0, left: 0, // Put it on the left side
                                    child: IconButton(
                                      onPressed: () => deleteSingleTasbeeh(tasbeehList[i].id),
                                      icon: Icon(Icons.delete, color: Colors.red.withOpacity(0.8), size: 22.sp),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tasbeehList[i].arabic,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontFamily: "Taha",
                                              fontSize: 24.sp,
                                              height: 1.4,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (tasbeehList[i].pronunciation != "")
                                            Padding(
                                              padding: EdgeInsets.only(top: 4.h),
                                              child: Text(
                                                tasbeehList[i].pronunciation,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontFamily: "roboto",
                                                  fontSize: 11.sp,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: tasbeehList.length,
                    scrollDirection: Axis.horizontal,
                    controller: tasbeehScrollController,
                  ),
                ),

                SizedBox(height: 8.h),

                // ─── Navigation arrows ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      isDark: isDark,
                      onTap: () {
                        if ((getValue("tasbeehLastIndex") ?? 0) != 0) {
                          tasbeehScrollController.animateToPage(
                              getValue("tasbeehLastIndex") - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic);
                        }
                      },
                    ),
                    SizedBox(width: 30.w),
                    _buildNavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      isDark: isDark,
                      onTap: () {
                        if ((getValue("tasbeehLastIndex") ?? 0) != tasbeehList.length - 1) {
                          tasbeehScrollController.animateToPage(
                              getValue("tasbeehLastIndex") + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic);
                        }
                      },
                    ),
                  ],
                ),

                // ─── Tally Counter Image with overlaid count + buttons ───
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: screenSize.width * 0.75,
                      child: AspectRatio(
                        aspectRatio: 1012 / 1278,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final maxHeight = constraints.maxHeight;
                            
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // The tally counter skin image
                                Image.asset(
                                  _skinImages[_currentSkinIndex],
                                  fit: BoxFit.fill,
                                  width: maxWidth,
                                  height: maxHeight,
                                ),

                                // Counter number overlay on the LCD screen area
                                Positioned(
                                  top: maxHeight * 0.191,
                                  left: maxWidth * 0.148,
                                  right: maxWidth * 0.148,
                                  height: maxHeight * 0.200,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "$currentCount",
                                        style: TextStyle(
                                          color: const Color(0xDA1E1E1E),
                                          fontSize: 62.sp,
                                          fontFamily: "DSEG7Classic",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Big COUNT button (the main large silver button area)
                                Positioned(
                                  top: maxHeight * 0.77 - (maxWidth * 0.24),
                                  left: maxWidth * 0.5 - (maxWidth * 0.24),
                                  width: maxWidth * 0.48,
                                  height: maxWidth * 0.48,
                                  child: GestureDetector(
                                    onTapDown: (_) => setState(() => _isCountPressed = true),
                                    onTapUp: (_) {
                                      setState(() => _isCountPressed = false);
                                      _onTasbeehTap();
                                    },
                                    onTapCancel: () => setState(() => _isCountPressed = false),
                                    behavior: HitTestBehavior.translucent,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 50),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: _isCountPressed
                                            ? RadialGradient(
                                                center: const Alignment(0, -0.6),
                                                radius: 0.8,
                                                colors: [
                                                  Colors.black.withAlpha(180),
                                                  Colors.transparent,
                                                ],
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),

                                // Small RESET button (the small silver button on the right)
                                Positioned(
                                  top: maxHeight * 0.559 - (maxWidth * 0.064),
                                  left: maxWidth * 0.741 - (maxWidth * 0.064),
                                  width: maxWidth * 0.128,
                                  height: maxWidth * 0.128,
                                  child: GestureDetector(
                                    onTapDown: (_) => setState(() => _isResetPressed = true),
                                    onTapUp: (_) {
                                      setState(() => _isResetPressed = false);
                                      _resetCount();
                                    },
                                    onTapCancel: () => setState(() => _isResetPressed = false),
                                    behavior: HitTestBehavior.translucent,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 50),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: _isResetPressed
                                            ? RadialGradient(
                                                center: const Alignment(0, -0.6),
                                                radius: 0.8,
                                                colors: [
                                                  Colors.black.withAlpha(180),
                                                  Colors.transparent,
                                                ],
                                              )
                                            : null,
                                      ),
                                    ),
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

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 20.sp,
        ),
      ),
    );
  }
}
