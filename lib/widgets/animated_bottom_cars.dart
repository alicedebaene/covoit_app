import 'package:flutter/material.dart';

class AnimatedBottomCars extends StatefulWidget {
  const AnimatedBottomCars({
    super.key,
    this.height = 80,
    this.opacity = 1.0,
    this.secondsPerLoop = 10,
  });

  final double height;
  final double opacity;
  final int secondsPerLoop;

  @override
  State<AnimatedBottomCars> createState() => _AnimatedBottomCarsState();
}

class _AnimatedBottomCarsState extends State<AnimatedBottomCars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsPerLoop),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedBottomCars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secondsPerLoop != widget.secondsPerLoop) {
      _controller.duration = Duration(seconds: widget.secondsPerLoop);
      _controller
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: widget.height,
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    // ✅ gauche -> droite : commence hors écran à gauche (-w) et finit à 0
                    final dx = (_controller.value * w) - w;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.translate(
                          offset: Offset(dx, 0),
                          child: _strip(w),
                        ),
                        Transform.translate(
                          offset: Offset(dx + w, 0),
                          child: _strip(w),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _strip(double width) {
    return SizedBox(
      width: width,
      height: widget.height,
      child: Image.asset(
        'assets/images/voitures.png',
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
