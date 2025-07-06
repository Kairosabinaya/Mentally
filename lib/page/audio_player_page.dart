import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/audio/bloc/audio_bloc.dart';
import '../features/audio/bloc/audio_event.dart';
import '../features/audio/bloc/audio_state.dart';
import '../shared/models/audio_model.dart';
import '../shared/widgets/bottom_navigation.dart';

class AudioPlayerPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100, // Account for bottom nav
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Back button
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Stop audio playback when back button is pressed
                              context.read<AudioBloc>().add(
                                const AudioStopEvent(),
                              );
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back, size: 28),
                          ),
                        ],
                      ),

                      // Album artwork
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),

                      // Track info
                      Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            artist,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      // Progress bar
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              activeTrackColor: const Color(0xFF1E3A8A),
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              thumbColor: const Color(0xFF1E3A8A),
                            ),
                            child: Slider(
                              value: state.position.inMilliseconds.toDouble(),
                              max: state.duration.inMilliseconds
                                  .toDouble()
                                  .clamp(1, double.infinity),
                              onChanged: (value) {
                                context.read<AudioBloc>().add(
                                  AudioSeekEvent(
                                    Duration(milliseconds: value.toInt()),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(state.position),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  _formatDuration(state.duration),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Player controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous button (now backward 10 seconds)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<AudioBloc>().add(
                                  const AudioPreviousEvent(),
                                );
                              },
                              icon: const Icon(
                                Icons.replay_10,
                                size: 30,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),

                          // Play/Pause button
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E3A8A,
                                  ).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (state.isPlaying) {
                                  context.read<AudioBloc>().add(
                                    const AudioPauseEvent(),
                                  );
                                } else {
                                  context.read<AudioBloc>().add(
                                    const AudioPlayEvent(),
                                  );
                                }
                              },
                              icon: Icon(
                                state.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Next button (now forward 10 seconds)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<AudioBloc>().add(
                                  const AudioNextEvent(),
                                );
                              },
                              icon: const Icon(
                                Icons.forward_10,
                                size: 30,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Volume control
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_down,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor: const Color(0xFF1E3A8A),
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                                thumbColor: const Color(0xFF1E3A8A),
                              ),
                              child: Slider(
                                value: state.volume.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  context.read<AudioBloc>().add(
                                    AudioSetVolumeEvent(value),
                                  );
                                },
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.volume_up,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: '/audio-therapy',
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
