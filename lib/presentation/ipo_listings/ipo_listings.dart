import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/ipo_model.dart';
import './widgets/ipo_filter_panel_widget.dart';
import './widgets/ipo_grid_widget.dart';
import './widgets/ipo_search_bar_widget.dart';

class IPOListingsScreen extends StatefulWidget {
  const IPOListingsScreen({super.key});

  @override
  State<IPOListingsScreen> createState() => _IPOListingsScreenState();
}

class _IPOListingsScreenState extends State<IPOListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<IPOModel> _allIPOs = [];
  List<IPOModel> _filteredIPOs = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIPOData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIPOData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _allIPOs = IPOModel.getSampleData();
      _filteredIPOs = _allIPOs;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    String query = _searchController.text.toLowerCase();
    List<IPOModel> filtered = _allIPOs;

    // Apply search filter
    if (query.isNotEmpty) {
      filtered = filtered
          .where((ipo) =>
              ipo.companyName.toLowerCase().contains(query) ||
              ipo.category.toLowerCase().contains(query))
          .toList();
    }

    // Apply status filter
    if (_activeFilters['statuses'] != null &&
        (_activeFilters['statuses'] as List).isNotEmpty) {
      List<IPOStatus> selectedStatuses = _activeFilters['statuses'];
      filtered = filtered
          .where((ipo) => selectedStatuses.contains(ipo.status))
          .toList();
    }

    // Apply category filter
    if (_activeFilters['categories'] != null &&
        (_activeFilters['categories'] as List).isNotEmpty) {
      List<String> selectedCategories = _activeFilters['categories'];
      filtered = filtered
          .where((ipo) => selectedCategories.contains(ipo.category))
          .toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      DateTimeRange dateRange = _activeFilters['dateRange'];
      filtered = filtered.where((ipo) {
        return (ipo.openDate.isAfter(dateRange.start) ||
                ipo.openDate.isAtSameMomentAs(dateRange.start)) &&
            (ipo.closeDate.isBefore(dateRange.end) ||
                ipo.closeDate.isAtSameMomentAs(dateRange.end));
      }).toList();
    }

    // Apply issue size filter
    if (_activeFilters['issueSizes'] != null &&
        (_activeFilters['issueSizes'] as List).isNotEmpty) {
      List<String> selectedSizes = _activeFilters['issueSizes'];
      filtered = filtered
          .where((ipo) => _matchesIssueSizeFilter(ipo.issueSize, selectedSizes))
          .toList();
    }

    setState(() {
      _filteredIPOs = filtered;
    });
  }

  bool _matchesIssueSizeFilter(String issueSize, List<String> selectedSizes) {
    // Extract numeric value from issue size string (e.g., "₹2,500 Cr" -> 2500)
    String numericString = issueSize.replaceAll(RegExp(r'[^\d]'), '');
    if (numericString.isEmpty) return false;

    int size = int.tryParse(numericString) ?? 0;

    for (String selectedSize in selectedSizes) {
      switch (selectedSize) {
        case 'Under ₹500 Cr':
          if (size < 500) return true;
          break;
        case '₹500-1000 Cr':
          if (size >= 500 && size <= 1000) return true;
          break;
        case '₹1000-2000 Cr':
          if (size >= 1000 && size <= 2000) return true;
          break;
        case '₹2000-5000 Cr':
          if (size >= 2000 && size <= 5000) return true;
          break;
        case 'Above ₹5000 Cr':
          if (size > 5000) return true;
          break;
      }
    }
    return false;
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return IPOFilterPanelWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _applyFiltersAndSearch();
          },
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _onIPOTap(IPOModel ipo) {
    // Navigate to IPO details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening details for ${ipo.companyName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBookmarkTap(IPOModel ipo) {
    setState(() {
      int index = _allIPOs.indexWhere((item) => item.id == ipo.id);
      if (index != -1) {
        _allIPOs[index] = _allIPOs[index].copyWith(
          isBookmarked: !_allIPOs[index].isBookmarked,
        );
      }
    });
    _applyFiltersAndSearch();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ipo.isBookmarked
              ? '${ipo.companyName} removed from bookmarks'
              : '${ipo.companyName} added to bookmarks',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
    });
    _applyFiltersAndSearch();
  }

  bool get _hasActiveFilters {
    return _activeFilters.isNotEmpty || _searchController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IPO Listings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          if (_hasActiveFilters)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all filters',
            ),
          IconButton(
            onPressed: _loadIPOData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          IPOSearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              // Search is handled by listener
            },
            onFilterTap: _showFilterPanel,
          ),

          // Active filters indicator
          if (_hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredIPOs.length} of ${_allIPOs.length} IPOs',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // IPO grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadIPOData,
              child: IPOGridWidget(
                ipos: _filteredIPOs,
                onIPOTap: _onIPOTap,
                onBookmarkTap: _onBookmarkTap,
                isLoading: _isLoading,
                searchQuery: _searchController.text,
                hasActiveFilters: _activeFilters.isNotEmpty,
                onClearFilters: _clearFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
