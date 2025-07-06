import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Audio Categories
enum AudioCategory {
  meditation,
  therapy,
  sleep,
  nature,
  breathing,
  focus,
  anxiety,
  depression,
  stress,
  relaxation,
}

// Repeat Modes
enum RepeatMode { off, one, all }

// Audio Status
enum AudioStatus { loading, ready, playing, paused, stopped, error }

// Audio Track Model
class AudioTrack extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final String? artworkUrl;
  final Duration duration;
  final AudioCategory category;
  final List<String> tags;
  final double rating;
  final int listens;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int pointsReward;
  final Map<String, dynamic> metadata;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioUrl,
    this.artworkUrl,
    required this.duration,
    required this.category,
    this.tags = const [],
    this.rating = 0.0,
    this.listens = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.pointsReward = 0,
    this.metadata = const {},
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      artworkUrl: json['artworkUrl'],
      duration: Duration(milliseconds: json['duration'] ?? 0),
      category: AudioCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AudioCategory.meditation,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      listens: json['listens'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      isActive: json['isActive'] ?? true,
      pointsReward: json['pointsReward'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'audioUrl': audioUrl,
      'artworkUrl': artworkUrl,
      'duration': duration.inMilliseconds,
      'category': category.name,
      'tags': tags,
      'rating': rating,
      'listens': listens,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'pointsReward': pointsReward,
      'metadata': metadata,
    };
  }

  AudioTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? audioUrl,
    String? artworkUrl,
    Duration? duration,
    AudioCategory? category,
    List<String>? tags,
    double? rating,
    int? listens,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? pointsReward,
    Map<String, dynamic>? metadata,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      listens: listens ?? this.listens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      pointsReward: pointsReward ?? this.pointsReward,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    album,
    audioUrl,
    artworkUrl,
    duration,
    category,
    tags,
    rating,
    listens,
    createdAt,
    updatedAt,
    isActive,
    pointsReward,
    metadata,
  ];
}

// Audio Playlist Model
class AudioPlaylist extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AudioTrack> tracks;
  final String? artworkUrl;
  final AudioCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final String? userId;

  const AudioPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.tracks,
    this.artworkUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.userId,
  });

  factory AudioPlaylist.fromJson(Map<String, dynamic> json) {
    return AudioPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((track) => AudioTrack.fromJson(track))
              .toList() ??
          [],
      artworkUrl: json['artworkUrl'],
      category: AudioCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AudioCategory.meditation,
      ),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      isDefault: json['isDefault'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'artworkUrl': artworkUrl,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'userId': userId,
    };
  }

  AudioPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    List<AudioTrack>? tracks,
    String? artworkUrl,
    AudioCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    String? userId,
  }) {
    return AudioPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      userId: userId ?? this.userId,
    );
  }

  Duration get totalDuration {
    return tracks.fold(Duration.zero, (sum, track) => sum + track.duration);
  }

  String get formattedTotalDuration {
    final minutes = totalDuration.inMinutes;
    final seconds = totalDuration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    tracks,
    artworkUrl,
    category,
    createdAt,
    updatedAt,
    isDefault,
    userId,
  ];
}

class AudioModel extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String description;
  final String url;
  final String? thumbnailUrl;
  final Duration duration;
  final String category; // meditation, therapy, sleep, etc.
  final List<String> tags;
  final double rating;
  final int listens;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int pointsReward;
  final Map<String, dynamic> metadata;

  const AudioModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.url,
    this.thumbnailUrl,
    required this.duration,
    required this.category,
    required this.tags,
    required this.rating,
    required this.listens,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.pointsReward,
    required this.metadata,
  });

  // Empty constructor for initial state
  AudioModel.empty()
    : id = '',
      title = '',
      artist = '',
      description = '',
      url = '',
      thumbnailUrl = null,
      duration = Duration.zero,
      category = '',
      tags = const [],
      rating = 0.0,
      listens = 0,
      createdAt = DateTime.now(),
      updatedAt = DateTime.now(),
      isActive = true,
      pointsReward = 0,
      metadata = const {};

  // Create from Firebase document
  factory AudioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AudioModel(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      duration: Duration(milliseconds: data['duration'] ?? 0),
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      listens: data['listens'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      pointsReward: data['pointsReward'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.inMilliseconds,
      'category': category,
      'tags': tags,
      'rating': rating,
      'listens': listens,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'pointsReward': pointsReward,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      duration: Duration(milliseconds: json['duration'] ?? 0),
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      listens: json['listens'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      pointsReward: json['pointsReward'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.inMilliseconds,
      'category': category,
      'tags': tags,
      'rating': rating,
      'listens': listens,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'pointsReward': pointsReward,
      'metadata': metadata,
    };
  }

  // Copy with method for immutability
  AudioModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? description,
    String? url,
    String? thumbnailUrl,
    Duration? duration,
    String? category,
    List<String>? tags,
    double? rating,
    int? listens,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? pointsReward,
    Map<String, dynamic>? metadata,
  }) {
    return AudioModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      listens: listens ?? this.listens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      pointsReward: pointsReward ?? this.pointsReward,
      metadata: metadata ?? this.metadata,
    );
  }

  // Formatted duration for display
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    description,
    url,
    thumbnailUrl,
    duration,
    category,
    tags,
    rating,
    listens,
    createdAt,
    updatedAt,
    isActive,
    pointsReward,
    metadata,
  ];

  @override
  bool get stringify => true;
}
