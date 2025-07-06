import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/audio/bloc/audio_bloc.dart';
import '../features/audio/bloc/audio_event.dart';
import '../features/audio/bloc/audio_state.dart';
import '../shared/models/audio_model.dart';
import 'audio_player_page.dart';

class AllSongsPage extends StatelessWidget {
  final List<AudioTrack> tracks;

  const AllSongsPage({super.key, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'All Songs',
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
      body:
          tracks.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Color(0xFF94A3B8)),
                    SizedBox(height: 16),
                    Text(
                      'No songs available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return _buildSongCard(track, context);
                },
              ),
    );
  }

  Widget _buildSongCard(AudioTrack track, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Auto-play the song
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
        decoration: BoxDecoration(
          color: Colors.white,
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      track.artworkUrl ??
                          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: BlocBuilder<AudioBloc, AudioState>(
                        builder: (context, state) {
                          final isFavorite = state.favoriteTracks.any(
                            (t) => t.id == track.id,
                          );
                          return IconButton(
                            onPressed: () {
                              context.read<AudioBloc>().add(
                                AudioToggleFavoriteEvent(track),
                              );
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
