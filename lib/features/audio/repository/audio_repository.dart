import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/audio_model.dart';

class AudioRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AudioRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Get all playlists for the user
  Future<List<AudioPlaylist>> getPlaylists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return await _getDefaultPlaylists();
      }

      final snapshot =
          await _firestore
              .collection(AppConstants.playlistsCollection)
              .where('userId', isEqualTo: user.uid)
              .get();

      final playlists =
          snapshot.docs
              .map(
                (doc) => AudioPlaylist.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();

      if (playlists.isEmpty) {
        return await _getDefaultPlaylists();
      }

      return playlists;
    } catch (e) {
      // Return default playlists on error
      return await _getDefaultPlaylists();
    }
  }

  // Get a specific playlist by ID
  Future<AudioPlaylist?> getPlaylist(String playlistId) async {
    try {
      final doc =
          await _firestore
              .collection(AppConstants.playlistsCollection)
              .doc(playlistId)
              .get();

      if (!doc.exists) return null;

      return AudioPlaylist.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      return null;
    }
  }

  // Create a new playlist
  Future<String?> createPlaylist(AudioPlaylist playlist) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = await _firestore
          .collection(AppConstants.playlistsCollection)
          .add({
            ...playlist.toJson(),
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Update a playlist
  Future<bool> updatePlaylist(String playlistId, AudioPlaylist playlist) async {
    try {
      await _firestore
          .collection(AppConstants.playlistsCollection)
          .doc(playlistId)
          .update({
            ...playlist.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await _firestore
          .collection(AppConstants.playlistsCollection)
          .doc(playlistId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite track
  Future<bool> toggleFavorite(String trackId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) return false;

      final userData = snapshot.data()!;
      final favorites = List<String>.from(userData['favoriteTrackIds'] ?? []);

      if (favorites.contains(trackId)) {
        favorites.remove(trackId);
      } else {
        favorites.add(trackId);
      }

      await userDoc.update({'favoriteTrackIds': favorites});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user's favorite tracks
  Future<List<String>> getFavoriteTrackIds() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

      if (!snapshot.exists) return [];

      final userData = snapshot.data()!;
      return List<String>.from(userData['favoriteTrackIds'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // Get default playlists with local audio files
  Future<List<AudioPlaylist>> _getDefaultPlaylists() async {
    try {
      // Create default playlists with local audio files
      final now = DateTime.now();
      final relaxationTracks = [
        AudioTrack(
          id: 'audio1',
          title: 'Peaceful Meditation',
          artist: 'Mentally Audio',
          album: 'Relaxation Collection',
          audioUrl: 'assets/audio/Audio1.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 10),
          category: AudioCategory.meditation,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio2',
          title: 'Nature Sounds',
          artist: 'Mentally Audio',
          album: 'Relaxation Collection',
          audioUrl: 'assets/audio/Audio2.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 15),
          category: AudioCategory.nature,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio3',
          title: 'Deep Breathing',
          artist: 'Mentally Audio',
          album: 'Relaxation Collection',
          audioUrl: 'assets/audio/Audio3.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 8),
          category: AudioCategory.breathing,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final sleepTracks = [
        AudioTrack(
          id: 'audio4',
          title: 'Rain Sounds',
          artist: 'Mentally Audio',
          album: 'Sleep Collection',
          audioUrl: 'assets/audio/Audio4.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1519452575417-564c1401ecc0?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 30),
          category: AudioCategory.sleep,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio5',
          title: 'Ocean Waves',
          artist: 'Mentally Audio',
          album: 'Sleep Collection',
          audioUrl: 'assets/audio/Audio5.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 45),
          category: AudioCategory.sleep,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final focusTracks = [
        AudioTrack(
          id: 'audio6',
          title: 'Focus Flow',
          artist: 'Mentally Audio',
          album: 'Focus Collection',
          audioUrl: 'assets/audio/Audio6.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 25),
          category: AudioCategory.focus,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio7',
          title: 'Concentration',
          artist: 'Mentally Audio',
          album: 'Focus Collection',
          audioUrl: 'assets/audio/Audio7.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 20),
          category: AudioCategory.focus,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final anxietyTracks = [
        AudioTrack(
          id: 'audio8',
          title: 'Calm Mind',
          artist: 'Mentally Audio',
          album: 'Anxiety Relief',
          audioUrl: 'assets/audio/Audio8.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 12),
          category: AudioCategory.anxiety,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio9',
          title: 'Stress Relief',
          artist: 'Mentally Audio',
          album: 'Anxiety Relief',
          audioUrl: 'assets/audio/Audio9.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1467810563316-b5476525c0f9?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 18),
          category: AudioCategory.anxiety,
          createdAt: now,
          updatedAt: now,
        ),
        AudioTrack(
          id: 'audio10',
          title: 'Inner Peace',
          artist: 'Mentally Audio',
          album: 'Anxiety Relief',
          audioUrl: 'assets/audio/Audio10.mp3',
          artworkUrl:
              'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?w=400&h=400&fit=crop',
          duration: const Duration(minutes: 22),
          category: AudioCategory.anxiety,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      return [
        AudioPlaylist(
          id: 'relaxation',
          name: 'Relaxation & Meditation',
          description: 'Peaceful tracks for relaxation and meditation',
          tracks: relaxationTracks,
          artworkUrl:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
          category: AudioCategory.meditation,
          createdAt: now,
          updatedAt: now,
          isDefault: true,
        ),
        AudioPlaylist(
          id: 'sleep',
          name: 'Sleep & Rest',
          description: 'Soothing sounds for better sleep',
          tracks: sleepTracks,
          artworkUrl: 'https://images.unsplash.com/photo-1519452575417-564c1401ecc0?w=400&h=400&fit=crop',
          category: AudioCategory.sleep,
          createdAt: now,
          updatedAt: now,
          isDefault: true,
        ),
        AudioPlaylist(
          id: 'focus',
          name: 'Focus & Concentration',
          description: 'Enhance your focus and productivity',
          tracks: focusTracks,
          artworkUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
          category: AudioCategory.focus,
          createdAt: now,
          updatedAt: now,
          isDefault: true,
        ),
        AudioPlaylist(
          id: 'anxiety',
          name: 'Anxiety Relief',
          description: 'Calming tracks for anxiety and stress relief',
          tracks: anxietyTracks,
          artworkUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
          category: AudioCategory.anxiety,
          createdAt: now,
          updatedAt: now,
          isDefault: true,
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  // Save listening history
  Future<void> saveListeningHistory(
    String trackId,
    Duration listenedDuration,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('listeningHistory')
          .add({
            'trackId': trackId,
            'listenedDuration': listenedDuration.inSeconds,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Ignore errors in analytics
    }
  }

  // Get listening statistics
  Future<Map<String, dynamic>> getListeningStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final snapshot =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .collection('listeningHistory')
              .where(
                'timestamp',
                isGreaterThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 30)),
                ),
              )
              .get();

      int totalSessions = snapshot.docs.length;
      int totalMinutes = 0;
      Map<String, int> categoryStats = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalMinutes += (data['listenedDuration'] as int) ~/ 60;

        // This would need track category lookup
        // For now, we'll use a simple approach
      }

      return {
        'totalSessions': totalSessions,
        'totalMinutes': totalMinutes,
        'categoryStats': categoryStats,
      };
    } catch (e) {
      return {};
    }
  }

  // Additional methods needed by AudioBloc
  Future<List<AudioTrack>> getAvailableTracks() async {
    try {
      final playlists = await _getDefaultPlaylists();
      final allTracks = <AudioTrack>[];

      for (final playlist in playlists) {
        allTracks.addAll(playlist.tracks);
      }

      return allTracks;
    } catch (e) {
      return [];
    }
  }

  Future<List<AudioPlaylist>> getUserPlaylists() async {
    return await getPlaylists();
  }

  Future<List<AudioTrack>> getFavoriteTracks() async {
    try {
      final favoriteIds = await getFavoriteTrackIds();
      if (favoriteIds.isEmpty) return [];

      final allTracks = await getAvailableTracks();
      return allTracks
          .where((track) => favoriteIds.contains(track.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<AudioPlaylist> createNewPlaylist(
    String name,
    String? description,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final playlist = AudioPlaylist(
        id: '', // Will be set by Firestore
        name: name,
        description: description ?? '',
        tracks: [],
        category: AudioCategory.meditation,
        createdAt: now,
        updatedAt: now,
        userId: user.uid,
      );

      final docRef = await _firestore
          .collection(AppConstants.playlistsCollection)
          .add({
            ...playlist.toJson(),
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return playlist.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create playlist: ${e.toString()}');
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, AudioTrack track) async {
    try {
      final playlistDoc =
          await _firestore
              .collection(AppConstants.playlistsCollection)
              .doc(playlistId)
              .get();

      if (!playlistDoc.exists) {
        throw Exception('Playlist not found');
      }

      final playlist = AudioPlaylist.fromJson({
        'id': playlistDoc.id,
        ...playlistDoc.data()!,
      });

      final updatedTracks = [...playlist.tracks, track];
      final updatedPlaylist = playlist.copyWith(tracks: updatedTracks);

      await _firestore
          .collection(AppConstants.playlistsCollection)
          .doc(playlistId)
          .update({
            ...updatedPlaylist.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to add track to playlist: ${e.toString()}');
    }
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    try {
      final playlistDoc =
          await _firestore
              .collection(AppConstants.playlistsCollection)
              .doc(playlistId)
              .get();

      if (!playlistDoc.exists) {
        throw Exception('Playlist not found');
      }

      final playlist = AudioPlaylist.fromJson({
        'id': playlistDoc.id,
        ...playlistDoc.data()!,
      });

      final updatedTracks =
          playlist.tracks.where((track) => track.id != trackId).toList();
      final updatedPlaylist = playlist.copyWith(tracks: updatedTracks);

      await _firestore
          .collection(AppConstants.playlistsCollection)
          .doc(playlistId)
          .update({
            ...updatedPlaylist.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to remove track from playlist: ${e.toString()}');
    }
  }

  Future<void> addToFavorites(AudioTrack track) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);

      final snapshot = await userDoc.get();
      final userData = snapshot.exists ? snapshot.data()! : <String, dynamic>{};
      final favorites = List<String>.from(userData['favoriteTrackIds'] ?? []);

      if (!favorites.contains(track.id)) {
        favorites.add(track.id);
        await userDoc.set({
          ...userData,
          'favoriteTrackIds': favorites,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to add to favorites: ${e.toString()}');
    }
  }

  Future<void> removeFromFavorites(String trackId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);

      final snapshot = await userDoc.get();
      if (!snapshot.exists) return;

      final userData = snapshot.data()!;
      final favorites = List<String>.from(userData['favoriteTrackIds'] ?? []);

      if (favorites.contains(trackId)) {
        favorites.remove(trackId);
        await userDoc.update({'favoriteTrackIds': favorites});
      }
    } catch (e) {
      throw Exception('Failed to remove from favorites: ${e.toString()}');
    }
  }
}
