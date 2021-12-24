import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  const CoinIcon({Key? key, this.radius = 30.0}) : super(key: key);
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: radius,
        height: radius,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        child: Icon(
          Icons.monetization_on_outlined,
          color: Colors.amber[100],
          size: radius,
        ),
      );
}
