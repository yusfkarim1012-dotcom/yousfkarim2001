import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:permission_handler/permission_handler.dart';

class NativeCompass extends StatefulWidget {
  const NativeCompass({super.key});

  @override
  State<NativeCompass> createState() => _NativeCompassState();
}

class _NativeCompassState extends State<NativeCompass> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
/*
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = status == PermissionStatus.granted;
        });
      }
    });
*/
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermissions) {
      return Center(
        child: ElevatedButton(
          child: const Text("Location Disabled"),
          onPressed: () async {
            // await [Permission.location, Permission.locationWhenInUse].request();
            // _fetchPermissionStatus();
          },
        ),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final qiblahDirection = snapshot.data;
        if (qiblahDirection == null) {
          return const Center(child: Text("Unable to get Qiblah direction"));
        }

        // Native Compass Logic:
        // We just show an arrow pointing to Qiblah.
        // angle = (qiblah(offset from North) - heading(direction))
        

        // This assumes the Image points North.
        // If we want the arrow to point to Qiblah?
        // Let's use the provided code from one of the examples or derive it:
        // direction.qiblah is the angle of Mecca from True North (Clockwise).
        // direction.direction is the Heading of Device from True North.
        // We want the Arrow to point to Mecca.
        // So Arrow Rotation = (Mecca Angle - Heading).
        
        final double heading = qiblahDirection.direction;
        final double mecca = qiblahDirection.qiblah;
        final double rotation = (mecca - heading) * (math.pi / 180);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text("Native Compass", style: TextStyle(color: Colors.white, fontSize: 20.sp)),
               SizedBox(height: 20.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Simple Circle Background
                  Container(
                    width: 300.w,
                    height: 300.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.black12,
                    ),
                  ),
                  // The Arrow pointing to Qiblah
                  Transform.rotate(
                    angle: rotation,
                    child: Icon(
                      Icons.arrow_upward,
                      size: 100.sp,
                      color: Theme.of(context).primaryColor, // Use app theme color or specific
                    ),
                  ),
                  // North Indicator (Optional, pointing to -heading)
                   Transform.rotate(
                    angle: -heading * (math.pi / 180),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 260.h), // Offset to put 'N' at top of circle
                        child: Text("N", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24.sp)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                "${heading.toStringAsFixed(0)}°",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
