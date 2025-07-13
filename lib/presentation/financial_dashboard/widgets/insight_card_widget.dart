import 'package:flutter/material.dart';

import '../../../models/financial_insight.dart';

class InsightCardWidget extends StatelessWidget {
  final FinancialInsight insight;

  const InsightCardWidget({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getInsightColor(insight.type).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getInsightIcon(insight.type),
                    size: 20,
                    color: _getInsightColor(insight.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (insight.value != null || insight.trend != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (insight.value != null) ...[
                              Text(
                                insight.value!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: _getInsightColor(insight.type),
                                    ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (insight.trend != null) ...[
                              Icon(
                                _getTrendIcon(insight.trend!),
                                size: 16,
                                color: _getTrendColor(insight.trend!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                insight.trend!.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: _getTrendColor(insight.trend!),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (insight.score != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(insight.score!).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${insight.score!.toInt()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(insight.score!),
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return const Color(0xFF2E7D32); // Green
      case InsightType.negative:
        return const Color(0xFFC62828); // Red
      case InsightType.warning:
        return const Color(0xFFF57C00); // Orange
      case InsightType.neutral:
        return const Color(0xFF757575); // Gray
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.trending_up;
      case InsightType.negative:
        return Icons.trending_down;
      case InsightType.warning:
        return Icons.warning_amber;
      case InsightType.neutral:
        return Icons.info_outline;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return const Color(0xFF2E7D32);
      case 'down':
        return const Color(0xFFC62828);
      case 'stable':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      case 'stable':
        return Icons.horizontal_rule;
      default:
        return Icons.horizontal_rule;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF2E7D32);
    if (score >= 60) return const Color(0xFFF57C00);
    return const Color(0xFFC62828);
  }
}
