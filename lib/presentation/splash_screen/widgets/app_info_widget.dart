import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Version and Copyright
        Text(
          'Version 1.0.0',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),

        SizedBox(height: 0.5.h),

        Text(
          '© 2025 FinanceInsight',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),

        SizedBox(height: 1.h),

        // Security and Privacy indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSecurityIndicator(
              context: context,
              icon: Icons.security_rounded,
              label: 'Secure',
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 1,
              height: 3.h,
              color: Theme.of(context).colorScheme.outline.withAlpha(77),
            ),
            _buildSecurityIndicator(
              context: context,
              icon: Icons.verified_user_rounded,
              label: 'Encrypted',
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 1,
              height: 3.h,
              color: Theme.of(context).colorScheme.outline.withAlpha(77),
            ),
            _buildSecurityIndicator(
              context: context,
              icon: Icons.privacy_tip_rounded,
              label: 'Private',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityIndicator({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 4.w,
          color: Theme.of(context).colorScheme.primary.withAlpha(179),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }
}
