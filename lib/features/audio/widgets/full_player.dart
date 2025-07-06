import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class FullPlayer extends StatefulWidget {
  final AudioTrack track;
  final AudioPlaylist? playlist;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration? totalDuration;
  final double volume;
  final double playbackSpeed;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final bool isFavorite;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function(Duration) onSeek;
  final Function(double) onVolumeChange;
  final Function(double) onSpeedChange;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onMinimize;

  const FullPlayer({
    super.key,
    required this.track,
    this.playlist,
    required this.isPlaying,
    required this.currentPosition,
    this.totalDuration,
    required this.volume,
    required this.playbackSpeed,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.isFavorite,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeek,
    required this.onVolumeChange,
    required this.onSpeedChange,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
    required this.onFavoriteToggle,
    required this.onMinimize,
  });

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  bool _isDragging = false;
  bool _showVolumeSlider = false;
  bool _showSpeedSlider = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(FullPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Artwork
            Expanded(flex: 3, child: _buildArtwork()),

            // Track info
            _buildTrackInfo(),

            // Progress bar
            _buildProgressBar(),

            // Controls
            _buildControls(),

            // Additional controls
            _buildAdditionalControls(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onMinimize,
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          if (widget.playlist != null) ...[
            Column(
              children: [
                Text(
                  'From Playlist',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  widget.playlist!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () {
              // Show more options
            },
            icon: const Icon(Icons.more_vert),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        margin: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      widget.track.artworkUrl != null
                          ? (widget.track.artworkUrl!.startsWith('http')
                              ? CachedNetworkImage(
                                imageUrl: widget.track.artworkUrl!,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(
                                        Icons.music_note,
                                        size: 80,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                              )
                              : Image.asset(
                                widget.track.artworkUrl!,
                                fit: BoxFit.cover,
                              ))
                          : Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.music_note,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                          ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            widget.track.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.track.artist,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final duration = widget.totalDuration ?? Duration.zero;
    final position = widget.currentPosition;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value:
                  duration.inMilliseconds > 0
                      ? (position.inMilliseconds / duration.inMilliseconds)
                          .clamp(0.0, 1.0)
                      : 0.0,
              onChanged: (value) {
                if (duration.inMilliseconds > 0) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  widget.onSeek(newPosition);
                }
              },
              onChangeStart: (value) {
                setState(() {
                  _isDragging = true;
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            onPressed: widget.onShuffleToggle,
            icon: Icon(
              Icons.shuffle,
              color:
                  widget.isShuffleEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            iconSize: 28,
          ),

          // Previous
          IconButton(
            onPressed: widget.onPrevious,
            icon: const Icon(Icons.skip_previous),
            color: AppColors.textPrimary,
            iconSize: 36,
          ),

          // Play/Pause
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: widget.onPlayPause,
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),

          // Next
          IconButton(
            onPressed: widget.onNext,
            icon: const Icon(Icons.skip_next),
            color: AppColors.textPrimary,
            iconSize: 36,
          ),

          // Repeat
          IconButton(
            onPressed: widget.onRepeatToggle,
            icon: Icon(
              widget.repeatMode == RepeatMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color:
                  widget.repeatMode != RepeatMode.off
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Volume
          IconButton(
            onPressed: () {
              setState(() {
                _showVolumeSlider = !_showVolumeSlider;
                _showSpeedSlider = false;
              });
            },
            icon: Icon(
              widget.volume == 0
                  ? Icons.volume_off
                  : widget.volume < 0.5
                  ? Icons.volume_down
                  : Icons.volume_up,
              color: AppColors.textSecondary,
            ),
          ),

          // Favorite
          IconButton(
            onPressed: widget.onFavoriteToggle,
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : AppColors.textSecondary,
            ),
          ),

          // Speed
          IconButton(
            onPressed: () {
              setState(() {
                _showSpeedSlider = !_showSpeedSlider;
                _showVolumeSlider = false;
              });
            },
            icon: Icon(Icons.speed, color: AppColors.textSecondary),
          ),

          // Sleep timer
          IconButton(
            onPressed: () {
              // Show sleep timer options
            },
            icon: Icon(Icons.bedtime, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
