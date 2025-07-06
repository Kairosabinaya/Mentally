class AppConstants {
  // App Information
  static const String appName = 'Mentally';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String moodsCollection = 'moods';
  static const String journalsCollection = 'journals';
  static const String communityPostsCollection = 'community_posts';
  static const String commentsCollection = 'comments';
  static const String activitiesCollection = 'activities';
  static const String playlistsCollection = 'playlists';
  static const String audioTracksCollection = 'audio_tracks';
  static const String journalEntriesCollection = 'journal_entries';
  static const String journalPromptsCollection = 'journal_prompts';
  static const String journalTemplatesCollection = 'journal_templates';
  static const String journalDraftsCollection = 'journal_drafts';

  // API Keys
  static const String geminiApiKey = 'AIzaSyCq7IWRsikIpJPL6FzGmjW0_1t0tcm1hHM';

  // Asset Paths
  static const String audioPath = 'assets/audio/';
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';

  // Audio Files
  static const List<String> audioFiles = [
    'Audio1.mp3',
    'Audio2.mp3',
    'Audio3.mp3',
    'Audio4.mp3',
    'Audio5.mp3',
    'Audio6.mp3',
    'Audio7.mp3',
    'Audio8.mp3',
    'Audio9.mp3',
    'Audio10.mp3',
  ];

  // Mood Types (ordered for UI display: Score 1 (left) to Score 5 (right))
  static const List<String> moodTypes = [
    'very_sad', // Score 1 (leftmost)
    'sad', // Score 2
    'neutral', // Score 3
    'happy', // Score 4
    'very_happy', // Score 5 (rightmost)
  ];

  // Mood Images (ordered to match UI display: Score 1 to Score 5)
  static const List<String> moodImages = [
    'assets/images/Mood1.png', // very_sad (Score 1)
    'assets/images/Mood2.png', // sad (Score 2)
    'assets/images/Mood3.png', // neutral (Score 3)
    'assets/images/Mood4.png', // happy (Score 4)
    'assets/images/Mood5.png', // very_happy (Score 5)
  ];

  // Mood Emojis (ordered to match UI display: Score 1 to Score 5)
  static const List<String> moodEmojis = [
    '😰', // very_sad -> Poor (Score 1)
    '😔', // sad -> Low (Score 2)
    '😐', // neutral -> Okay (Score 3)
    '😊', // happy -> Good (Score 4)
    '😄', // very_happy -> Great (Score 5)
  ];

  // Point System
  static const int moodEntryPoints = 10;
  static const int journalEntryPoints = 15;
  static const int audioCompletionPoints = 5;
  static const int communityPostPoints = 20;
  static const int communityCommentPoints = 5;
  static const int pointsForPost = 20;
  static const int pointsForComment = 5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache Durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;
}
