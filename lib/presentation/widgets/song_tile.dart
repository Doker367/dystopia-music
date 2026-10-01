import 'package:flutter/material.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool isLoading;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListTile(
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF242424), borderRadius: BorderRadius.circular(8))),
        title: Container(width: 100, height: 16, color: const Color(0xFF242424)),
        subtitle: Container(width: 60, height: 14, color: const Color(0xFF242424)),
      );
    }
    return ListTile(
      onTap: onTap,
      leading: ArtworkWidget(url: song.artworkUrl, width: 48, height: 48, radius: 8),
      title: Text(song.title, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, style: const TextStyle(color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
        onPressed: () {},
      ),
    );
  }
}
