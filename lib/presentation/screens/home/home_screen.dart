import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/core/services/permission_service.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/providers/youtube_music_provider.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/section_header.dart';
import 'package:dystopia/presentation/widgets/apple_download_button.dart';
import 'package:dystopia/presentation/widgets/song_options_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedGenre = 'Todos';
  late String _audioMode;
  late bool _crossfade;

  @override
  void initState() {
    super.initState();
    final box = Hive.isBoxOpen('settings') ? Hive.box('settings') : null;
    _audioMode = box?.get('audioDspMode', defaultValue: 'HIFI 320K') ?? 'HIFI 320K';
    _crossfade = box?.get('crossfade', defaultValue: true) ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPermissions();
      try {
        ref.read(audioPlayerServiceProvider).setDspMode(_audioMode);
      } catch (e) {
        debugPrint('[HomeScreen] setDspMode error: $e');
      }
    });
  }

  Future<void> _initPermissions() async {
    try {
      // Request storage and notification permissions on startup
      await PermissionService.requestStoragePermission();
      await PermissionService.requestNotificationPermission();
    } catch (e) {
      debugPrint('[HomeScreen] Permission init error: $e');
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'BUENOS DÍAS';
    if (hour < 20) return 'BUENAS TARDES';
    return 'BUENAS NOCHES';
  }

  List<Song> get _filteredSongs {
    switch (_selectedGenre) {
      case 'Rock':
        return YouTubeMusicProvider.rockSongs;
      case 'Pop':
        return YouTubeMusicProvider.popSongs;
      case 'Reggae':
        return YouTubeMusicProvider.reggaeSongs;
      default:
        return [
          ...YouTubeMusicProvider.rockSongs,
          ...YouTubeMusicProvider.popSongs,
          ...YouTubeMusicProvider.reggaeSongs,
        ];
    }
  }



  Future<void> _handleFavoriteToggle(Song song) async {
    HapticFeedback.lightImpact();
    final favBox = Hive.box('favorites');
    final isFav = favBox.containsKey(song.id) || favBox.values.contains(song.id);
    if (isFav) {
      await favBox.delete(song.id);
      final legacyKeys = favBox.keys.where((k) => favBox.get(k) == song.id).toList();
      for (final k in legacyKeys) {
        await favBox.delete(k);
      }
    } else {
      await Hive.box<Song>('songs').put(song.id, song);
      await favBox.put(song.id, song.id);
    }
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFav ? 'Eliminada de Favoritos' : 'Añadida a Favoritos'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF1E1E24),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = _filteredSongs;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Cyberpunk Glassmorphic Header with Transparent Logo
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
            elevation: 0,
            floating: true,
            pinned: false,
            toolbarHeight: 74,
            title: Row(
              children: [
                // Distopia Logo Transparent with Ambient Glow
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/distopia_logo_transparent.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'DYSTOPIA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFA8B545).withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'CORE',
                            style: TextStyle(
                              color: Color(0xFFA8B545),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _greeting,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () => context.go('/explore'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Processing Mode Pills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAudioModePill('HIFI 320K', Icons.album_rounded),
                          const SizedBox(width: 8),
                          _buildAudioModePill('BASS BOOST', Icons.equalizer_rounded),
                          const SizedBox(width: 8),
                          _buildAudioModePill('REVERB NEON', Icons.surround_sound_rounded),
                          const SizedBox(width: 8),
                          _buildCrossfadePill(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Hero Cyber Banner with logosinfondo.png Transparent
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 165,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1F1A), Color(0xFF13151A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Transparent Logo Feature
                          Positioned(
                            right: -10,
                            bottom: -15,
                            top: -15,
                            child: Opacity(
                              opacity: 0.28,
                              child: Image.asset(
                                'assets/images/distopia_logo_transparent.png',
                                width: 190,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA8B545),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ROCK • POP • REGGAE',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ONLINE & DESCARGAS',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Sonido Atmosférico\ny Futurista',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (songs.isNotEmpty) {
                                      HapticFeedback.mediumImpact();
                                      ref.read(playerControllerProvider.notifier).playQueue(songs);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA8B545),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          spreadRadius: -1,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                                        SizedBox(width: 4),
                                        Text(
                                          'Reproducir Todo',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Functional Genre Filter Chips (Rock, Pop, Reggae - NO BANDA)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildGenreChip('Todos', Icons.all_inclusive_rounded),
                          const SizedBox(width: 8),
                          _buildGenreChip('Rock', Icons.electric_bolt_rounded),
                          const SizedBox(width: 8),
                          _buildGenreChip('Pop', Icons.star_rounded),
                          const SizedBox(width: 8),
                          _buildGenreChip('Reggae', Icons.spa_rounded),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Escuchado recientemente (Horizontal Carousel)
                  SectionHeader(
                    title: 'Destacados // $_selectedGenre',
                    onSeeAll: () => context.go('/explore'),
                  ),
                  SizedBox(
                    height: 195,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return _RecentSongCard(
                          song: song,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(playerControllerProvider.notifier).playQueue(songs, startIndex: index);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pistas Principales
                  SectionHeader(
                    title: 'Pistas Disponibles (${songs.length})',
                    onSeeAll: () => context.go('/explore'),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: songs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isFav = Hive.box('favorites').containsKey(song.id);

                      return _SongListCard(
                        song: song,
                        index: index + 1,
                        isFavorite: isFav,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(playerControllerProvider.notifier).playQueue(songs, startIndex: index);
                        },
                        onFavorite: () => _handleFavoriteToggle(song),
                        onMore: () => SongOptionsModal.show(context, ref, song),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label, IconData icon) {
    final isSelected = _selectedGenre == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedGenre = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8B545)
              : const Color(0xFF16161A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA8B545)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioModePill(String title, IconData icon) {
    final isSelected = _audioMode == title;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        setState(() => _audioMode = title);
        try {
          await ref.read(audioPlayerServiceProvider).setDspMode(title);
        } catch (e) {
          debugPrint('[HomeScreen] setDspMode error: $e');
        }

        String desc = '';
        if (title == 'HIFI 320K') {
          desc = 'Sonido puro de estudio y rango dinámico intacto';
        } else if (title == 'BASS BOOST') {
          desc = 'Sub-graves potenciados (+7dB) y pegada dinámica';
        } else if (title == 'REVERB NEON') {
          desc = 'Escenario espacial cyberpunk con agudos cristalinos';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFFA8B545), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Modo DSP: $title',
                        style: const TextStyle(
                          color: Color(0xFFA8B545),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1400),
              backgroundColor: const Color(0xFF1E1E24),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8B545).withValues(alpha: 0.16)
              : const Color(0xFF16161A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFA8B545) : Colors.white12,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.22),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFA8B545) : Colors.grey,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFA8B545) : Colors.grey,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrossfadePill() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final newCrossfade = !_crossfade;
        setState(() => _crossfade = newCrossfade);
        if (Hive.isBoxOpen('settings')) {
          await Hive.box('settings').put('crossfade', newCrossfade);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    newCrossfade ? Icons.check_circle_rounded : Icons.pause_circle_outline_rounded,
                    color: newCrossfade ? const Color(0xFFA8B545) : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    newCrossfade
                        ? 'Fade Automático Activado (Transición suave)'
                        : 'Fade Automático Desactivado',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1400),
              backgroundColor: const Color(0xFF1E1E24),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _crossfade
              ? const Color(0xFFA8B545).withValues(alpha: 0.16)
              : const Color(0xFF16161A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _crossfade ? const Color(0xFFA8B545) : Colors.white12,
            width: 1,
          ),
          boxShadow: _crossfade
              ? [
                  BoxShadow(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.22),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.graphic_eq_rounded,
              color: _crossfade ? const Color(0xFFA8B545) : Colors.grey,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              _crossfade ? 'FADE AUTO: ON' : 'FADE AUTO: OFF',
              style: TextStyle(
                color: _crossfade ? const Color(0xFFA8B545) : Colors.grey,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _RecentSongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ArtworkWidget(
                    url: song.artworkUrl,
                    width: 135,
                    height: 135,
                    radius: 16,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFA8B545),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SongListCard extends StatelessWidget {
  final Song song;
  final int index;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMore;

  const _SongListCard({
    required this.song,
    required this.index,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onMore,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16161A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Color(0xFFA8B545),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            ArtworkWidget(
              url: song.artworkUrl,
              width: 44,
              height: 44,
              radius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Favorite Button
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.redAccent : Colors.white38,
                size: 20,
              ),
              onPressed: onFavorite,
            ),
            // Apple Music Style Download Button
            AppleDownloadButton(song: song, size: 32),
            // Options Button
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white38,
                size: 20,
              ),
              onPressed: onMore,
            ),
            // Play Button
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFFA8B545),
                size: 30,
              ),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
