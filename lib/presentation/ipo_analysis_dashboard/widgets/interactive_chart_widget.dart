import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class InteractiveChartWidget extends StatefulWidget {
  final String chartType;
  final List<FlSpot> data;
  final String title;

  const InteractiveChartWidget({
    super.key,
    required this.chartType,
    required this.data,
    required this.title,
  });

  @override
  State<InteractiveChartWidget> createState() => _InteractiveChartWidgetState();
}

class _InteractiveChartWidgetState extends State<InteractiveChartWidget> {
  bool _showTooltip = false;
  FlSpot? _tooltipSpot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                  height: 200,
                  child: LineChart(LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color: theme.dividerColor.withAlpha(128),
                                strokeWidth: 1);
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                                color: theme.dividerColor.withAlpha(128),
                                strokeWidth: 1);
                          }),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text(value.toInt().toString(),
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withAlpha(179)));
                                  })),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text('₹${value.toInt()}',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withAlpha(179)));
                                  }))),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: theme.dividerColor.withAlpha(128))),
                      lineBarsData: [
                        LineChartBarData(
                            spots: widget.data,
                            isCurved: true,
                            color: AppTheme.getSuccessColor(isLight),
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.getSuccessColor(isLight)
                                    .withAlpha(26))),
                      ],
                      lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              return LineTooltipItem(
                                  '₹${touchedSpot.y.toStringAsFixed(2)}',
                                  GoogleFonts.inter(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500));
                            }).toList();
                          }),
                          handleBuiltInTouches: true)))),
            ])));
  }
}
