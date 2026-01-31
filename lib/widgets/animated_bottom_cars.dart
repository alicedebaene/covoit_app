import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AnimatedBottomCars extends StatefulWidget {
  const AnimatedBottomCars({
    super.key,
    this.height = 80,
    this.opacity = 0.9,
    this.secondsPerLoop = 10,
    this.assetPath = 'assets/images/voitures.png',
    this.edgeMaskWidth = 44, // 👈 masque les bords (évite voiture coupée)
    this.backgroundColor, // si null, on prend transparent (souvent ok si ton fond est derrière)
    this.bottom = 0,
    this.leftToRight = true, // 👈 demandé : gauche -> droite
  });

  final double height;
  final double opacity;
  final int secondsPerLoop;
  final String assetPath;

  /// Largeur (en px) des "rideaux" gauche/droite pour cacher les voitures coupées
  final double edgeMaskWidth;

  /// Couleur des rideaux. Mets ton _bg si tu veux un masquage parfait.
  final Color? backgroundColor;

  /// Position verticale (par défaut collé en bas)
  final double bottom;

  /// Sens d'animation
  final bool leftToRight;

  @override
  State<AnimatedBottomCars> createState() => _AnimatedBottomCarsState();
}

class _AnimatedBottomCarsState extends State<AnimatedBottomCars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double? _aspectRatio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsPerLoop),
    )..repeat();

    _resolveImageSize();
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

    if (oldWidget.assetPath != widget.assetPath) {
      _aspectRatio = null;
      _resolveImageSize();
    }
  }

  void _resolveImageSize() {
    // Récupère la taille réelle de l'image pour calculer sa largeur à la bonne hauteur
    final provider = AssetImage(widget.assetPath);
    final stream = provider.resolve(const ImageConfiguration());

    _stream?.removeListener(_listener!);

    _stream = stream;
    _listener = ImageStreamListener((ImageInfo info, bool _) {
      final ui.Image img = info.image;
      final ratio = img.width / img.height;

      if (mounted) {
        setState(() => _aspectRatio = ratio);
      }
    }, onError: (Object _, StackTrace? __) {
      // Si l'asset ne charge pas, on laisse _aspectRatio null
    });

    stream.addListener(_listener!);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener!);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si on ne connait pas la taille de l'image, on affiche quand même,
    // mais on évite de planter.
    final ratio = _aspectRatio ?? 6.0; // fallback large
    final imgW = widget.height * ratio;

    final curtainColor = widget.backgroundColor ?? Colors.transparent;

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottom,
      height: widget.height,
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: ClipRect(
            child: Stack(
              children: [
                // Bande animée
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value; // 0..1
                    final dx = t * imgW;

                    // Gauche -> Droite:
                    // image A arrive depuis la gauche, image B la suit
                    final x1 = widget.leftToRight ? (-imgW + dx) : (-dx);
                    final x2 = widget.leftToRight ? (dx) : (imgW - dx);

                    return Stack(
                      children: [
                        Positioned(
                          left: x1,
                          bottom: 0,
                          height: widget.height,
                          child: Image.asset(
                            widget.assetPath,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Positioned(
                          left: x2,
                          bottom: 0,
                          height: widget.height,
                          child: Image.asset(
                            widget.assetPath,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // ✅ Rideau gauche (cache voiture coupée)
                if (widget.edgeMaskWidth > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: widget.edgeMaskWidth,
                    child: Container(color: curtainColor),
                  ),

                // ✅ Rideau droit (cache voiture coupée)
                if (widget.edgeMaskWidth > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: widget.edgeMaskWidth,
                    child: Container(color: curtainColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
