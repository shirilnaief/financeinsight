import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/portfolio_model.dart';
import './widgets/portfolio_analytics_widget.dart';
import './widgets/portfolio_header_widget.dart';
import './widgets/portfolio_holdings_widget.dart';
import './widgets/portfolio_performance_chart_widget.dart';
import './widgets/transaction_history_widget.dart';

class PortfolioTrackerScreen extends StatefulWidget {
  const PortfolioTrackerScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioTrackerScreen> createState() => _PortfolioTrackerScreenState();
}

class _PortfolioTrackerScreenState extends State<PortfolioTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - in production, this would come from a service/API
  late PortfolioSummary portfolioSummary;
  late List<PortfolioHolding> holdings;
  late List<PortfolioTransaction> transactions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    portfolioSummary = PortfolioSummary.getSampleData();
    holdings = PortfolioHolding.getSampleData();
    transactions = PortfolioTransaction.getSampleData();
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
      body: RefreshIndicator(
        onRefresh: _refreshPortfolio,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PortfolioHeaderWidget(summary: portfolioSummary),
            ),
            SliverToBoxAdapter(
              child: _buildQuickActions(theme),
            ),
            SliverToBoxAdapter(
              child: _buildTabBar(theme),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHoldingsTab(),
                  _buildPerformanceTab(),
                  _buildTransactionsTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPositionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Position'),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              'Set Alert',
              Icons.notifications_outlined,
              () => _showSetAlertDialog(),
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Export Report',
              Icons.download_outlined,
              () => _exportPortfolioReport(),
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Tax Report',
              Icons.receipt_long_outlined,
              () => _generateTaxReport(),
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(51),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        tabs: const [
          Tab(text: 'Holdings'),
          Tab(text: 'Performance'),
          Tab(text: 'Transactions'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildHoldingsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          PortfolioHoldingsWidget(
            holdings: holdings,
            onHoldingTap: _showHoldingDetails,
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          PortfolioPerformanceChartWidget(),
          SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TransactionHistoryWidget(transactions: transactions),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          PortfolioAnalyticsWidget(holdings: holdings),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Future<void> _refreshPortfolio() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _loadData();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolio refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showHoldingDetails(PortfolioHolding holding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildHoldingDetailsSheet(holding),
    );
  }

  Widget _buildHoldingDetailsSheet(PortfolioHolding holding) {
    final theme = Theme.of(context);
    final profitLossColor = holding.isProfit
        ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
        : AppTheme.getErrorColor(theme.brightness == Brightness.light);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageWidget(
                imageUrl: holding.companyLogo,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.companyName,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      holding.symbol,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Value', style: theme.textTheme.bodyMedium),
                    Text(
                      '₹${holding.totalValue.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total P&L', style: theme.textTheme.bodyMedium),
                    Text(
                      '₹${holding.profitLoss.toStringAsFixed(0)} (${holding.profitLossPercentage.toStringAsFixed(2)}%)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: profitLossColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dividend Yield', style: theme.textTheme.bodyMedium),
                    Text(
                      '${holding.dividendYield.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditPositionDialog(holding);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSellPositionDialog(holding);
                  },
                  icon: const Icon(Icons.sell),
                  label: const Text('Sell'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getErrorColor(
                        theme.brightness == Brightness.light),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  void _showAddPositionDialog() {
    // Implementation for adding new position
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Position feature coming soon')),
    );
  }

  void _showEditPositionDialog(PortfolioHolding holding) {
    // Implementation for editing position
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${holding.companyName} position')),
    );
  }

  void _showSellPositionDialog(PortfolioHolding holding) {
    // Implementation for selling position
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sell ${holding.companyName} position')),
    );
  }

  void _showSetAlertDialog() {
    // Implementation for setting price alerts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set Alert feature coming soon')),
    );
  }

  void _exportPortfolioReport() {
    // Implementation for exporting portfolio report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export Report feature coming soon')),
    );
  }

  void _generateTaxReport() {
    // Implementation for generating tax report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tax Report feature coming soon')),
    );
  }
}
