import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/portfolio_model.dart';

class PortfolioHoldingsWidget extends StatelessWidget {
  final List<PortfolioHolding> holdings;
  final Function(PortfolioHolding) onHoldingTap;

  const PortfolioHoldingsWidget({
    Key? key,
    required this.holdings,
    required this.onHoldingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Holdings',
                style: theme.textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  // Add new position functionality
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Position'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (holdings.isEmpty)
          _buildEmptyState(theme)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: holdings.length,
            itemBuilder: (context, index) {
              final holding = holdings[index];
              return _buildHoldingCard(holding, theme, context);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            'No Holdings Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your portfolio by adding your first IPO investment',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(
      PortfolioHolding holding, ThemeData theme, BuildContext context) {
    final profitLossColor = holding.isProfit
        ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
        : AppTheme.getErrorColor(theme.brightness == Brightness.light);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => onHoldingTap(holding),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                holding.symbol,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(153),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  holding.category,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatNumber(holding.totalValue)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              holding.isProfit
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: profitLossColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${holding.isProfit ? '+' : ''}${holding.profitLossPercentage.toStringAsFixed(2)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: profitLossColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.surfaceContainerHighest.withAlpha(77),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetric(
                          'Quantity',
                          '${holding.quantity}',
                          theme,
                        ),
                      ),
                      Expanded(
                        child: _buildMetric(
                          'Avg Cost',
                          '₹${holding.purchasePrice.toStringAsFixed(0)}',
                          theme,
                        ),
                      ),
                      Expanded(
                        child: _buildMetric(
                          'Current Price',
                          '₹${holding.currentPrice.toStringAsFixed(0)}',
                          theme,
                        ),
                      ),
                      Expanded(
                        child: _buildMetric(
                          'P&L',
                          '₹${_formatNumber(holding.profitLoss.abs())}',
                          theme,
                          color: profitLossColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, ThemeData theme,
      {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
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
