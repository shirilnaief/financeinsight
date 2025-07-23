import './supabase_service.dart';

class NewsService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Get all market news
  Future<List<MarketNews>> getAllNews({
    bool? isTrending,
    List<String>? tags,
    String? searchQuery,
    int? limit,
  }) async {
    try {
      var query = _supabase
          .select('market_news')
          .order('published_at', ascending: false);

      if (isTrending != null) {
        query = query.filter('is_trending', 'eq', isTrending);
      }

      if (tags != null && tags.isNotEmpty) {
        query = query.filter('tags', 'ov', tags);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.filter('title', 'ilike', '%$searchQuery%');
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response.data as List)
          .map((json) => MarketNews.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  // Get trending news
  Future<List<MarketNews>> getTrendingNews({int limit = 10}) async {
    return getAllNews(isTrending: true, limit: limit);
  }

  // Get news by tags
  Future<List<MarketNews>> getNewsByTags(List<String> tags,
      {int? limit}) async {
    return getAllNews(tags: tags, limit: limit);
  }

  // Search news
  Future<List<MarketNews>> searchNews(String query, {int? limit}) async {
    return getAllNews(searchQuery: query, limit: limit);
  }

  // Get news by ID
  Future<MarketNews?> getNewsById(String id) async {
    try {
      final response =
          await _supabase.select('market_news').filter('id', 'eq', id).single();

      return MarketNews.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get available news tags
  Future<List<String>> getAvailableTags() async {
    try {
      final response =
          await _supabase.select('market_news', 'tags').not('tags', 'is', null);

      final allTags = <String>{};
      for (final item in response.data as List) {
        final tags = item['tags'] as List?;
        if (tags != null) {
          allTags.addAll(tags.cast<String>());
        }
      }

      final tagList = allTags.toList()..sort();
      return tagList;
    } catch (e) {
      return [
        'technology',
        'finance',
        'ipo',
        'market',
        'stocks',
        'earnings',
        'investment'
      ];
    }
  }

  // Real-time subscription for news updates
  void subscribeToNewsUpdates(void Function() onUpdate) {
    _supabase.subscribe(
      'market_news',
      callback: (payload) => onUpdate(),
    );
  }
}

class MarketNews {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final String? author;
  final String? source;
  final String? imageUrl;
  final DateTime publishedAt;
  final List<String> tags;
  final bool isTrending;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketNews({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.author,
    this.source,
    this.imageUrl,
    required this.publishedAt,
    required this.tags,
    required this.isTrending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketNews.fromJson(Map<String, dynamic> json) {
    return MarketNews(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'],
      author: json['author'],
      source: json['source'],
      imageUrl: json['image_url'],
      publishedAt: DateTime.parse(json['published_at']),
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      isTrending: json['is_trending'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'author': author,
      'source': source,
      'image_url': imageUrl,
      'published_at': publishedAt.toIso8601String(),
      'tags': tags,
      'is_trending': isTrending,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}