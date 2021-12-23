import 'package:flutter/material.dart';

class Bill extends StatelessWidget {
  const Bill({Key? key, this.width = 35.0}) : super(key: key);
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width / 1.3;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Icon(
        Icons.money,
        size: height,
        color: Colors.green[200],
      ),
    );
  }
}
