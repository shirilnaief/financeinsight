import '../models/ipo_model.dart';
import './supabase_service.dart';

class IPOService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Get all IPO listings
  Future<List<IPOModel>> getAllIPOs({
    IPOStatus? status,
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.select('ipo_listings', '''
        *,
        user_ipo_bookmarks!left(
          id,
          user_id
        )
      ''');

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('company_name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response.data as List).map((json) {
        final bookmarks = json['user_ipo_bookmarks'] as List?;
        final isBookmarked = _supabase.isAuthenticated && 
            bookmarks?.any((b) => b['user_id'] == _supabase.currentUser!.id) == true;

        json['is_bookmarked'] = isBookmarked;
        json.remove('user_ipo_bookmarks');

        return IPOModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch IPOs: $e');
    }
  }

  // Get IPO by ID
  Future<IPOModel?> getIPOById(String id) async {
    try {
      final response = await _supabase
          .select('ipo_listings', '''
            *,
            user_ipo_bookmarks!left(
              id,
              user_id
            )
          ''')
          .eq('id', id)
          .single();

      final bookmarks = response.data['user_ipo_bookmarks'] as List?;
      final isBookmarked = _supabase.isAuthenticated && 
          bookmarks?.any((b) => b['user_id'] == _supabase.currentUser!.id) == true;

      response.data['is_bookmarked'] = isBookmarked;
      response.data.remove('user_ipo_bookmarks');

      return IPOModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Get user's bookmarked IPOs
  Future<List<IPOModel>> getUserBookmarkedIPOs() async {
    if (!_supabase.isAuthenticated) return [];

    try {
      final response = await _supabase
          .select('user_ipo_bookmarks', '''
            ipo_listings(*)
          ''')
          .eq('user_id', _supabase.currentUser!.id);

      return (response.data as List)
          .map((json) => IPOModel.fromJson(json['ipo_listings']))
          .map((ipo) => ipo.copyWith(isBookmarked: true))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookmarked IPOs: $e');
    }
  }

  // Toggle IPO bookmark
  Future<bool> toggleBookmark(String ipoId) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final userId = _supabase.currentUser!.id;

      // Check if bookmark exists
      final existingBookmark = await _supabase
          .select('user_ipo_bookmarks')
          .eq('user_id', userId)
          .eq('ipo_id', ipoId)
          .maybeSingle();

      if (existingBookmark != null) {
        // Remove bookmark
        await _supabase
            .delete('user_ipo_bookmarks')
            .eq('user_id', userId)
            .eq('ipo_id', ipoId);
        return false;
      } else {
        // Add bookmark
        await _supabase.insert('user_ipo_bookmarks', {
          'user_id': userId,
          'ipo_id': ipoId,
        });
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Get IPO categories
  Future<List<String>> getIPOCategories() async {
    try {
      final response = await _supabase
          .select('ipo_listings', 'category')
          .not('category', 'is', null);

      final categories = (response.data as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      return ['Technology', 'Finance', 'Healthcare', 'Energy', 'Retail', 'Automotive'];
    }
  }

  // Get trending IPOs
  Future<List<IPOModel>> getTrendingIPOs({int limit = 5}) async {
    try {
      final response = await _supabase
          .select('ipo_listings', '''
            *,
            user_ipo_bookmarks!left(
              id,
              user_id
            )
          ''')
          .in_('status', ['ongoing', 'upcoming'])
          .order('created_at', ascending: false)
          .limit(limit);

      return (response.data as List).map((json) {
        final bookmarks = json['user_ipo_bookmarks'] as List?;
        final isBookmarked = _supabase.isAuthenticated && 
            bookmarks?.any((b) => b['user_id'] == _supabase.currentUser!.id) == true;

        json['is_bookmarked'] = isBookmarked;
        json.remove('user_ipo_bookmarks');

        return IPOModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending IPOs: $e');
    }
  }

  // Real-time subscription for IPO updates
  void subscribeToIPOUpdates(void Function() onUpdate) {
    _supabase.subscribe(
      'ipo_listings',
      callback: (payload) => onUpdate());

    if (_supabase.isAuthenticated) {
      _supabase.subscribe(
        'user_ipo_bookmarks',
        callback: (payload) {
          if (payload.newRecord['user_id'] == _supabase.currentUser!.id ||
              payload.oldRecord['user_id'] == _supabase.currentUser!.id) {
            onUpdate();
          }
        });
    }
  }
}