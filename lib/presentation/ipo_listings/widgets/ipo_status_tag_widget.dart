import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ipo_model.dart';

class IPOStatusTagWidget extends StatelessWidget {
  final IPOStatus status;
  final bool isDarkMode;

  const IPOStatusTagWidget({
    super.key,
    required this.status,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors['border']!,
          width: 1,
        ),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors() {
    switch (status) {
      case IPOStatus.upcoming:
        return isDarkMode
            ? {
                'background': const Color(0xFF1E3A8A).withAlpha(51),
                'border': const Color(0xFF3B82F6),
                'text': const Color(0xFF60A5FA),
              }
            : {
                'background': const Color(0xFFEBF4FF),
                'border': const Color(0xFF3B82F6),
                'text': const Color(0xFF1D4ED8),
              };
      case IPOStatus.ongoing:
        return isDarkMode
            ? {
                'background': const Color(0xFF14532D).withAlpha(51),
                'border': const Color(0xFF16A34A),
                'text': const Color(0xFF4ADE80),
              }
            : {
                'background': const Color(0xFFECFDF5),
                'border': const Color(0xFF16A34A),
                'text': const Color(0xFF15803D),
              };
      case IPOStatus.closed:
        return isDarkMode
            ? {
                'background': const Color(0xFF9A3412).withAlpha(51),
                'border': const Color(0xFFEA580C),
                'text': const Color(0xFFFB923C),
              }
            : {
                'background': const Color(0xFFFFF7ED),
                'border': const Color(0xFFEA580C),
                'text': const Color(0xFFC2410C),
              };
      case IPOStatus.listed:
        return isDarkMode
            ? {
                'background': const Color(0xFF581C87).withAlpha(51),
                'border': const Color(0xFF9333EA),
                'text': const Color(0xFFA855F7),
              }
            : {
                'background': const Color(0xFFFAF5FF),
                'border': const Color(0xFF9333EA),
                'text': const Color(0xFF7C3AED),
              };
    }
  }
}
