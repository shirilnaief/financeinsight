import '../models/portfolio_model.dart';
import './supabase_service.dart';

class PortfolioService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Get user's portfolio holdings
  Future<List<PortfolioHolding>> getUserHoldings() async {
    if (!_supabase.isAuthenticated) return [];

    try {
      final response = await _supabase
          .select('portfolio_holdings')
          .eq('user_id', _supabase.currentUser!.id)
          .order('created_at', ascending: false);

      return (response.data as List)
          .map((json) => PortfolioHolding.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch portfolio holdings: $e');
    }
  }

  // Add new holding
  Future<PortfolioHolding> addHolding(PortfolioHolding holding) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final data = holding.toJson();
      data['user_id'] = _supabase.currentUser!.id;
      data.remove('id'); // Let database generate ID

      final response = await _supabase.insert('portfolio_holdings', data);
      final selected = await _supabase.select('portfolio_holdings').eq('user_id', _supabase.currentUser!.id).single();

      return PortfolioHolding.fromJson(selected.data);
    } catch (e) {
      throw Exception('Failed to add holding: $e');
    }
  }

  // Update holding
  Future<PortfolioHolding> updateHolding(PortfolioHolding holding) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final data = holding.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.update('portfolio_holdings', data);
      final response = await _supabase
          .select('portfolio_holdings')
          .eq('id', holding.id)
          .eq('user_id', _supabase.currentUser!.id)
          .single();

      return PortfolioHolding.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update holding: $e');
    }
  }

  // Delete holding
  Future<void> deleteHolding(String holdingId) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.delete('portfolio_holdings');
      await _supabase
          .select('portfolio_holdings')
          .eq('id', holdingId)
          .eq('user_id', _supabase.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete holding: $e');
    }
  }

  // Get user's transactions
  Future<List<PortfolioTransaction>> getUserTransactions({int? limit}) async {
    if (!_supabase.isAuthenticated) return [];

    try {
      var query = _supabase
          .select('portfolio_transactions')
          .eq('user_id', _supabase.currentUser!.id)
          .order('transaction_date', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response.data as List)
          .map((json) => PortfolioTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Add new transaction
  Future<PortfolioTransaction> addTransaction(
      PortfolioTransaction transaction) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final data = transaction.toJson();
      data['user_id'] = _supabase.currentUser!.id;
      data.remove('id'); // Let database generate ID

      await _supabase.insert('portfolio_transactions', data);
      final response = await _supabase
          .select('portfolio_transactions')
          .eq('user_id', _supabase.currentUser!.id)
          .single();

      return PortfolioTransaction.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Get portfolio summary
  Future<PortfolioSummary> getPortfolioSummary() async {
    if (!_supabase.isAuthenticated) {
      return PortfolioSummary(
        totalValue: 0,
        totalCost: 0,
        dailyChange: 0,
        dailyChangePercentage: 0,
        totalProfitLoss: 0,
        totalProfitLossPercentage: 0,
        totalHoldings: 0,
      );
    }

    try {
      final holdings = await getUserHoldings();

      double totalValue = 0;
      double totalCost = 0;

      for (final holding in holdings) {
        totalValue += holding.totalValue;
        totalCost += holding.totalCost;
      }

      final totalProfitLoss = totalValue - totalCost;
      final totalProfitLossPercentage =
          totalCost > 0 ? (totalProfitLoss / totalCost) * 100 : 0;

      // For demo purposes, generate random daily change
      final dailyChange =
          totalValue * (0.001 * (DateTime.now().millisecond % 20 - 10));
      final dailyChangePercentage =
          totalValue > 0 ? (dailyChange / totalValue) * 100 : 0;

      return PortfolioSummary(
        totalValue: totalValue,
        totalCost: totalCost,
        dailyChange: dailyChange,
        dailyChangePercentage: dailyChangePercentage.toDouble(),
        totalProfitLoss: totalProfitLoss,
        totalProfitLossPercentage: totalProfitLossPercentage.toDouble(),
        totalHoldings: holdings.length,
      );
    } catch (e) {
      throw Exception('Failed to calculate portfolio summary: $e');
    }
  }

  // Real-time subscription for portfolio updates
  void subscribeToPortfolioUpdates(void Function() onUpdate) {
    if (!_supabase.isAuthenticated) return;

    _supabase.subscribe(
      'portfolio_holdings',
      callback: (payload) {
        if (payload.newRecord['user_id'] == _supabase.currentUser!.id ||
            payload.oldRecord['user_id'] == _supabase.currentUser!.id) {
          onUpdate();
        }
      },
    );

    _supabase.subscribe(
      'portfolio_transactions',
      callback: (payload) {
        if (payload.newRecord['user_id'] == _supabase.currentUser!.id ||
            payload.oldRecord['user_id'] == _supabase.currentUser!.id) {
          onUpdate();
        }
      },
    );
  }
}