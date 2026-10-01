
import 'package:go_router/go_router.dart';

import 'package:dystopia/presentation/screens/home/home_screen.dart';
import 'package:dystopia/presentation/screens/search/search_screen.dart';
import 'package:dystopia/presentation/screens/library/library_screen.dart';
import 'package:dystopia/presentation/screens/downloads/downloads_screen.dart';
import 'package:dystopia/presentation/screens/settings/settings_screen.dart';
import 'package:dystopia/presentation/screens/player/full_player_screen.dart';
import 'package:dystopia/presentation/screens/player/queue_screen.dart';
import 'package:dystopia/presentation/screens/artist/artist_screen.dart';
import 'package:dystopia/presentation/screens/album/album_screen.dart';
import 'package:dystopia/presentation/screens/playlist/playlist_screen.dart';
import 'package:dystopia/presentation/screens/favorites/favorites_screen.dart';
import 'package:dystopia/presentation/screens/app_shell.dart';

final goRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const FullPlayerScreen(),
    ),
    GoRoute(
      path: '/queue',
      builder: (context, state) => const QueueScreen(),
    ),
    GoRoute(
      path: '/artist/:id',
      builder: (context, state) => ArtistScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/album/:id',
      builder: (context, state) => AlbumScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/playlist/:id',
      builder: (context, state) => PlaylistScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
  ],
);
