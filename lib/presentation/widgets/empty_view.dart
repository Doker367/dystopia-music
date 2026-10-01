import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyView({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF9E9E9E), size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}
