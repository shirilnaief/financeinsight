import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ipo_model.dart';

class IPOFilterPanelWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback onClose;

  const IPOFilterPanelWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
    required this.onClose,
  });

  @override
  State<IPOFilterPanelWidget> createState() => _IPOFilterPanelWidgetState();
}

class _IPOFilterPanelWidgetState extends State<IPOFilterPanelWidget> {
  late Map<String, dynamic> filters;
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
    dateRange = filters['dateRange'] as DateTimeRange?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filter IPOs',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter
                  _buildFilterSection(
                    context,
                    'IPO Status',
                    _buildStatusFilter(context),
                  ),

                  const SizedBox(height: 24),

                  // Category filter
                  _buildFilterSection(
                    context,
                    'Company Category',
                    _buildCategoryFilter(context),
                  ),

                  const SizedBox(height: 24),

                  // Date range filter
                  _buildFilterSection(
                    context,
                    'Date Range',
                    _buildDateRangeFilter(context),
                  ),

                  const SizedBox(height: 24),

                  // Issue size filter
                  _buildFilterSection(
                    context,
                    'Issue Size Range',
                    _buildIssueSizeFilter(context),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    Widget content,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    final statuses = IPOStatus.values;
    final selectedStatuses = List<IPOStatus>.from(filters['statuses'] ?? []);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = selectedStatuses.contains(status);
        return FilterChip(
          label: Text(status.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedStatuses.add(status);
              } else {
                selectedStatuses.remove(status);
              }
              filters['statuses'] = selectedStatuses;
            });
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = [
      'Technology',
      'Finance',
      'Healthcare',
      'Energy',
      'Retail',
      'Automotive',
      'Manufacturing',
      'Real Estate',
    ];
    final selectedCategories = List<String>.from(filters['categories'] ?? []);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
              filters['categories'] = selectedCategories;
            });
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateRange != null
                    ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}'
                    : 'Select date range',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: dateRange != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (dateRange != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    dateRange = null;
                    filters.remove('dateRange');
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSizeFilter(BuildContext context) {
    final sizeRanges = [
      'Under ₹500 Cr',
      '₹500-1000 Cr',
      '₹1000-2000 Cr',
      '₹2000-5000 Cr',
      'Above ₹5000 Cr',
    ];
    final selectedSizes = List<String>.from(filters['issueSizes'] ?? []);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizeRanges.map((size) {
        final isSelected = selectedSizes.contains(size);
        return FilterChip(
          label: Text(size),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedSizes.add(size);
              } else {
                selectedSizes.remove(size);
              }
              filters['issueSizes'] = selectedSizes;
            });
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateRange = picked;
        filters['dateRange'] = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearFilters() {
    setState(() {
      filters.clear();
      dateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(filters);
    widget.onClose();
  }
}
