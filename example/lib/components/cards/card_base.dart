import 'package:flutter/material.dart';

class CardBase extends StatelessWidget {
  const CardBase({Key? key, this.height, required this.child})
      : super(key: key);

  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: child,
      ),
    );
  }
}
