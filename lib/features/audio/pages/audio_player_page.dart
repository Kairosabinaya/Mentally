import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/models/audio_model.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/audio_player_controls.dart';
import '../widgets/audio_progress_bar.dart';
import '../widgets/audio_track_info.dart';
import '../widgets/audio_playlist_view.dart';
import '../widgets/audio_volume_slider.dart';
import '../widgets/audio_speed_selector.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/ai_consultation_fab.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _artworkController;
  late AnimationController _controlsController;
  late Animation<double> _artworkAnimation;
  late Animation<double> _controlsAnimation;
  bool _showPlaylist = false;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controlsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _artworkAnimation = CurvedAnimation(
      parent: _artworkController,
      curve: Curves.easeInOut,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsController,
      curve: Curves.easeInOut,
    );

    _artworkController.forward();
    _controlsController.forward();

    context.read<AudioBloc>().add(const AudioInitializeEvent());
  }

  @override
  void dispose() {
    _artworkController.dispose();
    _controlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Audio Therapy'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Track info section
                if (state.currentTrack != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AudioTrackInfo(
                      track: state.currentTrack!,
                      isFavorite: state.isTrackFavorite(state.currentTrack!.id),
                      onFavoriteToggle: () {
                        context.read<AudioBloc>().add(
                          AudioToggleFavoriteEvent(state.currentTrack!),
                        );
                      },
                    ),
                  ),

                // Progress bar
                if (state.currentTrack != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AudioProgressBar(
                      position: state.position,
                      duration: state.duration,
                      onSeek: (position) {
                        context.read<AudioBloc>().add(AudioSeekEvent(position));
                      },
                    ),
                  ),

                // Player controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AudioPlayerControls(
                    isPlaying: state.isPlaying,
                    canGoPrevious: state.canGoPrevious,
                    canGoNext: state.canGoNext,
                    onPlayPause: () {
                      if (state.isPlaying) {
                        context.read<AudioBloc>().add(const AudioPauseEvent());
                      } else {
                        context.read<AudioBloc>().add(const AudioPlayEvent());
                      }
                    },
                    onNext: () {
                      context.read<AudioBloc>().add(const AudioNextEvent());
                    },
                    onPrevious: () {
                      context.read<AudioBloc>().add(const AudioPreviousEvent());
                    },
                  ),
                ),

                // Speed selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AudioSpeedSelector(
                    currentSpeed: state.playbackSpeed,
                    onSpeedChanged: (speed) {
                      context.read<AudioBloc>().add(AudioSetSpeedEvent(speed));
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Playlist
                Expanded(
                  child: AudioPlaylistView(
                    playlists: state.playlists,
                    currentPlaylist: state.currentPlaylist,
                    onPlaylistSelected: (playlist) {
                      context.read<AudioBloc>().add(
                        AudioLoadPlaylistEvent(playlist.tracks),
                      );
                    },
                    onTrackSelected: (trackIndex) {
                      if (trackIndex < state.currentPlaylist.length) {
                        context.read<AudioBloc>().add(
                          AudioSelectTrackEvent(trackIndex),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            currentRoute: '/audio-therapy',
          ),
          floatingActionButton: const AiConsultationFab(),
        );
      },
    );
  }

  Widget _buildPlayerView(BuildContext context, AudioState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Album artwork
          _buildArtwork(state),

          const SizedBox(height: 40),

          // Track info
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _controlsAnimation.value)),
                child: Opacity(
                  opacity: _controlsAnimation.value,
                  child: AudioTrackInfo(
                    track: state.currentTrack,
                    isFavorite: state.currentTrack != null
                        ? state.isTrackFavorite(state.currentTrack!.id)
                        : false,
                    onFavoriteToggle: () {
                      if (state.currentTrack != null) {
                        context.read<AudioBloc>().add(
                          AudioToggleFavoriteEvent(state.currentTrack!),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Progress bar
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _controlsAnimation.value)),
                child: Opacity(
                  opacity: _controlsAnimation.value,
                  child: AudioProgressBar(
                    position: state.position,
                    duration: state.duration,
                    onSeek: (position) {
                      context.read<AudioBloc>().add(AudioSeekEvent(position));
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Player controls
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - _controlsAnimation.value)),
                child: Opacity(
                  opacity: _controlsAnimation.value,
                  child: AudioPlayerControls(
                    isPlaying: state.isPlaying,
                    canGoPrevious: state.canGoPrevious,
                    canGoNext: state.canGoNext,
                    onPlayPause: () {
                      context.read<AudioBloc>().add(
                        const AudioTogglePlayPauseEvent(),
                      );
                    },
                    onPrevious: () {
                      context.read<AudioBloc>().add(const AudioPreviousEvent());
                    },
                    onNext: () {
                      context.read<AudioBloc>().add(const AudioNextEvent());
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Additional controls
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _controlsAnimation.value)),
                child: Opacity(
                  opacity: _controlsAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Volume control
                      Expanded(
                        child: AudioVolumeSlider(
                          volume: state.volume,
                          onVolumeChanged: (volume) {
                            context.read<AudioBloc>().add(
                              AudioSetVolumeEvent(volume),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Speed control
                      AudioSpeedSelector(
                        currentSpeed: state.playbackSpeed,
                        onSpeedChanged: (speed) {
                          context.read<AudioBloc>().add(
                            AudioSetPlaybackSpeedEvent(speed),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildArtwork(AudioState state) {
    return AnimatedBuilder(
      animation: _artworkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _artworkAnimation.value),
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: state.currentTrack?.artworkUrl != null
                  ? Image.asset(
                      state.currentTrack!.artworkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultArtwork();
                      },
                    )
                  : _buildDefaultArtwork(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultArtwork() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, size: 80, color: AppColors.textOnPrimary),
      ),
    );
  }
}
