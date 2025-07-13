import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class PerformanceComparisonWidget extends StatefulWidget {
  const PerformanceComparisonWidget({super.key});

  @override
  State<PerformanceComparisonWidget> createState() =>
      _PerformanceComparisonWidgetState();
}

class _PerformanceComparisonWidgetState
    extends State<PerformanceComparisonWidget> {
  String _selectedIndex = 'NIFTY 50';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance Comparison',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedIndex,
                  underline: const SizedBox(),
                  items: ['NIFTY 50', 'SENSEX', 'NIFTY NEXT 50'].map((index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(
                        index,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIndex = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.dividerColor.withAlpha(77),
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
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Mar',
                            'May',
                            'Jul',
                            'Sep',
                            'Nov'
                          ];
                          if (value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color:
                                    theme.colorScheme.onSurface.withAlpha(179),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withAlpha(179),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Portfolio line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 5),
                        FlSpot(1, 12),
                        FlSpot(2, 8),
                        FlSpot(3, 15),
                        FlSpot(4, 22),
                        FlSpot(5, 18),
                      ],
                      isCurved: true,
                      color: AppTheme.getSuccessColor(isLight),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    // Index line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(1, 8),
                        FlSpot(2, 6),
                        FlSpot(3, 10),
                        FlSpot(4, 14),
                        FlSpot(5, 12),
                      ],
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem(
                    context, 'Portfolio', AppTheme.getSuccessColor(isLight)),
                const SizedBox(width: 24),
                _buildLegendItem(
                    context, _selectedIndex, theme.colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withAlpha(204),
          ),
        ),
      ],
    );
  }
}
