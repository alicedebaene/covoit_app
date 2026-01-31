import 'package:flutter/material.dart';

class OvalinkLogoBadge extends StatelessWidget {
  const OvalinkLogoBadge({
    super.key,
    this.size = 96, // 👈 plus grand par défaut
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.directions_car,
          size: size * 0.6,
          color: Colors.black54,
        ),
      ),
    );
  }
}
