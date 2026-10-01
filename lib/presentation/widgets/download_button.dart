import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final bool isDownloading;
  final bool isDownloaded;
  final double progress;
  final VoidCallback onPressed;

  const DownloadButton({super.key, required this.isDownloading, required this.isDownloaded, required this.progress, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: progress, color: const Color(0xFFA8B545)),
          const Icon(Icons.download, color: Color(0xFFA8B545), size: 16),
        ],
      );
    }
    return IconButton(
      icon: Icon(isDownloaded ? Icons.download_done : Icons.download, color: isDownloaded ? const Color(0xFFA8B545) : const Color(0xFF9E9E9E)),
      onPressed: onPressed,
    );
  }
}
