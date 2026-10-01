import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/providers/app_providers.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/screens/playlist/create_playlist_dialog.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicProvider = ref.watch(musicProviderProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          elevation: 0,
          title: const Text(
            'BIBLIOTECA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              fontSize: 20,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFA8B545),
            labelColor: Color(0xFFA8B545),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Canciones'),
              Tab(text: 'Playlists'),
              Tab(text: 'Artistas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Canciones Tab
            FutureBuilder(
              future: musicProvider.getTrending(limit: 50),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFA8B545)));
                }
                final songs = snapshot.data!;
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
                  itemCount: songs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      tileColor: const Color(0xFF16161A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      leading: ArtworkWidget(url: song.artworkUrl, width: 44, height: 44, radius: 8),
                      title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(song.artist, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFA8B545), size: 28),
                        onPressed: () {
                          ref.read(playerControllerProvider.notifier).playSong(song);
                        },
                      ),
                      onTap: () {
                        ref.read(playerControllerProvider.notifier).playSong(song);
                      },
                    );
                  },
                );
              },
            ),

            // Playlists Tab
            ValueListenableBuilder<Box<Playlist>>(
              valueListenable: Hive.box<Playlist>('playlists').listenable(),
              builder: (context, box, _) {
                final playlists = box.values.toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
                  children: [
                    // Create Playlist Button Card
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final created = await showDialog<Playlist>(
                          context: context,
                          builder: (_) => const CreatePlaylistDialog(),
                        );
                        if (created != null && context.mounted) {
                          context.push('/playlist/${created.id}');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8B545).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: Color(0xFFA8B545), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'NUEVA PLAYLIST',
                              style: TextStyle(
                                color: Color(0xFFA8B545),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (playlists.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                          child: Column(
                            children: [
                              Opacity(
                                opacity: 0.35,
                                child: Image.asset(
                                  'assets/images/distopia_logo_transparent.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'SIN PLAYLISTS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Crea tu primera lista con el botón de arriba.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...playlists.map((pl) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPlaylistTile(
                              title: pl.name,
                              subtitle: '${pl.songCount} canciones • ${pl.description.isNotEmpty ? pl.description : "Lista personal"}',
                              icon: Icons.queue_music_rounded,
                              onTap: () => context.push('/playlist/${pl.id}'),
                            ),
                          )),
                  ],
                );
              },
            ),

            // Artistas Tab
            ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
              children: [
                _buildArtistTile('Cyber Synth', '2 pistas disponibles', 'https://picsum.photos/seed/artist1/500/500'),
                const SizedBox(height: 8),
                _buildArtistTile('Byte Master', '1 pista disponible', 'https://picsum.photos/seed/artist2/500/500'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: const Color(0xFF16161A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFA8B545), Color(0xFF00E5FF)],
          ),
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildArtistTile(String name, String tracks, String imageUrl) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: const Color(0xFF16161A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ArtworkWidget(url: imageUrl, width: 48, height: 48, radius: 24),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(tracks, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
