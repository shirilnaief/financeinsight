import 'package:flutter/material.dart';

import '../../../models/financial_insight.dart';
import './insight_card_widget.dart';

class InsightsListWidget extends StatelessWidget {
  final List<FinancialInsight> insights;

  const InsightsListWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No insights generated yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a financial report to get AI-powered insights.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group insights by category
    final Map<String, List<FinancialInsight>> groupedInsights = {};
    for (final insight in insights) {
      groupedInsights.putIfAbsent(insight.category, () => []).add(insight);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Insights',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...groupedInsights.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(entry.key),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              ...entry.value
                  .map((insight) => InsightCardWidget(insight: insight)),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'revenue':
        return Icons.trending_up;
      case 'profitability':
        return Icons.account_balance;
      case 'debt':
        return Icons.warning_amber;
      case 'cash flow':
        return Icons.water_drop;
      case 'margins':
        return Icons.percent;
      case 'liquidity':
        return Icons.opacity;
      case 'efficiency':
        return Icons.speed;
      case 'growth':
        return Icons.show_chart;
      case 'risk':
        return Icons.security;
      default:
        return Icons.analytics;
    }
  }
}
