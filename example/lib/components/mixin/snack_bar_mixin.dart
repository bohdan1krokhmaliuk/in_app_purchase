import 'package:flutter/material.dart';

mixin SnackBarMixin<T extends StatefulWidget> on State<T> {
  static const _snackBarStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  void showSnackbar(
    final String text, {
    final Widget? icon,
    final Color color = Colors.green,
    final TextStyle? style = _snackBarStyle,
    final Duration duration = const Duration(seconds: 1),
  }) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: color,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 5.0)],
              Flexible(
                child: Text(
                  text,
                  maxLines: 3,
                  style: style,
                ),
              ),
              if (icon != null) ...[const SizedBox(width: 5.0), icon],
            ],
          ),
        ),
      );
    }
  }
}
