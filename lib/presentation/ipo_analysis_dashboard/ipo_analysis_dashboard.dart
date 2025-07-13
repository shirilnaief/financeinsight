import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import './widgets/interactive_chart_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/performance_comparison_widget.dart';
import './widgets/portfolio_toggle_widget.dart';
import './widgets/time_period_selector_widget.dart';
import './widgets/watchlist_widget.dart';

class IPOAnalysisDashboard extends StatefulWidget {
  const IPOAnalysisDashboard({super.key});

  @override
  State<IPOAnalysisDashboard> createState() => _IPOAnalysisDashboardState();
}

class _IPOAnalysisDashboardState extends State<IPOAnalysisDashboard> {
  String _selectedPeriod = '1M';
  bool _isPortfolioView = true;
  bool _isLoading = false;

  final List<FlSpot> _chartData = const [
    FlSpot(0, 100),
    FlSpot(1, 115),
    FlSpot(2, 108),
    FlSpot(3, 125),
    FlSpot(4, 140),
    FlSpot(5, 135),
    FlSpot(6, 150),
  ];

  final List<Map<String, dynamic>> _watchlistItems = [
    {
      'name': 'Paytm IPO',
      'sector': 'Fintech',
      'price': 645.50,
      'change': -2.3,
    },
    {
      'name': 'Zomato IPO',
      'sector': 'Food Delivery',
      'price': 89.75,
      'change': 5.8,
    },
    {
      'name': 'Nykaa IPO',
      'sector': 'E-commerce',
      'price': 1250.20,
      'change': 1.2,
    },
    {
      'name': 'PolicyBazaar IPO',
      'sector': 'InsurTech',
      'price': 567.80,
      'change': -0.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPO Analysis Dashboard'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Controls
              Row(
                children: [
                  TimePeriodSelectorWidget(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                  ),
                  const Spacer(),
                  PortfolioToggleWidget(
                    isPortfolioView: _isPortfolioView,
                    onToggleChanged: (isPortfolio) {
                      setState(() {
                        _isPortfolioView = isPortfolio;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Key Metrics Cards
              _buildMetricsGrid(context),
              const SizedBox(height: 24),

              // Interactive Chart
              if (_isLoading)
                _buildLoadingChart(context)
              else
                InteractiveChartWidget(
                  chartType: 'line',
                  data: _chartData,
                  title: _isPortfolioView
                      ? 'Portfolio Performance ($_selectedPeriod)'
                      : 'Market Performance ($_selectedPeriod)',
                ),
              const SizedBox(height: 24),

              // Performance Comparison
              const PerformanceComparisonWidget(),
              const SizedBox(height: 24),

              // Watchlist
              WatchlistWidget(watchlistItems: _watchlistItems),
              const SizedBox(height: 24),

              // Additional Insights
              _buildInsightsSection(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterDialog,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filters'),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        MetricsCardWidget(
          title: 'Total Portfolio Value',
          value: '₹12,45,750',
          subtitle: 'Last updated: Now',
          percentage: 8.5,
          isPositive: true,
          icon: Icons.account_balance_wallet,
        ),
        MetricsCardWidget(
          title: 'Total Gains/Losses',
          value: '₹98,250',
          subtitle: 'Overall P&L',
          percentage: 12.3,
          isPositive: true,
          icon: Icons.trending_up,
        ),
        MetricsCardWidget(
          title: 'Success Rate',
          value: '76.5%',
          subtitle: '17 of 22 IPOs',
          percentage: 5.2,
          isPositive: true,
          icon: Icons.check_circle,
        ),
        MetricsCardWidget(
          title: 'Market Performance',
          value: '+15.8%',
          subtitle: 'Vs NIFTY 50',
          percentage: -2.1,
          isPositive: false,
          icon: Icons.show_chart,
        ),
      ],
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(
                  'Loading chart data...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              context,
              'Your portfolio is outperforming NIFTY 50 by 8.5% this month.',
              Icons.trending_up,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              'Consider diversifying into the pharma sector for better risk management.',
              Icons.info_outline,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              '3 IPOs in your watchlist are expected to list next week.',
              Icons.schedule,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      BuildContext context, String text, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting data to PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sector'),
              subtitle: const Text('Technology, Healthcare, Finance'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Issue Size'),
              subtitle: const Text('₹100Cr - ₹5000Cr'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Listing Date'),
              subtitle: const Text('Last 6 months'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Performance Range'),
              subtitle: const Text('-50% to +200%'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
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
                const SnackBar(content: Text('Filters applied')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
