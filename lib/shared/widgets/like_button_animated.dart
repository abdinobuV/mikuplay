import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tombol Like yang animasinya smooth tapi tidak lebay:
/// - Tap pertama: heart scale up sedikit + warna berubah ke merah
/// - Tap kedua: kembali ke outline putih
/// - Tidak ada particle explosion, tidak ada confetti
/// - Cukup scale pulse + color transition yang terasa "satisfying"
///
/// Cara pakai:
/// ```dart
/// LikeButtonAnimated(
///   isLiked: _isLiked,
///   onToggle: (liked) => setState(() => _isLiked = liked),
/// )
/// ```
class LikeButtonAnimated extends StatefulWidget {
  final bool          isLiked;
  final ValueChanged<bool>? onToggle;
  final double        size;

  const LikeButtonAnimated({
    super.key,
    required this.isLiked,
    this.onToggle,
    this.size = 22,
  });

  @override
  State<LikeButtonAnimated> createState() => _LikeButtonAnimatedState();
}

class _LikeButtonAnimatedState extends State<LikeButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scaleAnim;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;

    // Controller untuk pulse saat di-tap
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Scale: 1.0 → 1.35 → 1.0 (menggunakan keyframe simulasi)
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(LikeButtonAnimated old) {
    super.didUpdateWidget(old);
    if (old.isLiked != widget.isLiked) {
      setState(() => _isLiked = widget.isLiked);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    setState(() => _isLiked = !_isLiked);
    await _ctrl.forward(from: 0);
    widget.onToggle?.call(_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim, child: child),
              child: Icon(
                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(_isLiked),
                size: widget.size,
                color: _isLiked ? AppColors.red : AppColors.skyOp(0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}