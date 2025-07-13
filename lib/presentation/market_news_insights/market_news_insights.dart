import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './widgets/news_card_widget.dart';
import './widgets/news_ticker_widget.dart';
import './widgets/search_filter_widget.dart';
import './widgets/trending_topics_widget.dart';

class MarketNewsInsights extends StatefulWidget {
  const MarketNewsInsights({super.key});

  @override
  State<MarketNewsInsights> createState() => _MarketNewsInsightsState();
}

class _MarketNewsInsightsState extends State<MarketNewsInsights>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  final List<String> _breakingHeadlines = [
    'Market opens higher on positive global cues',
    'New IPO filing: TechCorp announces ₹2000Cr public offering',
    'SEBI introduces new regulations for retail investors',
    'Nifty 50 crosses 20,000 mark for the first time',
    'Foreign investors show renewed interest in Indian markets',
  ];

  final List<String> _categories = [
    'All',
    'IPO News',
    'Market Analysis',
    'Regulatory Updates',
    'Expert Opinions',
  ];

  final List<Map<String, dynamic>> _newsItems = [
    {
      'headline':
          'TechCorp IPO oversubscribed by 15x on strong investor demand',
      'summary':
          'The technology company\'s initial public offering saw unprecedented demand from both retail and institutional investors.',
      'source': 'Economic Times',
      'category': 'IPO News',
      'publishedAt': '2h ago',
      'readingTime': '4 min read',
      'imageUrl':
          'https://images.pexels.com/photos/590041/pexels-photo-590041.jpeg?w=200&h=120&fit=crop',
      'engagementCount': 1250,
      'isBookmarked': false,
    },
    {
      'headline': 'Market analysis: Q3 earnings drive sector rotation',
      'summary':
          'Strong quarterly results from technology and healthcare sectors are prompting investors to rebalance portfolios.',
      'source': 'Mint',
      'category': 'Market Analysis',
      'publishedAt': '4h ago',
      'readingTime': '6 min read',
      'imageUrl':
          'https://images.pixabay.com/photo/2016/11/27/21/42/stock-1863880_960_720.jpg?w=200&h=120&fit=crop',
      'engagementCount': 890,
      'isBookmarked': true,
    },
    {
      'headline': 'SEBI proposes new framework for IPO pricing transparency',
      'summary':
          'Regulatory body seeks to enhance disclosure requirements and pricing mechanisms for better investor protection.',
      'source': 'Reuters',
      'category': 'Regulatory Updates',
      'publishedAt': '6h ago',
      'readingTime': '3 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=120&fit=crop',
      'engagementCount': 567,
      'isBookmarked': false,
    },
    {
      'headline': 'Expert view: Why mid-cap IPOs are gaining momentum',
      'summary':
          'Investment experts share insights on the growing appeal of mid-cap public offerings in the current market environment.',
      'source': 'Bloomberg',
      'category': 'Expert Opinions',
      'publishedAt': '8h ago',
      'readingTime': '5 min read',
      'imageUrl':
          'https://images.pexels.com/photos/534216/pexels-photo-534216.jpeg?w=200&h=120&fit=crop',
      'engagementCount': 432,
      'isBookmarked': false,
    },
    {
      'headline':
          'Market update: Banking sector shows resilience amid volatility',
      'summary':
          'Despite global uncertainty, Indian banking stocks maintain stability with strong fundamentals supporting investor confidence.',
      'source': 'MoneyControl',
      'category': 'Market Analysis',
      'publishedAt': '10h ago',
      'readingTime': '4 min read',
      'imageUrl':
          'https://images.pixabay.com/photo/2017/01/18/17/14/analytics-1990435_960_720.jpg?w=200&h=120&fit=crop',
      'engagementCount': 678,
      'isBookmarked': true,
    },
  ];

  final List<Map<String, dynamic>> _trendingTopics = [
    {
      'title': 'IPO Market Rally',
      'sentiment': 'positive',
      'mentions': 2450,
      'trend': 'up',
      'change': 15.3,
    },
    {
      'title': 'Tech Sector Rotation',
      'sentiment': 'neutral',
      'mentions': 1890,
      'trend': 'stable',
      'change': 2.1,
    },
    {
      'title': 'Regulatory Changes',
      'sentiment': 'negative',
      'mentions': 1234,
      'trend': 'down',
      'change': -5.7,
    },
    {
      'title': 'Foreign Investment',
      'sentiment': 'positive',
      'mentions': 987,
      'trend': 'up',
      'change': 8.9,
    },
    {
      'title': 'Market Volatility',
      'sentiment': 'neutral',
      'mentions': 756,
      'trend': 'stable',
      'change': 1.2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market News & Insights'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_off,
            ),
            onPressed: _toggleNotifications,
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: _showBookmarks,
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            setState(() {
              _selectedCategory = _categories[index];
            });
          },
          tabs: _categories.map((category) {
            return Tab(
              text: category,
              height: 40,
            );
          }).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        child: Column(
          children: [
            // Breaking news ticker
            Container(
              padding: const EdgeInsets.all(16),
              child: NewsTickerWidget(headlines: _breakingHeadlines),
            ),

            // Search and filters
            SearchFilterWidget(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFiltersChanged: _handleFiltersChanged,
              currentQuery: _searchQuery,
            ),

            // Content area
            Expanded(
              child: _isLoading ? _buildLoadingView() : _buildContentView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlert,
        child: const Icon(Icons.add_alert),
        tooltip: 'Create News Alert',
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContentView() {
    return Row(
      children: [
        // Main content
        Expanded(
          flex: 2,
          child: _buildNewsList(),
        ),

        // Sidebar (trending topics)
        Container(
          width: 300,
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
          child: TrendingTopicsWidget(trendingTopics: _trendingTopics),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    final filteredNews = _getFilteredNews();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNews.length,
      itemBuilder: (context, index) {
        final newsItem = filteredNews[index];
        return NewsCardWidget(
          newsItem: newsItem,
          onTap: () => _openNewsDetail(newsItem),
          onBookmark: () => _toggleBookmark(index),
          onShare: () => _shareNews(newsItem),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredNews() {
    var filtered = _newsItems.where((news) {
      final matchesSearch = _searchQuery.isEmpty ||
          news['headline'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news['summary'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || news['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return filtered;
  }

  Future<void> _refreshNews() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('News updated successfully')),
    );
  }

  void _handleFiltersChanged(Map<String, dynamic> filters) {
    if (filters['reset'] == true) {
      setState(() {
        _searchQuery = '';
        _selectedCategory = 'All';
      });
    }

    // Handle other filter changes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters applied')),
    );
  }

  void _toggleBookmark(int index) {
    setState(() {
      _newsItems[index]['isBookmarked'] =
          !(_newsItems[index]['isBookmarked'] ?? false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _newsItems[index]['isBookmarked']
              ? 'Added to bookmarks'
              : 'Removed from bookmarks',
        ),
      ),
    );
  }

  void _shareNews(Map<String, dynamic> newsItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${newsItem['headline']}'),
        action: SnackBarAction(
          label: 'Copy Link',
          onPressed: () {},
        ),
      ),
    );
  }

  void _openNewsDetail(Map<String, dynamic> newsItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newsItem['headline']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Source: ${newsItem['source']} • ${newsItem['publishedAt']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
              ),
              const SizedBox(height: 16),
              Text(newsItem['summary']),
              const SizedBox(height: 16),
              Text(
                'This is a detailed view of the news article. In a real app, this would contain the full article content with proper formatting, images, and related articles.',
                style: GoogleFonts.inter(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareNews(newsItem);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled
              ? 'Notifications enabled'
              : 'Notifications disabled',
        ),
      ),
    );
  }

  void _showBookmarks() {
    final bookmarkedNews =
        _newsItems.where((news) => news['isBookmarked'] == true).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarked Articles'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: bookmarkedNews.isEmpty
              ? const Center(child: Text('No bookmarked articles'))
              : ListView.builder(
                  itemCount: bookmarkedNews.length,
                  itemBuilder: (context, index) {
                    final news = bookmarkedNews[index];
                    return ListTile(
                      title: Text(
                        news['headline'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          Text('${news['source']} • ${news['publishedAt']}'),
                      onTap: () {
                        Navigator.pop(context);
                        _openNewsDetail(news);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('News Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Breaking news alerts'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            ListTile(
              title: const Text('Notification Frequency'),
              subtitle: const Text('Real-time'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Preferred Sources'),
              subtitle: const Text('Manage news sources'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Offline Reading'),
              subtitle: const Text('Download for offline access'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create News Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Keywords',
                hintText: 'e.g., "IPO", "TechCorp", "SEBI"',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.skip(1).map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Immediate alerts'),
              subtitle: const Text('Get notified instantly'),
              value: true,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News alert created')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
