import 'package:flutter/material.dart';

class PurchaseCard extends StatelessWidget {
  const PurchaseCard({
    Key? key,
    required final this.text,
    required final this.price,
    required final this.callback,
    final this.icon,
    final this.textStyle = const TextStyle(fontSize: 18.0),
    final this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 12.0,
    ),
  }) : super(key: key);

  final Widget? icon;
  final String text;
  final String price;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Card(
        elevation: 10,
        child: Container(
          height: 80.0,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
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
        ),
      ),
    );
  }
}
