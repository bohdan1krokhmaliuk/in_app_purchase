import 'package:flutter/material.dart';
import 'package:in_app_purchase_example/components/cards/card_base.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({Key? key, required this.isPluginInitialized})
      : super(key: key);

  final bool isPluginInitialized;

  @override
  Widget build(BuildContext context) {
    return CardBase(
      child: Row(
        children: [
          Icon(
            isPluginInitialized ? Icons.check : Icons.close,
            color: isPluginInitialized ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            'Plugin${isPluginInitialized ? ' ' : ' not '}initialized',
            style: const TextStyle(fontSize: 16.0),
          )
        ],
      ),
    );
  }
}
