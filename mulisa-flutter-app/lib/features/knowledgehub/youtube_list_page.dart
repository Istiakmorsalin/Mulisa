import 'package:flutter/material.dart';
import 'youtube_watch_page.dart';

class YoutubeListPage extends StatelessWidget {
  const YoutubeListPage({super.key});

  // Demo data (ID + title). Replace with your source later.
  static final List<_VideoItem> _videos = [

    _VideoItem(id: 'G5-Rp-6FMCQ', title: 'How-to: Care Routine'),
    _VideoItem(
      id: '1i9kcBHX2Nw',
      title: 'CDC: Understanding Mental Health Awareness',
    ),
    _VideoItem(
      id: '2GiIbOo2o1A',
      title: 'Harvard Health: The Importance of Sleep',
    ),
    _VideoItem(
      id: 'Jn79IcXuK68',
      title: 'Mayo Clinic: Managing Stress and Anxiety',
    ),
    _VideoItem(
      id: 'owcZmS5KwHw',
      title: 'Cleveland Clinic: Heart Health and Exercise',
    ),
    _VideoItem(
      id: 'owcZmS5KwHw',
      title: 'Johns Hopkins Medicine: Nutrition for Better Living',
    ),
    _VideoItem(
      id: 'owcZmS5KwHw',
      title: 'National Institute on Aging: Staying Active at Any Age',
    ),
    _VideoItem(
      id: 'V2sEay-E-Ro',
      title: 'Stanford Medicine: Mindfulness and Relaxation',
    ),
    _VideoItem(
      id: 'X1T7sYBckbM',
      title: 'Harvard Medical School: Understanding Blood Pressure',
    ),
    _VideoItem(
      id: 'aqz-KE-bpKQ',
      title: 'Emergency Support: When to Seek Help (Creative Commons)',
    ),
    _VideoItem(
      id: 'mJENhCXzL6I',
      title: 'NASA: Earth from Space – Health & Perspective',
    ),
    _VideoItem(
      id: 'mJENhCXzL6I',
      title: 'WHO: How to Wash Hands Properly',
    ),
    _VideoItem(
      id: 'mJENhCXzL6I',
      title: 'TED-Ed: How Does Your Immune System Work?',
    ),
    _VideoItem(
      id: 'mJENhCXzL6I',
      title: 'Johns Hopkins Medicine: Understanding Diabetes Basics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Recommended Videos',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: _videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final v = _videos[i];
              return _VideoCard(item: v, onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => YoutubeWatchPage(videoId: v.id, title: v.title),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _VideoItem item;
  final VoidCallback onTap;
  const _VideoCard({required this.item, required this.onTap});

  String get _thumb => 'https://img.youtube.com/vi/${item.id}/hqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with gradient + floating play btn
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Ink.image(
                    image: NetworkImage(_thumb),
                    fit: BoxFit.cover,
                    child: const SizedBox.expand(),
                  ),
                ),
                // Top/bottom gradient overlays for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.12),
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                // Floating play button
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                // Title over thumbnail
                Positioned(
                  left: 12,
                  right: 70, // leave room for play btn
                  bottom: 12,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
                  ),
                ),
              ],
            ),

            // Meta row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  // Tiny YouTube-like dot/avatar placeholder
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.ondemand_video, size: 18, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'YouTube • Education',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'More',
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {}, // hook to menu if needed
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoItem {
  final String id;
  final String title;
  const _VideoItem({required this.id, required this.title});
}
