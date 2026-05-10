import 'package:flutter/material.dart';

/// Wrapper yang memberi efek "press down" saat widget ditekan.
/// Scale turun sedikit (0.97) saat finger down, kembali saat lift.
/// Sangat halus — tidak terasa berlebihan, tapi memberikan
/// feedback fisik yang memuaskan.
///
/// Cara pakai:
/// ```dart
/// TapScaleWidget(
///   onTap: () => doSomething(),
///   child: Container(...),
/// )
/// ```
class TapScaleWidget extends StatefulWidget {
  final Widget       child;
  final VoidCallback? onTap;
  final double       scaleDown;   // default: 0.97
  final Duration     duration;

  const TapScaleWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.duration  = const Duration(milliseconds: 120),
  });

  @override
  State<TapScaleWidget> createState() => _TapScaleWidgetState();
}

class _TapScaleWidgetState extends State<TapScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}