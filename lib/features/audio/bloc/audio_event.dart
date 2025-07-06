import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../../shared/models/audio_model.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

// Initialize audio system
class AudioInitializeEvent extends AudioEvent {
  const AudioInitializeEvent();
}

// Load playlist
class AudioLoadPlaylistEvent extends AudioEvent {
  final List<AudioTrack> tracks;
  final int? initialIndex;

  const AudioLoadPlaylistEvent(this.tracks, {this.initialIndex});

  @override
  List<Object?> get props => [tracks, initialIndex];
}

// Load playlist by ID
class AudioLoadPlaylistByIdEvent extends AudioEvent {
  final String playlistId;
  final int? initialIndex;

  const AudioLoadPlaylistByIdEvent(this.playlistId, {this.initialIndex});

  @override
  List<Object?> get props => [playlistId, initialIndex];
}

// Playback controls
class AudioPlayEvent extends AudioEvent {
  const AudioPlayEvent();
}

class AudioPauseEvent extends AudioEvent {
  const AudioPauseEvent();
}

class AudioStopEvent extends AudioEvent {
  const AudioStopEvent();
}

class AudioSeekEvent extends AudioEvent {
  final Duration position;

  const AudioSeekEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class AudioNextEvent extends AudioEvent {
  const AudioNextEvent();
}

class AudioPreviousEvent extends AudioEvent {
  const AudioPreviousEvent();
}

// Player modes
class AudioSetShuffleModeEvent extends AudioEvent {
  final bool enabled;

  const AudioSetShuffleModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class AudioSetRepeatModeEvent extends AudioEvent {
  final RepeatMode mode;

  const AudioSetRepeatModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class AudioSetVolumeEvent extends AudioEvent {
  final double volume;

  const AudioSetVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class AudioSetPlaybackSpeedEvent extends AudioEvent {
  final double speed;

  const AudioSetPlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class AudioSetSpeedEvent extends AudioEvent {
  final double speed;

  const AudioSetSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

// Track selection
class AudioSelectTrackEvent extends AudioEvent {
  final int index;

  const AudioSelectTrackEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class AudioTogglePlayPauseEvent extends AudioEvent {
  const AudioTogglePlayPauseEvent();
}

// UI controls
class AudioToggleMiniPlayerEvent extends AudioEvent {
  const AudioToggleMiniPlayerEvent();
}

// State updates from audio player
class AudioUpdatePositionEvent extends AudioEvent {
  final Duration position;

  const AudioUpdatePositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class AudioUpdateDurationEvent extends AudioEvent {
  final Duration duration;

  const AudioUpdateDurationEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class AudioUpdatePlayerStateEvent extends AudioEvent {
  final PlayerState playerState;

  const AudioUpdatePlayerStateEvent(this.playerState);

  @override
  List<Object?> get props => [playerState];
}

// Playlist management
class AudioCreatePlaylistEvent extends AudioEvent {
  final String name;
  final String? description;

  const AudioCreatePlaylistEvent(this.name, {this.description});

  @override
  List<Object?> get props => [name, description];
}

class AudioAddToPlaylistEvent extends AudioEvent {
  final String playlistId;
  final AudioTrack track;

  const AudioAddToPlaylistEvent(this.playlistId, this.track);

  @override
  List<Object?> get props => [playlistId, track];
}

class AudioRemoveFromPlaylistEvent extends AudioEvent {
  final String playlistId;
  final String trackId;

  const AudioRemoveFromPlaylistEvent(this.playlistId, this.trackId);

  @override
  List<Object?> get props => [playlistId, trackId];
}

class AudioDeletePlaylistEvent extends AudioEvent {
  final String playlistId;

  const AudioDeletePlaylistEvent(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

// Favorites
class AudioToggleFavoriteEvent extends AudioEvent {
  final AudioTrack track;

  const AudioToggleFavoriteEvent(this.track);

  @override
  List<Object?> get props => [track];
}

// Error handling
class AudioErrorEvent extends AudioEvent {
  final String message;

  const AudioErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
