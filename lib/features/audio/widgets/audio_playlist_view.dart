import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class AudioPlaylistView extends StatelessWidget {
  final List<AudioPlaylist> playlists;
  final List<AudioTrack> currentPlaylist;
  final Function(AudioPlaylist) onPlaylistSelected;
  final Function(int) onTrackSelected;

  const AudioPlaylistView({
    super.key,
    required this.playlists,
    required this.currentPlaylist,
    required this.onPlaylistSelected,
    required this.onTrackSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primaryLight.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.queue_music,
                  color: AppColors.textOnPrimary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Playlists',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Playlists list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _buildPlaylistCard(playlist);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(AudioPlaylist playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onPlaylistSelected(playlist),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Playlist header
                Row(
                  children: [
                    // Artwork
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child:
                          playlist.artworkUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  playlist.artworkUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.music_note,
                                      color: AppColors.textOnPrimary,
                                      size: 30,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.music_note,
                                color: AppColors.textOnPrimary,
                                size: 30,
                              ),
                    ),

                    const SizedBox(width: 16),

                    // Playlist info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            playlist.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${playlist.tracks.length} tracks',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Play button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // Track list preview (first 3 tracks)
                if (playlist.tracks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  ...playlist.tracks.take(3).toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final track = entry.value;
                    return _buildTrackPreview(track, index);
                  }),
                  if (playlist.tracks.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${playlist.tracks.length - 3} more tracks',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackPreview(AudioTrack track, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Track number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Duration
          Text(
            track.formattedDuration,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
