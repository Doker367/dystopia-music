import 'package:flutter/material.dart';

class ArtistScreen extends StatelessWidget {
  final String id;
  const ArtistScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(child: Text('Artista', style: TextStyle(color: Colors.white))),
    );
  }
}
