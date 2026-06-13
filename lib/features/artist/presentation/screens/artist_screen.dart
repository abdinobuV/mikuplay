import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ArtistScreen extends StatefulWidget {
  final String artistName;
  const ArtistScreen({super.key, required this.artistName});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  // Dummy data based on artist name
  late Map<String, dynamic> artistData;
  late List<Map<String, dynamic>> topHits;

  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  void _loadArtistData() {
    final name = widget.artistName.toLowerCase();
    if (name.contains('miku')) {
      artistData = {
        'name': 'Hatsune Miku',
        'sub': 'Crypton Future Media',
        'listeners': '4.2M',
        'plays': '38M',
        'debut': '2007',
        'color': const Color(0xFF00B4D8),
        'imagePath': 'assets/images/artists/hatsune_miku.png',
      };
      topHits = [
        {'title': 'Melt', 'sub': 'ryo', 'dur': '4:33'},
        {'title': 'World is Mine', 'sub': 'ryo', 'dur': '4:09'},
        {'title': 'Decorator', 'sub': 'livetune', 'dur': '5:02'},
        {'title': 'Tell Your World', 'sub': 'livetune', 'dur': '4:22'},
        {'title': 'Freely Tomorrow', 'sub': 'Mitchie M', 'dur': '4:31'},
      ];
    } else if (name.contains('kaito')) {
      artistData = {
        'name': 'KAITO',
        'sub': 'Crypton Future Media - 2006',
        'listeners': '1.8M',
        'plays': '12M',
        'debut': '2006',
        'color': const Color(0xFF4D80E5),
        'imagePath': 'assets/images/artists/kaito.png',
      };
      topHits = [
        {'title': 'Just Be Friends', 'sub': 'Dixie Flatline', 'dur': '4:48'},
        {'title': 'Cendrillon', 'sub': 'Dixie Flatline', 'dur': '4:21'},
        {'title': 'Hoshizora no Waltz', 'sub': 'Oster Project', 'dur': '3:54'},
        {'title': 'Masa Works', 'sub': 'Masa', 'dur': '5:12'},
        {'title': 'Romeo and Cinderella', 'sub': 'doriko', 'dur': '3:44'},
      ];
    } else if (name.contains('gumi')) {
      artistData = {
        'name': 'GUMI',
        'sub': 'Internet Co. - 2009',
        'listeners': '1.2M',
        'plays': '9.5M',
        'debut': '2009',
        'color': const Color(0xFF4DCC99),
        'imagePath': 'assets/images/artists/gumi.png',
      };
      topHits = [
        {'title': 'Hibikase', 'sub': 'GigaP', 'dur': '3:58'},
        {'title': 'Poker Face', 'sub': 'Nem', 'dur': '4:02'},
        {'title': 'Mozaik Role', 'sub': 'Deco*27', 'dur': '4:15'},
        {'title': 'Melt', 'sub': 'YM', 'dur': '3:44'},
        {'title': 'ECHO', 'sub': 'Crusher-P', 'dur': '3:30'},
      ];
    } else if (name.contains('luka')) {
      artistData = {
        'name': 'LUKA',
        'sub': 'Crypton Future Media - 2009',
        'listeners': '2.1M',
        'plays': '14M',
        'debut': '2009',
        'color': const Color(0xFFBC0D87),
        'imagePath': 'assets/images/artists/luka.png',
      };
      topHits = [
        {'title': 'Hibikase', 'sub': 'GigaP', 'dur': '3:58'},
        {'title': 'Poker Face', 'sub': 'Nem', 'dur': '4:02'},
        {'title': 'Mozaik Role', 'sub': 'GigaP', 'dur': '4:15'},
        {'title': 'Melt', 'sub': 'YM', 'dur': '3:44'},
        {'title': 'ECHO', 'sub': 'Crusher-P', 'dur': '3:32'},
      ];
    } else {
      artistData = {
        'name': widget.artistName,
        'sub': 'Artist · Unknown',
        'listeners': '0',
        'plays': '0',
        'debut': '-',
        'color': AppColors.teal,
        'imagePath': 'assets/images/artists/placeholder_artist.png',
      };
      topHits = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background Decoration Circle
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 150,
            top: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: artistData['color'].withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.white),
                        onPressed: () => context.pop(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz,
                            color: AppColors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 10),

                      // Avatar
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: artistData['color'], width: 2),
                          ),
                          child: ClipOval(
                            // Placeholder image, ganti path dengan file asset lokal nanti
                            child: Image.asset(
                              artistData['imagePath'] ?? 'assets/images/placeholder_artist.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    alignment: Alignment.center,
                                    color: AppColors.card,
                                    child: Icon(Icons.person,
                                        size: 50, color: artistData['color']),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name & Subtitle
                      Center(
                        child: Text(
                          artistData['name'],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          artistData['sub'],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.skyOp(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                              value: artistData['listeners'],
                              label: 'Listeners'),
                          _StatItem(value: artistData['plays'], label: 'Plays'),
                          _StatItem(value: artistData['debut'], label: 'Debut'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Follow Button
                      Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 10),
                            decoration: BoxDecoration(
                              color: artistData['color'],
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '+ Follow',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Top Hits Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top Hits',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'See all \u2192',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: artistData['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Songs List
                      ...List.generate(topHits.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SongRow(
                            index: i + 1,
                            title: topHits[i]['title'],
                            subtitle: topHits[i]['sub'],
                            duration: topHits[i]['dur'],
                            color: artistData['color'],
                          ),
                        );
                      }),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.skyOp(0.6),
          ),
        ),
      ],
    );
  }
}

class _SongRow extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String duration;
  final Color color;

  const _SongRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deepCyanOp(0.15)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 24,
            child: Text(
              index.toString(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: index == 1 ? color : color.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Placeholder for song cover (Circle)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.skyOp(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.favorite_border, color: AppColors.skyOp(0.6), size: 16),
          const SizedBox(width: 8),
          Text(
            duration,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.skyOp(0.6),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
