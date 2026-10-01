import 'package:flutter/material.dart';

class AlbumScreen extends StatelessWidget {
  final String id;
  const AlbumScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(child: Text('Álbum', style: TextStyle(color: Colors.white))),
    );
  }
}
