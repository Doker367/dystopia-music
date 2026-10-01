import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtistCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const ArtistCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF242424),
              backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl!) : null,
              child: imageUrl == null ? const Icon(Icons.person, size: 40, color: Color(0xFF9E9E9E)) : null,
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
