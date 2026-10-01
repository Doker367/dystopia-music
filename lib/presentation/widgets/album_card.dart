import 'package:flutter/material.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class AlbumCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? artworkUrl;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.title,
    required this.artist,
    this.artworkUrl,
    required this.onTap,
  });

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
            ArtworkWidget(url: artworkUrl, width: 140, height: 140, radius: 12),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(artist, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
