import 'package:flutter/material.dart';

class AudioPlayerPage extends StatefulWidget {
  final String title;
  final String artist;
  final String imageUrl;

  const AudioPlayerPage({
    super.key,
    required this.title,
    required this.artist,
    required this.imageUrl,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  bool _isPlaying = false;
  double _currentPosition = 1.46;
  double _duration = 3.40;
  double _volume = 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
        ),
        title: Text(
          'Now Playing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildAlbumArt(),
              const SizedBox(height: 32),
              _buildSongInfo(),
              const SizedBox(height: 32),
              _buildProgressBar(),
              const SizedBox(height: 32),
              _buildPlaybackControls(),
              const SizedBox(height: 24),
              _buildVolumeControl(),
              const Spacer(),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          widget.artist,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _currentPosition,
            min: 0,
            max: _duration,
            onChanged: (value) {
              setState(() {
                _currentPosition = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.outlined(
          onPressed: () {},
          icon: Icon(
            Icons.shuffle_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 24,
        ),
        IconButton.filled(
          onPressed: () {},
          icon: Icon(
            Icons.skip_previous_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16),
          ),
        ),
        FloatingActionButton.large(
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 36,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        IconButton.filled(
          onPressed: () {},
          icon: Icon(
            Icons.skip_next_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16),
          ),
        ),
        IconButton.outlined(
          onPressed: () {},
          icon: Icon(
            Icons.repeat_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildVolumeControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.volume_down_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacity(0.3),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                  },
                ),
              ),
            ),
            Icon(
              Icons.volume_up_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.queue_music_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.favorite_border_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.share_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatDuration(double minutes) {
    final totalSeconds = (minutes * 60).round();
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
