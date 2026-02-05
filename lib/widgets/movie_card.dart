import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loading.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool showNewBadge;
  final VoidCallback? onTap;
  final bool removeMargin; // For grid layout without spacing

  const MovieCard({
    super.key,
    required this.movie,
    this.showNewBadge = false,
    this.onTap,
    this.removeMargin = false,
  });

  String _buildAccessibilityLabel() {
    final List<String> labels = [movie.title];

    if (movie.year > 0) {
      labels.add('${movie.year}년');
    }
    if (movie.duration > 0) {
      labels.add('${movie.duration}분');
    }
    if (movie.hasAD) {
      labels.add('화면해설 지원');
    }
    if (movie.hasCC) {
      labels.add('자막 지원');
    }
    if (showNewBadge) {
      labels.add('신작');
    }

    return labels.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _buildAccessibilityLabel(),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          margin:
              removeMargin ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster with badges
              Stack(
                children: [
                  // Poster image
                  Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[900], // Fallback background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie.posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 200, // Optimize memory for lists
                              placeholder: (context, url) => const ShimmerWidget(
                                width: 120,
                                height: 180,
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white24),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.movie_creation,
                                  color: Colors.white24),
                            ),
                    ),
                  ),

                  // NEW badge
                  if (showNewBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // AD and CC badges at bottom
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (movie.hasAD)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (movie.hasCC)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'CC',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Movie title
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
