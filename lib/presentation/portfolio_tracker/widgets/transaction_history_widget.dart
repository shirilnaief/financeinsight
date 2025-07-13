import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/portfolio_model.dart';
import '../../../theme/app_theme.dart';

class TransactionHistoryWidget extends StatefulWidget {
  final List<PortfolioTransaction> transactions;

  const TransactionHistoryWidget({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  State<TransactionHistoryWidget> createState() =>
      _TransactionHistoryWidgetState();
}

class _TransactionHistoryWidgetState extends State<TransactionHistoryWidget> {
  TransactionType? selectedFilter;
  List<PortfolioTransaction> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    filteredTransactions = widget.transactions;
  }

  void _filterTransactions(TransactionType? type) {
    setState(() {
      selectedFilter = type;
      if (type == null) {
        filteredTransactions = widget.transactions;
      } else {
        filteredTransactions = widget.transactions
            .where((transaction) => transaction.type == type)
            .toList();
      }
    });
  }

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
                'Transaction History',
                style: theme.textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  _showFilterDialog(context);
                },
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text(selectedFilter?.displayName ?? 'All'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (filteredTransactions.isEmpty)
          _buildEmptyState(theme)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return _buildTransactionCard(transaction, theme);
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
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedFilter != null
                ? 'No ${selectedFilter!.displayName.toLowerCase()} transactions found'
                : 'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      PortfolioTransaction transaction, ThemeData theme) {
    final typeColor = _getTransactionColor(transaction.type, theme);
    final typeIcon = _getTransactionIcon(transaction.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.companyName,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transaction.type.displayName} • ${transaction.symbol}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_formatNumber(transaction.totalAmount)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
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
                        '${transaction.quantity}',
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildMetric(
                        'Price',
                        '₹${transaction.price.toStringAsFixed(2)}',
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildMetric(
                        'Fees',
                        '₹${transaction.fees.toStringAsFixed(2)}',
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildMetric(
                        'Total',
                        '₹${_formatNumber(transaction.totalAmount)}',
                        theme,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, ThemeData theme) {
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
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(context, null, 'All Transactions'),
            ...TransactionType.values.map(
              (type) => _buildFilterOption(context, type, type.displayName),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
      BuildContext context, TransactionType? type, String label) {
    final theme = Theme.of(context);
    final isSelected = selectedFilter == type;

    return ListTile(
      title: Text(label),
      leading: Radio<TransactionType?>(
        value: type,
        groupValue: selectedFilter,
        onChanged: (value) {
          _filterTransactions(value);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        _filterTransactions(type);
        Navigator.pop(context);
      },
    );
  }

  Color _getTransactionColor(TransactionType type, ThemeData theme) {
    final isLight = theme.brightness == Brightness.light;
    switch (type) {
      case TransactionType.buy:
        return AppTheme.getSuccessColor(isLight);
      case TransactionType.sell:
        return AppTheme.getErrorColor(isLight);
      case TransactionType.dividend:
        return theme.colorScheme.primary;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.add_circle_outline;
      case TransactionType.sell:
        return Icons.remove_circle_outline;
      case TransactionType.dividend:
        return Icons.payments_outlined;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
