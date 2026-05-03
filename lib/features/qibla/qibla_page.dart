
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/features/qibla/q_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  bool _isCustomCompass = true;
  late AnimationController _switchController;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: darkPrimaryColor,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/tasbeehbackground.png'),
          alignment: Alignment.center,
          opacity: 0.05,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'القبلة',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: Colors.white.withOpacity(0.95),
              fontFamily: 'cairo',
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 16.h),

            // --- بوتنی گۆڕینی نێوان کۆمپاس و نەخشە ---
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    label: 'کۆمپاس',
                    icon: Icons.explore_rounded,
                    isSelected: _isCustomCompass,
                    onTap: () => setState(() => _isCustomCompass = true),
                  ),
                  _buildTabButton(
                    label: 'نەخشە',
                    icon: Icons.map_rounded,
                    isSelected: !_isCustomCompass,
                    onTap: () => setState(() => _isCustomCompass = false),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // --- ناوەڕۆک ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _isCustomCompass
                    ? const CustomCompassBody(key: ValueKey('compass'))
                    : _buildMapPlaceholder(),
              ),
            ),

            // --- ئاگادارکردنەوەی خوارەوە ---
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Text(
                'ئامێرەکەت لەدور شتی مادنی خۆ بگرە بۆ کارکردنی باشترین کۆمپاس',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11.sp,
                  fontFamily: 'cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xffC5A053)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.sp,
                  fontFamily: 'cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, color: Colors.white30, size: 64.sp),
          SizedBox(height: 16.h),
          Text(
            'نەخشەکە بەم بەرهەمدا بەردەست نییە',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14.sp,
              fontFamily: 'cairo',
            ),
          ),
        ],
      ),
    );
  }
}

