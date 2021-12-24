import 'package:flutter/material.dart';

class PremiumFeatureIcon extends StatelessWidget {
  const PremiumFeatureIcon({Key? key, this.radius = 30.0}) : super(key: key);
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: radius,
        height: radius,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: Icon(
          Icons.face,
          color: Colors.green[100],
          size: radius,
        ),
      );
}
