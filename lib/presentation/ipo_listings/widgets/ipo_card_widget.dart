import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/ipo_model.dart';
import './ipo_status_tag_widget.dart';

class IPOCardWidget extends StatelessWidget {
  final IPOModel ipo;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const IPOCardWidget({
    super.key,
    required this.ipo,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd MMM yy');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo, name and bookmark
              Row(
                children: [
                  // Company logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ipo.companyLogo,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Company name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ipo.companyName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        IPOStatusTagWidget(
                          status: ipo.status,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  // Bookmark button
                  IconButton(
                    onPressed: onBookmarkTap,
                    icon: Icon(
                      ipo.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: ipo.isBookmarked
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price range and lot size
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Price Range',
                      ipo.priceRange,
                      isDarkMode,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Lot Size',
                      '${ipo.lotSize} shares',
                      isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Issue size and dates
              _buildInfoItem(
                context,
                'Issue Size',
                ipo.issueSize,
                isDarkMode,
              ),
              const SizedBox(height: 12),

              // Date information based on status
              _buildDateInfo(context, dateFormatter, isDarkMode),

              const SizedBox(height: 12),

              // Description
              Text(
                ipo.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canApply() ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        _getActionButtonText(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    DateFormat dateFormatter,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);

    switch (ipo.status) {
      case IPOStatus.upcoming:
        return _buildInfoItem(
          context,
          'Opening Date',
          dateFormatter.format(ipo.openDate),
          isDarkMode,
        );
      case IPOStatus.ongoing:
        return _buildInfoItem(
          context,
          'Closes On',
          dateFormatter.format(ipo.closeDate),
          isDarkMode,
        );
      case IPOStatus.closed:
        return _buildInfoItem(
          context,
          'Closed On',
          dateFormatter.format(ipo.closeDate),
          isDarkMode,
        );
      case IPOStatus.listed:
        return ipo.listingDate != null
            ? _buildInfoItem(
                context,
                'Listed On',
                dateFormatter.format(ipo.listingDate!),
                isDarkMode,
              )
            : _buildInfoItem(
                context,
                'Closed On',
                dateFormatter.format(ipo.closeDate),
                isDarkMode,
              );
    }
  }

  bool _canApply() {
    return ipo.status == IPOStatus.upcoming || ipo.status == IPOStatus.ongoing;
  }

  String _getActionButtonText() {
    switch (ipo.status) {
      case IPOStatus.upcoming:
        return 'Set Reminder';
      case IPOStatus.ongoing:
        return 'Apply Now';
      case IPOStatus.closed:
        return 'View Result';
      case IPOStatus.listed:
        return 'View on BSE';
    }
  }
}
