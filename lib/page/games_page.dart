import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  // Mental health games data
  final List<Game> _games = [
    Game(
      name: 'CalmMaze',
      description:
          'Meditasi dan relaksasi dengan permainan labirin yang menenangkan',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 4.1,
      downloads: '82k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.calmmaze',
      category: 'Meditation',
    ),
    Game(
      name: 'StressBuster',
      description: 'Mini games untuk mengurangi stress dan kecemasan',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 3.8,
      downloads: '22k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.stressbuster',
      category: 'Stress Relief',
    ),
    Game(
      name: 'Positivity Puzzles',
      description: 'Puzzle games yang meningkatkan mood dan mindset positif',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 4.2,
      downloads: '71k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.positivitypuzzles',
      category: 'Positivity',
    ),
    Game(
      name: 'SleepySheep',
      description: 'Permainan relaksasi untuk membantu tidur lebih nyenyak',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 4.0,
      downloads: '50k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.sleepysheep',
      category: 'Sleep',
    ),
    Game(
      name: 'MindfulBreath',
      description:
          'Latihan pernapasan interaktif dengan visual yang menenangkan',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 4.3,
      downloads: '95k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.mindfulbreath',
      category: 'Breathing',
    ),
    Game(
      name: 'AnxietyAway',
      description: 'Tools dan mini games untuk mengatasi kecemasan',
      iconAsset: 'https://play-lh.googleusercontent.com/placeholder',
      rating: 3.9,
      downloads: '34k',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.anxietyaway',
      category: 'Anxiety',
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Meditation',
    'Stress Relief',
    'Positivity',
    'Sleep',
    'Breathing',
    'Anxiety',
  ];

  List<Game> get _filteredGames {
    if (_selectedCategory == 'All') {
      return _games;
    }
    return _games.where((game) => game.category == _selectedCategory).toList();
  }

  // Enhanced color palette matching home page
  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _lightBackground = Color(0xFFFAFBFF);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightGray = Color(0xFFE2E8F0);
  static const Color _softPink = Color(0xFFFDF2F8);
  static const Color _softBlue = Color(0xFFEFF6FF);
  static const Color _softGreen = Color(0xFFF0FDF4);
  static const Color _accentOrange = Color(0xFFFB923C);
  static const Color _accentGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mental Health Games',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Filter
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? _surfaceWhite : _textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'All';
                          });
                        },
                        backgroundColor: _surfaceWhite,
                        selectedColor: _primaryPurple,
                        side: BorderSide(
                          color: isSelected ? _primaryPurple : _lightGray,
                          width: 1,
                        ),
                        elevation: isSelected ? 2 : 0,
                        shadowColor: _primaryPurple.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(child: _buildGamesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        return _buildGameCard(_filteredGames[index]);
      },
    );
  }

  Widget _buildGameCard(Game game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getCategoryColor(game.category),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getCategoryIcon(game.category),
                color: _getCategoryIconColor(game.category),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textGray,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: _accentOrange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${game.rating}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.download_rounded, color: _textGray, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        game.downloads,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: _textGray),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryPurple, _primaryBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () => _launchPlayStore(game.playStoreUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Play',
                  style: TextStyle(
                    color: _surfaceWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Meditation':
        return _softPink;
      case 'Stress Relief':
        return _softBlue;
      case 'Positivity':
        return _softGreen;
      case 'Sleep':
        return _softPink.withOpacity(0.7);
      case 'Breathing':
        return _softBlue.withOpacity(0.7);
      case 'Anxiety':
        return _softGreen.withOpacity(0.7);
      default:
        return _lightGray;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Meditation':
        return Icons.self_improvement_rounded;
      case 'Stress Relief':
        return Icons.psychology_rounded;
      case 'Positivity':
        return Icons.sentiment_very_satisfied_rounded;
      case 'Sleep':
        return Icons.bedtime_rounded;
      case 'Breathing':
        return Icons.air_rounded;
      case 'Anxiety':
        return Icons.favorite_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category) {
      case 'Meditation':
        return _primaryPurple;
      case 'Stress Relief':
        return _primaryBlue;
      case 'Positivity':
        return _accentGreen;
      case 'Sleep':
        return _primaryPurple;
      case 'Breathing':
        return _primaryBlue;
      case 'Anxiety':
        return _accentGreen;
      default:
        return _primaryPurple;
    }
  }

  Future<void> _launchPlayStore(String url) async {
    try {
      final Uri playStoreUri = Uri.parse(url);
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open Play Store'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening Play Store'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
