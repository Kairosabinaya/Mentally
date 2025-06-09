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
      backgroundColor: const Color(0xFFF0F4FF),
      body: GestureDetector(
        onPanUpdate: (details) {
          // If swiping down, dismiss the page
          if (details.delta.dy > 0) {
            // Optional: Add some threshold for sensitivity
          }
        },
        onPanEnd: (details) {
          // If swipe down with sufficient velocity, dismiss
          if (details.velocity.pixelsPerSecond.dy > 300) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildAlbumArt(),
                      const SizedBox(height: 24),
                      _buildSongInfo(),
                      const SizedBox(height: 24),
                      _buildProgressBar(),
                      const SizedBox(height: 24),
                      _buildPlaybackControls(),
                      const SizedBox(height: 24),
                      _buildVolumeControl(),
                      const Spacer(),
                      _buildBottomControls(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1E3A8A),
            size: 28,
          ),
        ),
        const Text(
          'Now Playing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.equalizer, color: Color(0xFF1E3A8A), size: 24),
        ),
      ],
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          widget.artist,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF94A3B8),
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
            activeTrackColor: const Color(0xFF1E3A8A),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF1E3A8A),
            overlayColor: const Color(0xFF1E3A8A).withOpacity(0.2),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
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
        _buildControlButton(
          icon: Icons.skip_previous,
          size: 40,
          onPressed: () {},
        ),
        _buildControlButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          size: 56,
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          isPrimary: true,
        ),
        _buildControlButton(icon: Icons.skip_next, size: 40, onPressed: () {}),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 80 : 60,
      height: isPrimary ? 80 : 60,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF1E3A8A), size: size),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: Color(0xFF1E3A8A), size: 24),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1E3A8A),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF1E3A8A),
              overlayColor: const Color(0xFF1E3A8A).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
        const Icon(Icons.volume_up, color: Color(0xFF1E3A8A), size: 24),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.shuffle, color: Color(0xFF64748B), size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.repeat, color: Color(0xFF64748B), size: 24),
        ),
      ],
    );
  }

  String _formatDuration(double minutes) {
    int totalSeconds = (minutes * 60).round();
    int mins = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
