// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CustomCompassBody extends StatefulWidget {
//   const CustomCompassBody({super.key});

//   @override
//   State<CustomCompassBody> createState() => _CustomCompassBodyState();
// }

// class _CustomCompassBodyState extends State<CustomCompassBody> {
//   bool _hasPermissions = false;
//   bool _deviceSupported = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkDeviceSupport();
//     _fetchPermissionStatus();
//   }

//   Future<void> _checkDeviceSupport() async {
//     final supported = await FlutterQiblah.androidDeviceSensorSupport();
//     if (mounted) {
//       setState(() {
//         _deviceSupported = supported ?? false;
//       });
//     }
//   }

//   void _fetchPermissionStatus() {
//     Permission.locationWhenInUse.status.then((status) {
//       if (mounted) {
//         setState(() {
//           _hasPermissions = status == PermissionStatus.granted;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_deviceSupported) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48.sp, color: Colors.white70),
//             SizedBox(height: 16.h),
//             Text(
//               "Device does not support compass",
//               style: TextStyle(color: Colors.white, fontSize: 18.sp),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     if (!_hasPermissions) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off, size: 48.sp, color: Colors.white70),
//             SizedBox(height: 16.h),
//             Text(
//               "Location permission required",
//               style: TextStyle(color: Colors.white, fontSize: 18.sp),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20.h),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//               ),
//               child: const Text("Grant Permission"),
//               onPressed: () async {
//                 await [Permission.location, Permission.locationWhenInUse].request();
//                 _fetchPermissionStatus();
//               },
//             ),
//           ],
//         ),
//       );
//     }

//     return StreamBuilder<QiblahDirection>(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator.adaptive());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 48.sp, color: Colors.redAccent),
//                 SizedBox(height: 16.h),
//                 Text(
//                   "Error: ${snapshot.error}",
//                   style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         if (!snapshot.hasData) {
//           return const Center(child: Text("Waiting for compass data..."));
//         }

//         final qiblahDirection = snapshot.data!;
        
//         // Get the compass heading (device rotation)
//         final double heading = qiblahDirection.direction;
        
//         // Get the Qibla angle relative to North
//         final double qiblahAngle = qiblahDirection.qiblah;
        
//         // Calculate rotation for compass rose (rotates opposite to device heading)
//         final double compassTurn = (heading * -1) / 360;
        
//         // Calculate rotation for Qibla needle
//         // The needle should point to Qibla direction
//         final double needleTurn = ((qiblahAngle - heading) / 360);

//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Accuracy warning
//               if (qiblahDirection.offset != null && 
//                   (qiblahDirection.offset! > 15 || qiblahDirection.offset! < -15))
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 20.h),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     decoration: BoxDecoration(
//                       color: Colors.orangeAccent.withOpacity(0.8),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       "Move phone in figure-8 pattern to calibrate",
//                       style: TextStyle(color: Colors.white, fontSize: 12.sp),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
              
//               // Aligned indicator (when pointing to Qibla)
//               if (qiblahDirection.offset != null && 
//                   qiblahDirection.offset!.abs() < 5)
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 20.h),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     decoration: BoxDecoration(
//                       color: Colors.greenAccent.withOpacity(0.8),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.check_circle, color: Colors.white, size: 16.sp),
//                         SizedBox(width: 8.w),
//                         Text(
//                           "Aligned with Qibla",
//                           style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               // Compass visualization
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.8,
//                 height: MediaQuery.of(context).size.width * 0.8,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Compass Rose (Background) - rotates with device
//                     AnimatedRotation(
//                       duration: const Duration(milliseconds: 300),
//                       turns: compassTurn,
//                       curve: Curves.easeOut,
//                       child: Image.asset(
//                         "assets/images/compassn.png",
//                         fit: BoxFit.fill,
//                       ),
//                     ),

//                     // Qibla Needle - points to Qibla direction
//                     AnimatedRotation(
//                       duration: const Duration(milliseconds: 300),
//                       turns: needleTurn,
//                       curve: Curves.easeOut,
//                       child: SvgPicture.asset(
//                         "assets/images/needle.svg",
//                         fit: BoxFit.contain,
//                         height: MediaQuery.of(context).size.width * 0.7,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20.h),

//               // Current heading display
//               Text(
//                 "${heading.toStringAsFixed(0)}°",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 28.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
              
//               SizedBox(height: 8.h),

//               // Qibla direction display
//               Text(
//                 "Qibla Direction: ${qiblahAngle.toStringAsFixed(1)}°",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16.sp,
//                 ),
//               ),

//               // Offset from Qibla
//               if (qiblahDirection.offset != null)
//                 Padding(
//                   padding: EdgeInsets.only(top: 8.h),
//                   child: Text(
//                     "Offset: ${qiblahDirection.offset!.toStringAsFixed(1)}°",
//                     style: TextStyle(
//                       color: qiblahDirection.offset!.abs() < 5 
//                           ? Colors.greenAccent 
//                           : Colors.white54,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }