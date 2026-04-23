import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';
import 'package:khatmah/features/sibha/models/tasbeh.dart';
import 'package:khatmah/features/sibha/widgets/add_tasbeeh_dialog.dart';

class SibhaPage extends StatefulWidget {
  const SibhaPage({super.key});

  @override
  State<SibhaPage> createState() => _SibhaPageState();
}

class _SibhaPageState extends State<SibhaPage> with SingleTickerProviderStateMixin {
  List<Tasbeeh> tasbeehList = [
    Tasbeeh(
      id: 0,
      arabic: 'الحمد لله',
      translation: 'Praise be to Allah',
      pronunciation: 'Al-ham-du li-lah',
    ),
    Tasbeeh(
      id: 1,
      arabic: 'الله اكبر',
      translation: 'Allah is the Greatest',
      pronunciation: 'Al-lah-hu Ak-bar',
    ),
    Tasbeeh(
      id: 2,
      arabic: 'استغفر الله',
      translation: 'I seek forgiveness from Allah',
      pronunciation: 'As-tag-fir-ul-lah',
    ),
    Tasbeeh(
      id: 3,
      arabic: 'لا اله الا الله',
      translation: 'There is no god but Allah',
      pronunciation: 'La ila-ha ill-al-lah',
    ),
    Tasbeeh(
      id: 4,
      arabic: 'سبحان الله',
      translation: 'Glory be to Allah',
      pronunciation: 'Sub-han Allah',
    ),
    Tasbeeh(
      id: 5,
      arabic: 'سبحان الله وبحمده سبحان الله العظيم',
      translation:
          'Glory be to Allah, and praise is due to Him, glory be to Allah the Great',
      pronunciation: 'Sub-han Allah wa bi-ham-di-hi Sub-han Allah al-a-zeem',
    ),
    Tasbeeh(
      id: 6,
      arabic: 'سبحان الله والحمد لله ولا اله الا الله والله اكبر',
      translation:
          'Glory be to Allah, and praise is due to Allah, and there is no god but Allah, and Allah is the Greatest',
      pronunciation:
          'Sub-han Allah wa al-ham-du li-lah wa la ila-ha ill-al-lah wa Al-lah Ak-bar',
    ),
    Tasbeeh(
      id: 7,
      arabic: 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
      translation:
          'There is no god but You, glory be to You; surely I am of those who are unjust',
      pronunciation:
          'La ila-ha ill-a an-ta Sub-ha-na-ka in-ni ku-n-tu min az-zal-li-meen',
    ),
    Tasbeeh(
      id: 8,
      arabic: 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
      translation:
          'O Allah, You are the Peace, and from You comes peace; Blessed are You, O Possessor of Majesty and Honor',
      pronunciation:
          'Al-lah-ma an-ta as-Sa-laam wa min-ka as-Sa-laam ta-ba-ra-kat ya dha al-ja-la-li wal-i-kraam',
    ),
    Tasbeeh(
      id: 9,
      arabic: 'اللهم صل وسلم وبارك على سيدنا محمد',
      translation: 'O Allah, send peace and blessings upon our Master Muhammad',
      pronunciation:
          'Al-lah-ma sal-li wa sal-lim wa ba-rik ala sa-yi-di-na Mu-ham-mad',
    ),
    Tasbeeh(
      id: 10,
      arabic: 'الله أكبر كبيرا  والحمد لله كثيرا  وسبحان الله بكرة وأصيلا',
      translation:
          'Allah is the Greatest, greatly, and praise be to Allah abundantly, and glory be to Allah in the morning and the evening',
      pronunciation:
          'Al-lah Ak-bar kabee-ra wa al-ham-du li-lah ka-thee-ra wa Sub-han Al-lah bu-ka-ra wa a-shee-la',
    ),
    Tasbeeh(
      id: 11,
      arabic:
          'لا إله إلا الله وحده لا شريك له له الملك وله الحمد وهو على كل شيء قدير',
      translation:
          'There is no god but Allah alone, He has no partner, His is the sovereignty, and His is the praise, and He has power over everything',
      pronunciation:
          'La ila-ha ill-a al-lah wa-hda-hu la shar-ee-ka la-hu la-hu al-mul-ku wa la-hu al-ham-du wa hu-wa ala ku-l-lee shay-in qa-deer',
    ),
    Tasbeeh(
      id: 12,
      arabic: 'سبحان الله وبحمده  سبحان الله العظيم',
      translation:
          'Glory be to Allah, and praise be to Him; glory be to Allah the Great',
      pronunciation: 'Sub-han Al-lah wa bi-ham-di-hi  Sub-han Al-lah al-a-zeem',
    ),
  ];

  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  PageController tasbeehScrollController = PageController(initialPage: 0);

  @override
  void initState() {
    tasbeehScrollController = PageController(initialPage: getValue("tasbeehLastIndex") ?? 0);
    loadTasbeehs();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
    super.initState();
  }

  void loadTasbeehs() {
    // 1. Start with hardcoded ones
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

    // 2. Add custom ones
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

    // 3. Filter out deleted ones
    List deletedIds = getValue("deletedTasbeehIds") ?? [];
    tasbeehList = initialList.where((t) => !deletedIds.contains(t.id)).toList();
    setState(() {});
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
              
              // Also remove from customTasbeehs if it's there
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
              // Mark all current IDs as deleted
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
    updateValue(
        "${getValue("tasbeehLastIndex")}number",
        (getValue("${getValue("tasbeehLastIndex")}number") ?? 0) + 1);
    setState(() {});
  }

  void _resetCount() {
    HapticFeedback.mediumImpact();
    updateValue("${getValue("tasbeehLastIndex")}number", 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = getValue("darkMode") == true;
    
    final Color bgGradientStart = isDark ? const Color(0xff0F2027) : const Color(0xff1A2980);
    final Color bgGradientEnd = isDark ? const Color(0xff203A43) : const Color(0xff26D0CE);
    final Color textColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgGradientStart, bgGradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Subtle Islamic Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                "assets/images/tasbeehbackground.png",
                fit: BoxFit.cover,
                color: Colors.white,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  onPressed: deleteAllCustomTasbeehs,
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (c) => AddTasbeehDialog(
                              function: addCustomTasbeeh,
                            ));
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                )
              ],
              title: Text(
                "sibha".tr(),
                style: TextStyle(
                  fontFamily: 'cairo',
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                SizedBox(height: 20.h),
                // Glassmorphism Tasbeeh Card
                SizedBox(
                  height: screenSize.height * 0.28,
                  child: PageView.builder(
                    onPageChanged: ((value) {
                      updateValue("tasbeehLastIndex", value);
                      setState(() {});
                    }),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
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
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      onPressed: () => deleteSingleTasbeeh(tasbeehList[i].id),
                                      icon: Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.5), size: 20.sp),
                                    ),
                                  ),
                                  Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 10.h),
                                          Text(
                                            tasbeehList[i].arabic,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textColor,
                                              fontFamily: "cairo",
                                              fontSize: 22.sp,
                                              height: 1.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (tasbeehList[i].pronunciation != "" || tasbeehList[i].translation != "")
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8.h),
                                              child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                                            ),
                                          if (tasbeehList[i].pronunciation != "")
                                            Text(
                                              tasbeehList[i].pronunciation,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: textColor.withOpacity(0.9),
                                                fontFamily: "roboto",
                                                fontSize: 14.sp,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          if (tasbeehList[i].translation != "") SizedBox(height: 4.h),
                                          if (tasbeehList[i].translation != "")
                                            Text(
                                              tasbeehList[i].translation,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: textColor.withOpacity(0.8),
                                                fontFamily: "roboto",
                                                fontSize: 13.sp,
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
                
                SizedBox(height: 30.h),
                
                // Navigation and Reset Controls
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous Button
                      _buildNavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          if (getValue("tasbeehLastIndex") != 0) {
                            tasbeehScrollController.animateToPage(
                                getValue("tasbeehLastIndex") - 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          }
                        },
                      ),
                      
                      // Reset Button
                      InkWell(
                        onTap: _resetCount,
                        borderRadius: BorderRadius.circular(30.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                "0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Next Button
                      _buildNavButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        onTap: () {
                          if (getValue("tasbeehLastIndex") != tasbeehList.length - 1) {
                            tasbeehScrollController.animateToPage(
                                getValue("tasbeehLastIndex") + 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Giant Interactive Counter Button
                GestureDetector(
                  onTap: _onTasbeehTap,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 220.w,
                      height: 220.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring decoration
                          Container(
                            width: 190.w,
                            height: 190.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                            ),
                          ),
                          // Inner circle
                          Container(
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.05)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: Center(
                              child: Text(
                                "${getValue("${getValue("tasbeehLastIndex")}number") ?? 0}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: "roboto",
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 22.sp,
        ),
      ),
    );
  }
}
