import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtworkWidget extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final double radius;

  const ArtworkWidget({
    super.key,
    this.url,
    this.width = 48,
    this.height = 48,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url != null && url!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildFallback(),
              errorWidget: (context, url, error) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF242424),
      child: const Icon(Icons.music_note, color: Color(0xFF9E9E9E)),
    );
  }
}
