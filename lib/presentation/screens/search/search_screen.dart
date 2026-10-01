import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/providers/search_provider.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/apple_download_button.dart';
import 'package:dystopia/presentation/widgets/song_options_modal.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  void _triggerGenreSearch(String genre) {
    HapticFeedback.lightImpact();
    _controller.text = genre;
    ref.read(searchProvider.notifier).search(genre);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'EXPLORAR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFA8B545).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFFA8B545),
                decoration: InputDecoration(
                  hintText: 'Buscar Rock, Pop, Reggae...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA8B545)),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            _controller.clear();
                            ref.read(searchProvider.notifier).clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (val) {
                  setState(() {});
                  ref.read(searchProvider.notifier).search(val);
                },
              ),
            ),
          ),

          // Genre Quick Search Chips (Rock, Pop, Reggae)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickGenreChip('Rock Clásico', Icons.electric_bolt_rounded),
                  const SizedBox(width: 8),
                  _buildQuickGenreChip('Pop Hits', Icons.star_rounded),
                  const SizedBox(width: 8),
                  _buildQuickGenreChip('Reggae Vibes', Icons.spa_rounded),
                  const SizedBox(width: 8),
                  _buildQuickGenreChip('Anthemic Rock', Icons.album_rounded),
                ],
              ),
            ),
          ),

          // Search results
          Expanded(
            child: searchState.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFA8B545)),
                        SizedBox(height: 12),
                        Text(
                          'Buscando en el catálogo...',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : (searchState.results != null && searchState.results!.songs.isNotEmpty)
                    ? ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 140),
                        itemCount: searchState.results!.songs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final song = searchState.results!.songs[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            tileColor: const Color(0xFF16161A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            leading: ArtworkWidget(url: song.artworkUrl, width: 44, height: 44, radius: 8),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Apple Music Style Download Button
                                AppleDownloadButton(song: song, size: 32),
                                // Options Menu
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                  onPressed: () => SongOptionsModal.show(context, ref, song),
                                ),
                                // Listen / Play Button
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Color(0xFFA8B545),
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(playerControllerProvider.notifier).playQueue(searchState.results!.songs, startIndex: index);
                                  },
                                ),
                              ],
                            ),
                            onLongPress: () => SongOptionsModal.show(context, ref, song),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(playerControllerProvider.notifier).playQueue(searchState.results!.songs, startIndex: index);
                            },
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.35,
                              child: Image.asset(
                                'assets/images/distopia_logo_transparent.png',
                                width: 110,
                                height: 110,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _controller.text.isEmpty
                                  ? 'Busca por artista o canción de Rock, Pop y Reggae'
                                  : 'No se encontraron pistas',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGenreChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _triggerGenreSearch(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16161A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA8B545).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFA8B545), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
