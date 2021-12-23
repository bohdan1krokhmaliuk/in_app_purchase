import 'package:flutter/material.dart';

class AdsFreeIcon extends StatelessWidget {
  const AdsFreeIcon({Key? key, this.radius = 30.0}) : super(key: key);
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
          Icons.color_lens_outlined,
          color: Colors.white,
          size: radius,
        ),
      );
}
