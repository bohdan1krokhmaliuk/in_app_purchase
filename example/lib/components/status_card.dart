import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({Key? key, required this.isPluginInitialized})
      : super(key: key);

  final bool isPluginInitialized;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              isPluginInitialized ? Icons.check : Icons.close,
              color: isPluginInitialized ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              isPluginInitialized
                  ? 'Plugin initialized'
                  : 'Plugin not initialized',
              style: const TextStyle(fontSize: 16.0),
            )
          ],
        ),
      ),
    );
  }
}
