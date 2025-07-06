import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/audio/bloc/audio_bloc.dart';
import '../features/audio/bloc/audio_event.dart';
import '../features/audio/bloc/audio_state.dart';
import '../shared/models/audio_model.dart';
import '../shared/widgets/bottom_navigation.dart';
import '../core/theme/app_colors.dart';
import 'audio_player_page.dart';
import 'favorites_page.dart';
import 'all_songs_page.dart';

class AudioTherapyPage extends StatefulWidget {
  const AudioTherapyPage({super.key});

  @override
  State<AudioTherapyPage> createState() => _AudioTherapyPageState();
}

class _AudioTherapyPageState extends State<AudioTherapyPage> {
  @override
  void initState() {
    super.initState();
    // Initialize audio when page loads
    context.read<AudioBloc>().add(const AudioInitializeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'Audio Therapy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
      body: const _AudioTherapyBody(),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: '/audio-therapy',
      ),
    );
  }
}

class _AudioTherapyBody extends StatelessWidget {
  const _AudioTherapyBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioPlayerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecentlyPlayedSection(playlists: state.playlists),
              const SizedBox(height: 24),
              _PopularSection(tracks: state.availableTracks),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _RecentlyPlayedSection extends StatelessWidget {
  final List<AudioPlaylist> playlists;

  const _RecentlyPlayedSection({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (playlists.isNotEmpty)
              Expanded(child: _buildLargePlaylistCard(playlists[0], context)),
            const SizedBox(width: 12),
            if (playlists.length > 1)
              Expanded(child: _buildLargePlaylistCard(playlists[1], context)),
          ],
        ),
      ],
    );
  }

  Widget _buildLargePlaylistCard(AudioPlaylist playlist, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Load playlist, auto-play and navigate to audio player
        context.read<AudioBloc>().add(AudioLoadPlaylistEvent(playlist.tracks));
        context.read<AudioBloc>().add(const AudioPlayEvent());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AudioPlayerPage(
              title: playlist.name,
              artist: 'Mentally Audio',
              imageUrl:
                  playlist.artworkUrl ??
                  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(
                    playlist.artworkUrl ??
                        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          playlist.description ??
                              '${playlist.tracks.length} tracks',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularSection extends StatelessWidget {
  final List<AudioTrack> tracks;

  const _PopularSection({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AllSongsPage(tracks: tracks),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          tracks.length > 5 ? 5 : tracks.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAudioListItem(tracks[index], context),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioListItem(AudioTrack track, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Load single track, auto-play and navigate to player
        context.read<AudioBloc>().add(AudioLoadPlaylistEvent([track]));
        context.read<AudioBloc>().add(const AudioPlayEvent());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AudioPlayerPage(
              title: track.title,
              artist: track.artist,
              imageUrl:
                  track.artworkUrl ??
                  'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    track.artworkUrl ??
                        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                final isFavorite = state.favoriteTracks.any(
                  (t) => t.id == track.id,
                );
                return IconButton(
                  onPressed: () {
                    // Toggle favorite
                    context.read<AudioBloc>().add(
                      AudioToggleFavoriteEvent(track),
                    );
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : const Color(0xFF64748B),
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioItem {
  final String title;
  final String artist;
  final String imageUrl;
  final bool isFavorited;
  final bool isLarge;

  const _AudioItem({
    required this.title,
    required this.artist,
    required this.imageUrl,
    this.isFavorited = false,
    this.isLarge = false,
  });
}

class _BottomNavigationWidget extends StatelessWidget {
  const _BottomNavigationWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                Icons.home,
                'Home',
                context,
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.people_outline,
                'Community',
                context,
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                'Profile',
                context,
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    BuildContext context, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF1E3A8A)
                : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
