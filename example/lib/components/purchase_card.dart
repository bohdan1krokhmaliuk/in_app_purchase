import 'package:flutter/material.dart';

class PurchaseCard extends StatelessWidget {
  const PurchaseCard({
    Key? key,
    required final this.text,
    required final this.price,
    required final this.callback,
    final this.icon,
    final this.textStyle = const TextStyle(fontSize: 18.0, color: Colors.black),
  }) : super(key: key);

  final Widget? icon;
  final String text;
  final String price;

  final TextStyle textStyle;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (icon != null) icon!,
          const SizedBox(width: 10.0),
          Text(text, style: textStyle),
          const Spacer(),
          TextButton(
            onPressed: callback,
            child: Text(price, style: textStyle),
          )
        ],
      ),
    );
  }
}
