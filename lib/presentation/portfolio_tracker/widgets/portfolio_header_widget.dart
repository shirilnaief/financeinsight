import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_model.dart';

class PortfolioHeaderWidget extends StatelessWidget {
  final PortfolioSummary summary;

  const PortfolioHeaderWidget({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(204),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Portfolio Tracker',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${summary.totalHoldings} Holdings',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Total Portfolio Value',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onPrimary.withAlpha(204),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${_formatNumber(summary.totalValue)}',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildChangeIndicator(
                  label: 'Today',
                  value: summary.dailyChange,
                  percentage: summary.dailyChangePercentage,
                  isPositive: summary.isDailyGain,
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _buildChangeIndicator(
                  label: 'Total',
                  value: summary.totalProfitLoss,
                  percentage: summary.totalProfitLossPercentage,
                  isPositive: summary.isTotalGain,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator({
    required String label,
    required double value,
    required double percentage,
    required bool isPositive,
    required ThemeData theme,
  }) {
    final color = theme.colorScheme.onPrimary;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color.withAlpha(204),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '₹${_formatNumber(value.abs())}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${isPositive ? '+' : '-'}${percentage.abs().toStringAsFixed(2)}%)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(230),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
