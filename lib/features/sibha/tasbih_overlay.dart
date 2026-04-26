import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Floating Tasbih overlay — designed to align with skin image 20.png
/// Layout zones (% of height 380px):
///   0-8%   : close button (top-right)
///   8-30%  : LCD display (shows count over the dark screen of the skin)
///  30-52%  : COUNT (left) and RESET (right) invisible tap zones
///  52-98%  : large metallic knob — tap anywhere = count
class TasbihOverlayWidget extends StatefulWidget {
  const TasbihOverlayWidget({super.key});

  @override
  State<TasbihOverlayWidget> createState() => _TasbihOverlayWidgetState();
}

class _TasbihOverlayWidgetState extends State<TasbihOverlayWidget> {
  int _count = 0;
  File? _skinFile;
  bool _countHighlight = false;

  @override
  void initState() {
    super.initState();
    _load();
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

  void _tap() { setState(() => _count++); _save(); }
  void _reset() { setState(() => _count = 0); _save(); }
  Future<void> _close() async {
    try { await _save(); await FlutterOverlayWindow.closeOverlay(); } catch (_) {}
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

          return Stack(
            children: [

              // ── Skin image background ─────────────────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _skinFile != null
                      ? Image.file(_skinFile!, fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) => _fallback())
                      : _fallback(),
                ),
              ),

              // ── LCD display — overlays the dark screen area of skin
              // Skin's display is roughly at 8–30% of height, center
              Positioned(
                top: h * 0.08,
                left: w * 0.18,
                right: w * 0.18,
                height: h * 0.22,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '$_count',
                      style: const TextStyle(
                        color: Color(0xFF39FF14), // bright neon green LCD
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        decoration: TextDecoration.none,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(color: Color(0xFF00FF00), blurRadius: 16),
                          Shadow(color: Color(0xFF00FF00), blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── RESET tap zone — aligns with "RESET" label in skin
              // Skin shows COUNT(left) RESET(right) at ~30–52% height
              Positioned(
                top: h * 0.30,
                right: 0,
                width: w * 0.50,
                height: h * 0.22,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _reset,
                  child: const SizedBox.expand(), // invisible hit zone
                ),
              ),

              // ── Large COUNT tap zone — the metallic knob (52–100%)
              Positioned(
                top: h * 0.52,
                left: 0,
                right: 0,
                height: h * 0.46,
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
                      color: _countHighlight
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(h * 0.25),
                    ),
                  ),
                ),
              ),

              // ── Close button — small X at very top-right ─────────
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 15),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _fallback() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1a3a5c), Color(0xFF0a1a2e)],
      ),
    ),
  );
}
