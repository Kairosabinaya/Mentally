import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/audio_model.dart';
import '../repository/audio_repository.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _repository;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _session;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateSubscription;

  AudioBloc({required AudioRepository repository})
    : _repository = repository,
      super(const AudioState()) {
    on<AudioInitializeEvent>(_onInitialize);
    on<AudioLoadPlaylistEvent>(_onLoadPlaylist);
    on<AudioLoadPlaylistByIdEvent>(_onLoadPlaylistById);
    on<AudioPlayEvent>(_onPlay);
    on<AudioPauseEvent>(_onPause);
    on<AudioStopEvent>(_onStop);
    on<AudioSeekEvent>(_onSeek);
    on<AudioNextEvent>(_onNext);
    on<AudioPreviousEvent>(_onPrevious);
    on<AudioSetShuffleModeEvent>(_onSetShuffleMode);
    on<AudioSetRepeatModeEvent>(_onSetRepeatMode);
    on<AudioSetVolumeEvent>(_onSetVolume);
    on<AudioSelectTrackEvent>(_onSelectTrack);
    on<AudioTogglePlayPauseEvent>(_onTogglePlayPause);
    on<AudioToggleMiniPlayerEvent>(_onToggleMiniPlayer);
    on<AudioUpdatePositionEvent>(_onUpdatePosition);
    on<AudioUpdateDurationEvent>(_onUpdateDuration);
    on<AudioUpdatePlayerStateEvent>(_onUpdatePlayerState);
    on<AudioCreatePlaylistEvent>(_onCreatePlaylist);
    on<AudioAddToPlaylistEvent>(_onAddToPlaylist);
    on<AudioRemoveFromPlaylistEvent>(_onRemoveFromPlaylist);
    on<AudioDeletePlaylistEvent>(_onDeletePlaylist);
    on<AudioToggleFavoriteEvent>(_onToggleFavorite);
    on<AudioSetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<AudioSetSpeedEvent>(_onSetSpeed);
    on<AudioErrorEvent>(_onError);

    _initializeAudioSession();
  }

  Future<void> _initializeAudioSession() async {
    try {
      _session = await AudioSession.instance;
      await _session!.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      add(
        AudioErrorEvent('Failed to initialize audio session: ${e.toString()}'),
      );
    }
  }

  Future<void> _onInitialize(
    AudioInitializeEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AudioPlayerStatus.loading));

      // Load available tracks and playlists
      final tracks = await _repository.getAvailableTracks();
      final playlists = await _repository.getUserPlaylists();
      final favorites = await _repository.getFavoriteTracks();

      emit(
        state.copyWith(
          status: AudioPlayerStatus.ready,
          availableTracks: tracks,
          playlists: playlists,
          favoriteTracks: favorites,
        ),
      );

      // Set up audio player listeners
      _setupAudioPlayerListeners();
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to initialize audio: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadPlaylist(
    AudioLoadPlaylistEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AudioPlayerStatus.loading));

      // Set up playlist in audio player
      final audioSources =
          event.tracks
              .map((track) => AudioSource.asset(track.audioUrl))
              .toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: event.initialIndex ?? 0,
      );

      emit(
        state.copyWith(
          status: AudioPlayerStatus.ready,
          currentPlaylist: event.tracks,
          currentTrackIndex: event.initialIndex ?? 0,
          currentTrack:
              event.tracks.isNotEmpty
                  ? event.tracks[event.initialIndex ?? 0]
                  : null,
          isPlaylistLoaded: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to load playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadPlaylistById(
    AudioLoadPlaylistByIdEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AudioPlayerStatus.loading));

      // Find the playlist by ID
      final playlist = state.getPlaylistById(event.playlistId);
      if (playlist == null) {
        emit(
          state.copyWith(
            status: AudioPlayerStatus.error,
            errorMessage: 'Playlist not found: ${event.playlistId}',
          ),
        );
        return;
      }

      // Set up playlist in audio player
      final audioSources =
          playlist.tracks
              .map((track) => AudioSource.asset(track.audioUrl))
              .toList();

      final audioPlaylist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(
        audioPlaylist,
        initialIndex: event.initialIndex ?? 0,
      );

      emit(
        state.copyWith(
          status: AudioPlayerStatus.ready,
          currentPlaylist: playlist.tracks,
          currentTrackIndex: event.initialIndex ?? 0,
          currentTrack:
              playlist.tracks.isNotEmpty
                  ? playlist.tracks[event.initialIndex ?? 0]
                  : null,
          isPlaylistLoaded: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to load playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPlay(AudioPlayEvent event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer.play();
      emit(state.copyWith(isPlaying: true, status: AudioPlayerStatus.playing));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to play audio: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPause(AudioPauseEvent event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer.pause();
      emit(state.copyWith(isPlaying: false, status: AudioPlayerStatus.paused));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to pause audio: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStop(AudioStopEvent event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer.stop();
      emit(
        state.copyWith(
          isPlaying: false,
          status: AudioPlayerStatus.stopped,
          position: Duration.zero,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to stop audio: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSeek(AudioSeekEvent event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer.seek(event.position);
      emit(state.copyWith(position: event.position));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to seek: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onNext(AudioNextEvent event, Emitter<AudioState> emit) async {
    try {
      // Seek forward 10 seconds
      final currentPosition = _audioPlayer.position;
      final duration = _audioPlayer.duration ?? Duration.zero;
      final newPosition = currentPosition + const Duration(seconds: 10);

      // Don't seek beyond the end of the track
      final seekPosition = newPosition > duration ? duration : newPosition;

      await _audioPlayer.seek(seekPosition);
      emit(state.copyWith(position: seekPosition));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to seek forward: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPrevious(
    AudioPreviousEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      // Seek backward 10 seconds
      final currentPosition = _audioPlayer.position;
      final newPosition = currentPosition - const Duration(seconds: 10);

      // Don't seek before the beginning of the track
      final seekPosition =
          newPosition < Duration.zero ? Duration.zero : newPosition;

      await _audioPlayer.seek(seekPosition);
      emit(state.copyWith(position: seekPosition));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to seek backward: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetShuffleMode(
    AudioSetShuffleModeEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(event.enabled);
      emit(state.copyWith(isShuffleEnabled: event.enabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to set shuffle mode: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetRepeatMode(
    AudioSetRepeatModeEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      LoopMode loopMode;
      switch (event.mode) {
        case RepeatMode.off:
          loopMode = LoopMode.off;
          break;
        case RepeatMode.one:
          loopMode = LoopMode.one;
          break;
        case RepeatMode.all:
          loopMode = LoopMode.all;
          break;
      }

      await _audioPlayer.setLoopMode(loopMode);
      emit(state.copyWith(repeatMode: event.mode));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to set repeat mode: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetVolume(
    AudioSetVolumeEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _audioPlayer.setVolume(event.volume);
      emit(state.copyWith(volume: event.volume));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to set volume: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSelectTrack(
    AudioSelectTrackEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      if (event.index < state.currentPlaylist.length) {
        await _audioPlayer.seek(Duration.zero, index: event.index);
        emit(
          state.copyWith(
            currentTrackIndex: event.index,
            currentTrack: state.currentPlaylist[event.index],
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to select track: ${e.toString()}',
        ),
      );
    }
  }

  void _onTogglePlayPause(
    AudioTogglePlayPauseEvent event,
    Emitter<AudioState> emit,
  ) {
    if (state.isPlaying) {
      add(const AudioPauseEvent());
    } else {
      add(const AudioPlayEvent());
    }
  }

  void _onToggleMiniPlayer(
    AudioToggleMiniPlayerEvent event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(isMiniPlayerVisible: !state.isMiniPlayerVisible));
  }

  void _onUpdatePosition(
    AudioUpdatePositionEvent event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(
    AudioUpdateDurationEvent event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onUpdatePlayerState(
    AudioUpdatePlayerStateEvent event,
    Emitter<AudioState> emit,
  ) {
    final isPlaying = event.playerState.playing;
    final processingState = event.playerState.processingState;

    AudioPlayerStatus status;
    switch (processingState) {
      case ProcessingState.idle:
        status = AudioPlayerStatus.ready;
        break;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        status = AudioPlayerStatus.loading;
        break;
      case ProcessingState.ready:
        status =
            isPlaying ? AudioPlayerStatus.playing : AudioPlayerStatus.paused;
        break;
      case ProcessingState.completed:
        status = AudioPlayerStatus.stopped;
        break;
    }

    emit(state.copyWith(isPlaying: isPlaying, status: status));
  }

  Future<void> _onCreatePlaylist(
    AudioCreatePlaylistEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      final playlist = await _repository.createNewPlaylist(
        event.name,
        event.description,
      );
      final updatedPlaylists = [...state.playlists, playlist];

      emit(state.copyWith(playlists: updatedPlaylists));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to create playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddToPlaylist(
    AudioAddToPlaylistEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _repository.addTrackToPlaylist(event.playlistId, event.track);
      // Refresh playlists
      final playlists = await _repository.getUserPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to add track to playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRemoveFromPlaylist(
    AudioRemoveFromPlaylistEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _repository.removeTrackFromPlaylist(
        event.playlistId,
        event.trackId,
      );
      // Refresh playlists
      final playlists = await _repository.getUserPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to remove track from playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeletePlaylist(
    AudioDeletePlaylistEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _repository.deletePlaylist(event.playlistId);
      final updatedPlaylists =
          state.playlists.where((p) => p.id != event.playlistId).toList();
      emit(state.copyWith(playlists: updatedPlaylists));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to delete playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onToggleFavorite(
    AudioToggleFavoriteEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      final isFavorite = state.favoriteTracks.any(
        (t) => t.id == event.track.id,
      );

      if (isFavorite) {
        await _repository.removeFromFavorites(event.track.id);
        final updatedFavorites =
            state.favoriteTracks.where((t) => t.id != event.track.id).toList();
        emit(state.copyWith(favoriteTracks: updatedFavorites));
      } else {
        await _repository.addToFavorites(event.track);
        final updatedFavorites = [...state.favoriteTracks, event.track];
        emit(state.copyWith(favoriteTracks: updatedFavorites));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to toggle favorite: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetPlaybackSpeed(
    AudioSetPlaybackSpeedEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _audioPlayer.setSpeed(event.speed);
      emit(state.copyWith(playbackSpeed: event.speed));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to set playback speed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetSpeed(
    AudioSetSpeedEvent event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _audioPlayer.setSpeed(event.speed);
      emit(state.copyWith(playbackSpeed: event.speed));
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Failed to set speed: ${e.toString()}',
        ),
      );
    }
  }

  void _onError(AudioErrorEvent event, Emitter<AudioState> emit) {
    emit(
      state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  void _setupAudioPlayerListeners() {
    // Position updates
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      add(AudioUpdatePositionEvent(position));
    });

    // Duration updates
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        add(AudioUpdateDurationEvent(duration));
      }
    });

    // Player state updates
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      add(AudioUpdatePlayerStateEvent(playerState));
    });

    // Sequence state updates (for track changes)
    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen((
      sequenceState,
    ) {
      if (sequenceState != null) {
        final currentIndex = sequenceState.currentIndex;
        if (currentIndex != null && currentIndex != state.currentTrackIndex) {
          final newTrack =
              state.currentPlaylist.isNotEmpty &&
                      currentIndex < state.currentPlaylist.length
                  ? state.currentPlaylist[currentIndex]
                  : null;

          add(AudioSelectTrackEvent(currentIndex));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}

// Audio metadata class for just_audio
class AudioMetadata {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? artworkUrl;
  final Duration duration;

  const AudioMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artworkUrl,
    required this.duration,
  });
}
