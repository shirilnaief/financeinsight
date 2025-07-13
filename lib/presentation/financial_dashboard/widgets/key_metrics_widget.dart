import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class KeyMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> keyMetrics;

  const KeyMetricsWidget({
    super.key,
    required this.keyMetrics,
  });

  @override
  Widget build(BuildContext context) {
    if (keyMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Financial Metrics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMetricsGrid(context),
                const SizedBox(height: 24),
                if (_hasChartData()) _buildMetricsChart(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final metrics = _getFormattedMetrics();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                metric['label'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                metric['value'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: metric['color'],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Health Score',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _getPieChartSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(context),
      ],
    );
  }

  List<Map<String, dynamic>> _getFormattedMetrics() {
    final List<Map<String, dynamic>> formattedMetrics = [];

    keyMetrics.forEach((key, value) {
      String label = _formatLabel(key);
      String formattedValue = _formatValue(value);
      Color color = _getMetricColor(key, value);

      formattedMetrics.add({
        'label': label,
        'value': formattedValue,
        'color': color,
      });
    });

    return formattedMetrics;
  }

  String _formatLabel(String key) {
    switch (key.toLowerCase()) {
      case 'revenue':
        return 'Revenue';
      case 'netincome':
        return 'Net Income';
      case 'totaldebt':
        return 'Total Debt';
      case 'cashflow':
        return 'Cash Flow';
      case 'grossmargin':
        return 'Gross Margin';
      case 'operatingmargin':
        return 'Operating Margin';
      case 'netmargin':
        return 'Net Margin';
      case 'roe':
        return 'ROE';
      case 'roa':
        return 'ROA';
      default:
        return key.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        );
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';

    if (value is String) {
      return value;
    }

    if (value is num) {
      if (value >= 1000000000) {
        return '\$${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (value >= 1000000) {
        return '\$${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '\$${(value / 1000).toStringAsFixed(1)}K';
      } else if (value < 1 && value > 0) {
        return '${(value * 100).toStringAsFixed(1)}%';
      } else {
        return '\$${value.toStringAsFixed(0)}';
      }
    }

    return value.toString();
  }

  Color _getMetricColor(String key, dynamic value) {
    switch (key.toLowerCase()) {
      case 'revenue':
      case 'netincome':
      case 'cashflow':
        return const Color(0xFF2E7D32); // Green for positive metrics
      case 'totaldebt':
        return const Color(0xFFF57C00); // Orange for debt
      default:
        return const Color(0xFF1B365D); // Primary color
    }
  }

  bool _hasChartData() {
    return keyMetrics.containsKey('revenue') ||
        keyMetrics.containsKey('netIncome') ||
        keyMetrics.containsKey('totalDebt');
  }

  List<PieChartSectionData> _getPieChartSections() {
    final List<PieChartSectionData> sections = [];

    double revenue = _getNumericValue('revenue', 100);
    double netIncome = _getNumericValue('netIncome', 20);
    double debt = _getNumericValue('totalDebt', 30);

    double total = revenue + debt;

    if (revenue > 0) {
      sections.add(PieChartSectionData(
        value: revenue,
        color: const Color(0xFF2E7D32),
        title: '${((revenue / total) * 100).toInt()}%',
        radius: 30,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ));
    }

    if (debt > 0) {
      sections.add(PieChartSectionData(
        value: debt,
        color: const Color(0xFFF57C00),
        title: '${((debt / total) * 100).toInt()}%',
        radius: 30,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ));
    }

    return sections;
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(context, 'Assets', const Color(0xFF2E7D32)),
        _buildLegendItem(context, 'Debt', const Color(0xFFF57C00)),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  double _getNumericValue(String key, double defaultValue) {
    final value = keyMetrics[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }
}
