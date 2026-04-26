import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Floating Tasbih overlay
class TasbihOverlayWidget extends StatefulWidget {
  const TasbihOverlayWidget({super.key});

  @override
  State<TasbihOverlayWidget> createState() => _TasbihOverlayWidgetState();
}

class _TasbihOverlayWidgetState extends State<TasbihOverlayWidget> {
  int _count = 0;
  File? _skinFile;
  bool _countHighlight = false;
  bool _resetHighlight = false;

  @override
  void initState() {
    super.initState();
    _load();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        if (event['type'] == 'update_count') {
          if (mounted) setState(() => _count = event['count']);
        } else if (event['type'] == 'update_skin') {
          final f = File(event['skinPath']);
          if (f.existsSync()) {
            if (mounted) {
              // Evict old image from cache before setting new one to force refresh
              if (_skinFile != null) {
                FileImage(_skinFile!).evict();
              }
              setState(() => _skinFile = f);
            }
          }
        }
      }
    });
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final skinPath = p.getString('overlay_skin_path');
      final count = p.getInt('overlay_tasbih_count') ?? 0;

      File? skinFile;
      if (skinPath != null) {
        final f = File(skinPath);
        if (await f.exists()) skinFile = f;
      }
      if (mounted) setState(() { _count = count; _skinFile = skinFile; });
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('overlay_tasbih_count', _count);
    } catch (_) {}
  }

  void _tap() { 
    setState(() => _count++); 
    _save(); 
    FlutterOverlayWindow.shareData({"type": "update_count", "count": _count});
  }
  void _reset() { 
    setState(() => _count = 0); 
    _save(); 
    FlutterOverlayWindow.shareData({"type": "update_count", "count": _count});
  }
  Future<void> _close() async {
    try { 
      await _save(); 
      FlutterOverlayWindow.shareData({"type": "overlay_closed"}); // Don't await this, might block if app is dead
      await FlutterOverlayWindow.closeOverlay(); 
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Remove closeBtnAreaH definition since it's hardcoded now

          return Stack(
            children: [
              // ── Background Skin Image ───────
              Positioned(
                top: 20, // Give some space at the top for the close button
                left: 0,
                right: 0,
                bottom: 0,
                child: _skinFile != null
                    ? Image.file(_skinFile!, fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => _fallback())
                    : _fallback(),
              ),

              // ── LCD Display ────────────────────────────────────────
              Positioned(
                top: 20 + (h - 20) * 0.18,
                left: w * 0.22,
                right: w * 0.22,
                height: (h - 20) * 0.18,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 15),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '$_count',
                      style: const TextStyle(
                        color: Color(0xFF2C312C),
                        fontSize: 82,
                        fontFamily: 'DSEG7Classic',
                        decoration: TextDecoration.none,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Small RESET Button Tap Zone ────────────────────────
              Positioned(
                top: 20 + (h - 20) * 0.49,
                right: w * 0.18,
                width: w * 0.18,
                height: w * 0.18,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => setState(() => _resetHighlight = true),
                  onTapUp: (_) {
                    setState(() => _resetHighlight = false);
                    _reset();
                  },
                  onTapCancel: () => setState(() => _resetHighlight = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _resetHighlight
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),

              // ── Large COUNT Button Tap Zone ────────────────────────
              Positioned(
                top: 20 + (h - 20) * 0.62,
                left: w * 0.25,
                right: w * 0.25,
                height: (h - 20) * 0.26,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => setState(() => _countHighlight = true),
                  onTapUp: (_) {
                    setState(() => _countHighlight = false);
                    _tap();
                  },
                  onTapCancel: () => setState(() => _countHighlight = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _countHighlight
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),

              // ── × Close Button ──
              Positioned(
                top: 0,
                right: 15, // stick it a bit to the side
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    width: 22, // smaller
                    height: 22, // smaller
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6), // simple semi-transparent background so it's visible
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '×',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.1,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _fallback() {
    return Image.asset("assets/images/20.png", fit: BoxFit.fill);
  }
}
