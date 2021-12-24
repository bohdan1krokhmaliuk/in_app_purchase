import 'package:flutter/material.dart';

class ProductComponent extends StatelessWidget {
  const ProductComponent({
    Key? key,
    required final this.text,
    required final this.price,
    required final this.callback,
    final this.icon,
    final this.buttonColor = Colors.green,
    final this.textStyle = const TextStyle(fontSize: 16.0, color: Colors.black),
  }) : super(key: key);

  final String text;
  final String price;
  final Color buttonColor;
  final TextStyle textStyle;

  final Widget? icon;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0,
      width: double.infinity,
      child: Row(
        children: [
          if (icon != null) icon!,
          const SizedBox(width: 5.0),
          Expanded(
            child: Text(
              text,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: callback,
            child: Text(price),
            style: TextButton.styleFrom(
              minimumSize: const Size(70, 30),
              backgroundColor: buttonColor,
              primary: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
