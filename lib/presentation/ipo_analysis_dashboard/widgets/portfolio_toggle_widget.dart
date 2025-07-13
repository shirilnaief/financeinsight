import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioToggleWidget extends StatelessWidget {
  final bool isPortfolioView;
  final Function(bool) onToggleChanged;

  const PortfolioToggleWidget({
    super.key,
    required this.isPortfolioView,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(context, 'Market', !isPortfolioView),
          _buildToggleOption(context, 'Portfolio', isPortfolioView),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
      BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onToggleChanged(label == 'Portfolio'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
