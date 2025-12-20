import 'package:flutter/material.dart';

class InfoNotificationWidget extends StatelessWidget {
  final List<String> messages;

  const InfoNotificationWidget({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: messages.asMap().entries.map((entry) {
        int index = entry.key;
        String message = entry.value;
        bool hasDot = index == 0; // Only the first message has the orange dot

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
              child: Row(
                children: [
                  if (hasDot)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasDot)
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            if (index != messages.length - 1)
              const Divider(height: 1, thickness: 1),
          ],
        );
      }).toList(),
    );
  }
}

