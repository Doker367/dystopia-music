import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String title;
  final int songCount;
  final VoidCallback onTap;

  const PlaylistCard({super.key, required this.title, required this.songCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF242424), Color(0xFF1A1A1A)]),
              ),
              child: const Center(child: Icon(Icons.queue_music, color: Color(0xFF9E9E9E), size: 48)),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
            Text('$songCount canciones', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
