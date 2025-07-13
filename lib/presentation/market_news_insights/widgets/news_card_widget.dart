import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class NewsCardWidget extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const NewsCardWidget({
    super.key,
    required this.newsItem,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with source and time
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(newsItem['category'], isLight)
                          .withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      newsItem['category'] ?? 'General',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(newsItem['category'], isLight),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    newsItem['publishedAt'] ?? '2h ago',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image and content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: newsItem['imageUrl'] ??
                          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=200&h=120&fit=crop',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurface.withAlpha(77),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsItem['headline'] ??
                              'Market Update: Key Financial News',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          newsItem['summary'] ??
                              'Important developments in the financial markets today affecting IPO performance and investment strategies.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(179),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer with source, reading time, and actions
              Row(
                children: [
                  Text(
                    newsItem['source'] ?? 'Financial Times',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(102),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    newsItem['readingTime'] ?? '3 min read',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      if (newsItem['engagementCount'] != null) ...[
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${newsItem['engagementCount']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      InkWell(
                        onTap: onBookmark,
                        child: Icon(
                          newsItem['isBookmarked'] == true
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 18,
                          color: newsItem['isBookmarked'] == true
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onShare,
                        child: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category, bool isLight) {
    switch (category?.toLowerCase()) {
      case 'ipo news':
        return AppTheme.getSuccessColor(isLight);
      case 'market analysis':
        return Colors.blue;
      case 'regulatory updates':
        return AppTheme.getWarningColor(isLight);
      case 'expert opinions':
        return Colors.purple;
      default:
        return AppTheme.primaryLight;
    }
  }
}
