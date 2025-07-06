import 'package:equatable/equatable.dart';
import '../../../shared/models/audio_model.dart';

enum AudioPlayerStatus {
  initial,
  loading,
  ready,
  playing,
  paused,
  stopped,
  error,
}

class AudioState extends Equatable {
  final AudioPlayerStatus status;
  final List<AudioTrack> availableTracks;
  final List<AudioPlaylist> playlists;
  final List<AudioTrack> favoriteTracks;
  final List<AudioTrack> currentPlaylist;
  final AudioTrack? currentTrack;
  final int currentTrackIndex;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isPlaylistLoaded;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final double volume;
  final double playbackSpeed;
  final bool isMiniPlayerVisible;
  final String? errorMessage;

  const AudioState({
    this.status = AudioPlayerStatus.initial,
    this.availableTracks = const [],
    this.playlists = const [],
    this.favoriteTracks = const [],
    this.currentPlaylist = const [],
    this.currentTrack,
    this.currentTrackIndex = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isPlaylistLoaded = false,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.isMiniPlayerVisible = false,
    this.errorMessage,
  });

  AudioState copyWith({
    AudioPlayerStatus? status,
    List<AudioTrack>? availableTracks,
    List<AudioPlaylist>? playlists,
    List<AudioTrack>? favoriteTracks,
    List<AudioTrack>? currentPlaylist,
    AudioTrack? currentTrack,
    int? currentTrackIndex,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isPlaylistLoaded,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    double? volume,
    double? playbackSpeed,
    bool? isMiniPlayerVisible,
    String? errorMessage,
  }) {
    return AudioState(
      status: status ?? this.status,
      availableTracks: availableTracks ?? this.availableTracks,
      playlists: playlists ?? this.playlists,
      favoriteTracks: favoriteTracks ?? this.favoriteTracks,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentTrack: currentTrack ?? this.currentTrack,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isPlaylistLoaded: isPlaylistLoaded ?? this.isPlaylistLoaded,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
      errorMessage: errorMessage,
    );
  }

  // Helper getters
  bool get hasCurrentTrack => currentTrack != null;
  bool get hasPlaylist => currentPlaylist.isNotEmpty;
  bool get canGoNext => currentTrackIndex < currentPlaylist.length - 1;
  bool get canGoPrevious => currentTrackIndex > 0;
  bool get hasError => status == AudioPlayerStatus.error && errorMessage != null;

  // Progress calculation
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Remaining time
  Duration get remainingTime {
    return duration - position;
  }

  // Format duration
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted position
  String get formattedPosition => formatDuration(position);

  // Get formatted duration
  String get formattedDuration => formatDuration(duration);

  // Get formatted remaining time
  String get formattedRemainingTime => formatDuration(remainingTime);

  // Check if track is favorite
  bool isTrackFavorite(String trackId) {
    return favoriteTracks.any((track) => track.id == trackId);
  }

  // Get playlist by ID
  AudioPlaylist? getPlaylistById(String playlistId) {
    try {
      return playlists.firstWhere((playlist) => playlist.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  // Get tracks by category
  List<AudioTrack> getTracksByCategory(String category) {
    return availableTracks
        .where((track) => track.category == category)
        .toList();
  }

  // Get all categories
  List<String> get availableCategories {
    return availableTracks.map((track) => track.category.name).toSet().toList()
      ..sort();
  }

  // Get recently played tracks (this would typically come from a separate data source)
  List<AudioTrack> get recentTracks {
    // For now, return the first few tracks as "recent"
    // In a real app, this would be based on play history
    return availableTracks.take(5).toList();
  }

  // Get recommended tracks based on favorites
  List<AudioTrack> get recommendedTracks {
    if (favoriteTracks.isEmpty) {
      return availableTracks.take(10).toList();
    }

    // Simple recommendation: tracks from same categories as favorites
    final favoriteCategories =
        favoriteTracks.map((track) => track.category).toSet();

    return availableTracks
        .where(
          (track) =>
              favoriteCategories.contains(track.category) &&
              !favoriteTracks.any((fav) => fav.id == track.id),
        )
        .take(10)
        .toList();
  }

  // Shuffle mode display text
  String get shuffleModeText {
    return isShuffleEnabled ? 'Shuffle On' : 'Shuffle Off';
  }

  // Repeat mode display text
  String get repeatModeText {
    switch (repeatMode) {
      case RepeatMode.off:
        return 'Repeat Off';
      case RepeatMode.one:
        return 'Repeat One';
      case RepeatMode.all:
        return 'Repeat All';
    }
  }

  // Volume percentage
  int get volumePercentage => (volume * 100).round();

  // Playback speed text
  String get playbackSpeedText => '${playbackSpeed}x';

  @override
  List<Object?> get props => [
    status,
    availableTracks,
    playlists,
    favoriteTracks,
    currentPlaylist,
    currentTrack,
    currentTrackIndex,
    position,
    duration,
    isPlaying,
    isPlaylistLoaded,
    isShuffleEnabled,
    repeatMode,
    volume,
    playbackSpeed,
    isMiniPlayerVisible,
    errorMessage,
  ];

  @override
  bool get stringify => true;
}
