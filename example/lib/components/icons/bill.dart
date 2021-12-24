import 'package:flutter/material.dart';

class BillIcon extends StatelessWidget {
  const BillIcon({Key? key, this.size = 35.0}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Icon(
        Icons.money,
        size: size,
        color: Colors.green[100],
      ),
    );
  }
}
