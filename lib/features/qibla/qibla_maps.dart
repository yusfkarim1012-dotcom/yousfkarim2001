import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QiblahMaps extends StatefulWidget {
  final bool isDark;
  const QiblahMaps({super.key, required this.isDark});

  @override
  State<QiblahMaps> createState() => _QiblahMapsState();
}

class _QiblahMapsState extends State<QiblahMaps> {
  final MapController _mapController = MapController();
  final LatLng _kaabaPos = const LatLng(21.422487, 39.826206);
  
  LatLng? _userPos;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location service disabled');

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPos = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xffC5A053);
    
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: gold));
    }
    if (_error.isNotEmpty || _userPos == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text('Could not load location', style: TextStyle(fontFamily: 'cairo')),
            ElevatedButton(
              onPressed: () {
                setState(() { _loading = true; _error = ''; });
                _initLocation();
              },
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snap) {
        final heading = (snap.data?.direction ?? 0) * (math.pi / 180) * -1; // Convert to radians and reverse for rotation

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPos!,
                initialZoom: 14.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.khatmah.quran.yusf',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_userPos!, _kaabaPos],
                      color: gold,
                      strokeWidth: 4.0,
                      pattern: StrokePattern.dashed(segments: const [10, 10]),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Kaaba Marker
                    Marker(
                      point: _kaabaPos,
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset('assets/images/Makkah.png'),
                    ),
                    // User Marker
                    Marker(
                      point: _userPos!,
                      width: 50.0,
                      height: 50.0,
                      child: Transform.rotate(
                        angle: heading,
                        child: Icon(
                          Icons.navigation_rounded,
                          color: Colors.blueAccent,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 24.h,
              right: 16.w,
              child: FloatingActionButton(
                backgroundColor: gold,
                onPressed: () {
                  if (_userPos != null) {
                    _mapController.move(_userPos!, 14.0);
                  }
                },
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

