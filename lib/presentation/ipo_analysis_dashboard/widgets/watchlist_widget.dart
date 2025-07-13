import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class WatchlistWidget extends StatelessWidget {
  final List<Map<String, dynamic>> watchlistItems;

  const WatchlistWidget({
    super.key,
    required this.watchlistItems,
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
                  Icons.visibility,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Watchlist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...watchlistItems.map((item) => _buildWatchlistItem(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isPositive = item['change'] >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.getSuccessColor(isLight)
                  : AppTheme.getErrorColor(isLight),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item['sector'] ?? 'Technology',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item['price']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${item['change'].toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPositive
                      ? AppTheme.getSuccessColor(isLight)
                      : AppTheme.getErrorColor(isLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
