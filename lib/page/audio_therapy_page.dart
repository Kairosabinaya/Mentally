import 'package:flutter/material.dart';
import 'audio_player_page.dart';

class AudioTherapyPage extends StatelessWidget {
  const AudioTherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          'Audio Therapy',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
      ),
      body: const _AudioTherapyBody(),
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
            SizedBox(height: 24),
            _SearchBar(),
            SizedBox(height: 32),
            _RecentlyPlayedSection(),
            SizedBox(height: 32),
            _PopularSection(),
            SizedBox(height: 24),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.headphones_rounded,
              size: 48,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Audio Therapy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Relax and heal your mind with guided meditation, calming sounds, and therapeutic sessions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search for audio sessions...',
      leading: const Icon(Icons.search_rounded),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevation: MaterialStateProperty.all(0),
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.surfaceVariant,
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
      duration: '12 min',
      category: 'Meditation',
    ),
    _AudioItem(
      title: 'Calm Your Thoughts',
      artist: 'Ethan Rivers',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      duration: '15 min',
      category: 'Relaxation',
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
            Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyPlayed.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _recentlyPlayed.length - 1 ? 16 : 0,
                ),
                child: _buildLargeAudioCard(_recentlyPlayed[index], context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLargeAudioCard(_AudioItem item, BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.artist,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            item.category,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularSection extends StatelessWidget {
  const _PopularSection();

  static const List<_AudioItem> _popularAudio = [
    _AudioItem(
      title: 'Deep Sleep Meditation',
      artist: 'Sarah Johnson',
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop',
      duration: '20 min',
      category: 'Sleep',
    ),
    _AudioItem(
      title: 'Stress Relief Breathing',
      artist: 'Michael Chen',
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop',
      duration: '10 min',
      category: 'Breathing',
    ),
    _AudioItem(
      title: 'Morning Mindfulness',
      artist: 'Lisa Wang',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      duration: '8 min',
      category: 'Meditation',
    ),
    _AudioItem(
      title: 'Anxiety Relief Session',
      artist: 'David Miller',
      imageUrl:
          'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=400&fit=crop',
      duration: '18 min',
      category: 'Therapy',
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
            Text(
              'Popular This Week',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularAudio.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAudioListTile(_popularAudio[index], context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAudioListTile(_AudioItem item, BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.music_note_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.artist),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    item.category,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Text(
                  item.duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
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
          icon: Icon(
            Icons.play_circle_filled_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
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
      ),
    );
  }
}

class _AudioItem {
  final String title;
  final String artist;
  final String imageUrl;
  final String duration;
  final String category;

  const _AudioItem({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.duration,
    required this.category,
  });
}
