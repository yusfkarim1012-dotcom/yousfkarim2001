import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Floating Tasbih counter overlay — simple & crash-proof design.
/// Matches the masbha widget style: blue body, gray LCD display, oval COUNT button.
class TasbihOverlayWidget extends StatefulWidget {
  const TasbihOverlayWidget({super.key});

  @override
  State<TasbihOverlayWidget> createState() => _TasbihOverlayWidgetState();
}

class _TasbihOverlayWidgetState extends State<TasbihOverlayWidget> {
  int _count = 0;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => _count = p.getInt('overlay_tasbih_count') ?? 0);
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
  }

  void _reset() {
    setState(() => _count = 0);
    _save();
  }

  Future<void> _close() async {
    try {
      await _save();
      await FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF29ABE2), // sky blue — matches masbha widget
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 14,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── CLOSE button (top-right) ──────────────────────────
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),

              // ── RESET label (top-left) ──────────────────────────
              Positioned(
                top: 6,
                left: 8,
                child: GestureDetector(
                  onTap: _reset,
                  child: const Text(
                    'RST',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              // ── LCD display (top centre) ──────────────────────────
              Positioned(
                top: 18,
                left: 14,
                right: 14,
                height: 58,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A5A6A), // dark gray LCD
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_count',
                    style: const TextStyle(
                      color: Color(0xFFE0FFE0),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              // ── Big COUNT oval button (bottom centre) ─────────────
              Positioned(
                bottom: 14,
                left: 18,
                right: 18,
                height: 70,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    _tap();
                  },
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    decoration: BoxDecoration(
                      color: _pressed
                          ? const Color(0xFFE05070)
                          : const Color(0xFFF07090), // salmon-pink oval
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: _pressed
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
