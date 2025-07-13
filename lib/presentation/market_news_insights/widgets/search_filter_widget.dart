import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final String currentQuery;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    this.currentQuery = '',
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.currentQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news, companies, or keywords...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: widget.onSearchChanged,
            ),

            // Advanced filters (expandable)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? null : 0,
              child: _isExpanded ? _buildAdvancedFilters(context) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Advanced Filters',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Date range
        _buildFilterSection(
          context,
          'Date Range',
          DropdownButton<String>(
            value: 'Last 7 days',
            underline: const SizedBox(),
            items: [
              'Today',
              'Last 7 days',
              'Last 30 days',
              'Last 3 months',
              'Custom range',
            ].map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(
                  range,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              widget.onFiltersChanged({'dateRange': value});
            },
          ),
        ),

        // News sources
        _buildFilterSection(
          context,
          'Sources',
          Wrap(
            spacing: 8,
            children: [
              'All',
              'Economic Times',
              'Mint',
              'Reuters',
              'Bloomberg',
              'MoneyControl',
            ].map((source) {
              return FilterChip(
                label: Text(
                  source,
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                selected: source == 'All',
                onSelected: (selected) {
                  widget.onFiltersChanged({'source': source});
                },
              );
            }).toList(),
          ),
        ),

        // Relevance to portfolio
        _buildFilterSection(
          context,
          'Relevance',
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Portfolio relevant only',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  value: false,
                  onChanged: (value) {
                    widget.onFiltersChanged({'portfolioRelevant': value});
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        // Apply/Reset buttons
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.onFiltersChanged({'reset': true});
                },
                child: const Text('Reset Filters'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                  widget.onFiltersChanged({'apply': true});
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(
      BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withAlpha(204),
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
