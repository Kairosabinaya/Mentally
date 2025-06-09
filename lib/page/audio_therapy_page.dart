import 'package:flutter/material.dart';
import 'audio_player_page.dart';

class AudioTherapyPage extends StatelessWidget {
  const AudioTherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: const _AudioTherapyBody(),
      bottomNavigationBar: const _BottomNavigationWidget(),
    );
  }
}

class _AudioTherapyBody extends StatelessWidget {
  const _AudioTherapyBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderSection(),
            SizedBox(height: 20),
            _SearchBar(),
            SizedBox(height: 24),
            _RecentlyPlayedSection(),
            SizedBox(height: 24),
            _PopularSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Audio Therapy',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'search songs',
              style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyPlayedSection extends StatelessWidget {
  const _RecentlyPlayedSection();

  static const List<_AudioItem> _recentlyPlayed = [
    _AudioItem(
      title: 'Moments of Serenity',
      artist: 'Amelia Hart',
      imageUrl:
          'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=400&fit=crop',
      isLarge: true,
    ),
    _AudioItem(
      title: 'Calm Your Thoughts',
      artist: 'Ethan Rivers',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      isLarge: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Played',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLargeAudioCard(_recentlyPlayed[0], context)),
            const SizedBox(width: 12),
            Expanded(child: _buildLargeAudioCard(_recentlyPlayed[1], context)),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeAudioCard(_AudioItem item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => AudioPlayerPage(
                  title: item.title,
                  artist: item.artist,
                  imageUrl: item.imageUrl,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularSection extends StatelessWidget {
  const _PopularSection();

  static const List<_AudioItem> _popularItems = [
    _AudioItem(
      title: 'Reconnect with Yourself',
      artist: 'Sophia Leigh',
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop',
      isFavorited: true,
    ),
    _AudioItem(
      title: 'Healing Through Stillness',
      artist: 'Nathaniel Hayes',
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop',
      isFavorited: false,
    ),
    _AudioItem(
      title: 'The Art of Letting Go',
      artist: 'Evelyn Monroe',
      imageUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&h=400&fit=crop',
      isFavorited: false,
    ),
    _AudioItem(
      title: 'Finding Inner Peace',
      artist: 'Benjamin Clarke',
      imageUrl:
          'https://images.unsplash.com/photo-1444927714506-8492d94b5ba0?w=400&h=400&fit=crop',
      isFavorited: false,
    ),
    _AudioItem(
      title: 'Breathe and Go',
      artist: 'Sarah Mitchell',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      isFavorited: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _popularItems.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAudioListItem(_popularItems[index], context),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioListItem(_AudioItem item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => AudioPlayerPage(
                  title: item.title,
                  artist: item.artist,
                  imageUrl: item.imageUrl,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                item.isFavorited ? Icons.favorite : Icons.favorite_border,
                color:
                    item.isFavorited
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF64748B),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioItem {
  final String title;
  final String artist;
  final String imageUrl;
  final bool isFavorited;
  final bool isLarge;

  const _AudioItem({
    required this.title,
    required this.artist,
    required this.imageUrl,
    this.isFavorited = false,
    this.isLarge = false,
  });
}

class _BottomNavigationWidget extends StatelessWidget {
  const _BottomNavigationWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                Icons.home,
                'Home',
                context,
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.people_outline,
                'Community',
                context,
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                'Profile',
                context,
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    BuildContext context, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
