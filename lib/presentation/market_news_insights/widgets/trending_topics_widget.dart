import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class TrendingTopicsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trendingTopics;

  const TrendingTopicsWidget({
    super.key,
    required this.trendingTopics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending Topics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Market Sentiment',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...trendingTopics.asMap().entries.map((entry) {
              final index = entry.key;
              final topic = entry.value;
              return _buildTrendingItem(context, index + 1, topic);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(
      BuildContext context, int rank, Map<String, dynamic> topic) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sentiment = topic['sentiment'] ?? 'neutral';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Rank
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(rank, isLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Topic content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic['title'] ?? 'Market Topic',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(sentiment, isLight)
                            .withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sentiment.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getSentimentColor(sentiment, isLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${topic['mentions'] ?? 0} mentions',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trend indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTrendColor(topic['trend'], isLight).withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTrendIcon(topic['trend']),
                  size: 12,
                  color: _getTrendColor(topic['trend'], isLight),
                ),
                const SizedBox(width: 4),
                Text(
                  '${topic['change'] ?? 0}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getTrendColor(topic['trend'], isLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank, bool isLight) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return AppTheme.primaryLight;
    }
  }

  Color _getSentimentColor(String sentiment, bool isLight) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return AppTheme.getSuccessColor(isLight);
      case 'negative':
        return AppTheme.getErrorColor(isLight);
      case 'neutral':
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getTrendColor(String? trend, bool isLight) {
    switch (trend?.toLowerCase()) {
      case 'up':
        return AppTheme.getSuccessColor(isLight);
      case 'down':
        return AppTheme.getErrorColor(isLight);
      case 'stable':
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getTrendIcon(String? trend) {
    switch (trend?.toLowerCase()) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }
}