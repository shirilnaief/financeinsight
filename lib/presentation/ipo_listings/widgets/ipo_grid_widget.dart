import 'package:flutter/material.dart';

import '../../../models/ipo_model.dart';
import './ipo_card_widget.dart';
import './ipo_empty_state_widget.dart';

class IPOGridWidget extends StatelessWidget {
  final List<IPOModel> ipos;
  final Function(IPOModel) onIPOTap;
  final Function(IPOModel) onBookmarkTap;
  final bool isLoading;
  final String searchQuery;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  const IPOGridWidget({
    super.key,
    required this.ipos,
    required this.onIPOTap,
    required this.onBookmarkTap,
    this.isLoading = false,
    this.searchQuery = '',
    this.hasActiveFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (ipos.isEmpty) {
      return _buildEmptyState();
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final crossAxisCount = orientation == Orientation.portrait ? 2 : 3;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: ipos.length,
          itemBuilder: (context, index) {
            final ipo = ipos[index];
            return IPOCardWidget(
              ipo: ipo,
              onTap: () => onIPOTap(ipo),
              onBookmarkTap: () => onBookmarkTap(ipo),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content skeleton
            ...List.generate(
                4,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )),

            const Spacer(),

            // Buttons skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (searchQuery.isNotEmpty || hasActiveFilters) {
      return IPOEmptyStateWidget(
        title: 'No Results Found',
        subtitle: searchQuery.isNotEmpty
            ? 'No IPOs found for "$searchQuery"'
            : 'No IPOs match your current filters',
        icon: Icons.search_off,
        onRetry: onClearFilters,
        retryButtonText:
            searchQuery.isNotEmpty ? 'Clear Search' : 'Clear Filters',
      );
    }

    return const IPOEmptyStateWidget(
      title: 'No IPOs Available',
      subtitle:
          'There are currently no IPOs to display. Check back later for new offerings.',
      icon: Icons.business_center,
    );
  }
}
