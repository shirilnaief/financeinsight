import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PortfolioPerformanceChartWidget extends StatefulWidget {
  const PortfolioPerformanceChartWidget({Key? key}) : super(key: key);

  @override
  State<PortfolioPerformanceChartWidget> createState() =>
      _PortfolioPerformanceChartWidgetState();
}

class _PortfolioPerformanceChartWidgetState
    extends State<PortfolioPerformanceChartWidget> {
  String selectedPeriod = '1M';
  final List<String> periods = ['1W', '1M', '3M', '6M', '1Y'];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance',
                    style: theme.textTheme.titleLarge,
                  ),
                  _buildPeriodSelector(theme),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  _buildLineChartData(theme),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPeriod = period;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                period,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'Portfolio',
          theme.colorScheme.primary,
          theme,
        ),
        _buildLegendItem(
          'Market Index',
          AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          theme,
        ),
        _buildLegendItem(
          'Benchmark',
          theme.colorScheme.secondary,
          theme,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
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
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(ThemeData theme) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50000,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withAlpha(77),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('Jan', style: style);
                  break;
                case 1:
                  text = const Text('Feb', style: style);
                  break;
                case 2:
                  text = const Text('Mar', style: style);
                  break;
                case 3:
                  text = const Text('Apr', style: style);
                  break;
                case 4:
                  text = const Text('May', style: style);
                  break;
                case 5:
                  text = const Text('Jun', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50000,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 100000).toStringAsFixed(0)}L',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(77),
        ),
      ),
      minX: 0,
      maxX: 5,
      minY: 1400000,
      maxY: 1600000,
      lineBarsData: [
        // Portfolio line
        LineChartBarData(
          spots: _getPortfolioSpots(),
          isCurved: true,
          color: theme.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: theme.colorScheme.primary.withAlpha(26),
          ),
        ),
        // Market index line
        LineChartBarData(
          spots: _getMarketSpots(),
          isCurved: true,
          color: AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
        // Benchmark line
        LineChartBarData(
          spots: _getBenchmarkSpots(),
          isCurved: true,
          color: theme.colorScheme.secondary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [3, 3],
        ),
      ],
    );
  }

  List<FlSpot> _getPortfolioSpots() {
    return [
      const FlSpot(0, 1485000),
      const FlSpot(1, 1502000),
      const FlSpot(2, 1478000),
      const FlSpot(3, 1521000),
      const FlSpot(4, 1535000),
      const FlSpot(5, 1547250),
    ];
  }

  List<FlSpot> _getMarketSpots() {
    return [
      const FlSpot(0, 1485000),
      const FlSpot(1, 1495000),
      const FlSpot(2, 1488000),
      const FlSpot(3, 1512000),
      const FlSpot(4, 1525000),
      const FlSpot(5, 1538000),
    ];
  }

  List<FlSpot> _getBenchmarkSpots() {
    return [
      const FlSpot(0, 1485000),
      const FlSpot(1, 1490000),
      const FlSpot(2, 1485000),
      const FlSpot(3, 1505000),
      const FlSpot(4, 1515000),
      const FlSpot(5, 1525000),
    ];
  }
}
