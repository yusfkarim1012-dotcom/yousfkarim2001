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
              // ── Background Skin Image ─────────────────────────────
              Positioned.fill(
                child: _skinFile != null
                    ? Image.file(_skinFile!, fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => _fallback())
                    : _fallback(),
              ),

              // ── LCD Display (Grayish dark realistic color) ────────
              // Accurately positioned over the black LCD screen of the skin
              Positioned(
                top: h * 0.18,
                left: w * 0.22,
                right: w * 0.22,
                height: h * 0.18,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 15),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '$_count',
                      style: const TextStyle(
                        color: Color(0xFF3B403B), // Realistic LCD gray/black
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        decoration: TextDecoration.none,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Small Silver RESET Button Tap Zone ────────────────
              // Accurately positioned over the small silver circle
              Positioned(
                top: h * 0.49,
                right: w * 0.18,
                width: w * 0.18,
                height: w * 0.18, // Make it perfectly circular
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

              // ── Large COUNT Button Tap Zone ───────────────────────
              // Accurately positioned over the large silver knob
              Positioned(
                top: h * 0.62,
                left: w * 0.25,
                right: w * 0.25,
                height: h * 0.26,
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

              // ── Close button — transparent overlay corner ─────────
              Positioned(
                top: 0,
                right: 0,
                width: w * 0.25,
                height: h * 0.15,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _fallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1a3a5c), Color(0xFF0a1a2e)],
      ),
    ),
  );
}
