import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/audio/bloc/audio_bloc.dart';
import '../features/audio/bloc/audio_event.dart';
import '../features/audio/bloc/audio_state.dart';
import '../shared/models/audio_model.dart';
import 'audio_player_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state.status == AudioPlayerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.favoriteTracks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start liking songs to see them here',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.favoriteTracks.length,
            itemBuilder: (context, index) {
              final track = state.favoriteTracks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFavoriteTrackItem(track, context),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteTrackItem(AudioTrack track, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Load single track, auto-play and navigate to player
        context.read<AudioBloc>().add(AudioLoadPlaylistEvent([track]));
        context.read<AudioBloc>().add(const AudioPlayEvent());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => AudioPlayerPage(
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
            IconButton(
              onPressed: () {
                // Remove from favorites
                context.read<AudioBloc>().add(AudioToggleFavoriteEvent(track));
              },
              icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
