import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/portfolio_model.dart';

class PortfolioAnalyticsWidget extends StatelessWidget {
  final List<PortfolioHolding> holdings;

  const PortfolioAnalyticsWidget({
    Key? key,
    required this.holdings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio Analytics',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSectorAllocation(theme),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildRiskMetrics(theme),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDiversificationMetrics(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorAllocation(ThemeData theme) {
    final sectorData = _calculateSectorAllocation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sector Allocation',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: _buildPieChartSections(sectorData, theme),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...sectorData.entries.map((entry) => _buildSectorItem(
              entry.key,
              entry.value,
              _getSectorColor(entry.key, theme),
              theme,
            )),
      ],
    );
  }

  Widget _buildRiskMetrics(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Assessment',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildRiskItem('Volatility', '12.5%', Colors.orange, theme),
        const SizedBox(height: 12),
        _buildRiskItem('Beta', '1.2', Colors.blue, theme),
        const SizedBox(height: 12),
        _buildRiskItem('Sharpe Ratio', '1.45', Colors.green, theme),
        const SizedBox(height: 12),
        _buildRiskItem('Max Drawdown', '-8.2%', Colors.red, theme),
      ],
    );
  }

  Widget _buildDiversificationMetrics(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diversification Metrics',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Holdings Count',
                '${holdings.length}',
                Icons.account_balance_wallet,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Sectors',
                '${_getUniqueSectors().length}',
                Icons.pie_chart,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Concentration',
                '${_getTopHoldingPercentage().toStringAsFixed(1)}%',
                Icons.donut_small,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectorItem(
      String sector, double percentage, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sector,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(
      String label, String value, Color color, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
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
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateSectorAllocation() {
    final totalValue =
        holdings.fold<double>(0, (sum, holding) => sum + holding.totalValue);
    final sectorValues = <String, double>{};

    for (final holding in holdings) {
      sectorValues[holding.category] =
          (sectorValues[holding.category] ?? 0) + holding.totalValue;
    }

    return sectorValues
        .map((sector, value) => MapEntry(sector, (value / totalValue) * 100));
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> sectorData, ThemeData theme) {
    return sectorData.entries.map((entry) {
      return PieChartSectionData(
        color: _getSectorColor(entry.key, theme),
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getSectorColor(String sector, ThemeData theme) {
    const colors = [
      Color(0xFF1B365D),
      Color(0xFF4A90A4),
      Color(0xFF2E7D32),
      Color(0xFFF57C00),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
    ];

    final index = _getUniqueSectors().toList().indexOf(sector);
    return colors[index % colors.length];
  }

  Set<String> _getUniqueSectors() {
    return holdings.map((holding) => holding.category).toSet();
  }

  double _getTopHoldingPercentage() {
    final totalValue =
        holdings.fold<double>(0, (sum, holding) => sum + holding.totalValue);
    final maxValue = holdings.fold<double>(0,
        (max, holding) => holding.totalValue > max ? holding.totalValue : max);
    return (maxValue / totalValue) * 100;
  }
}