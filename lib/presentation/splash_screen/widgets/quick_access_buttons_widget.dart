import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAccessButtonsWidget extends StatelessWidget {
  final VoidCallback onGuestMode;
  final VoidCallback onSignIn;

  const QuickAccessButtonsWidget({
    Key? key,
    required this.onGuestMode,
    required this.onSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Access',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
          ),

          SizedBox(height: 3.h),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSignIn();
              },
              icon: Icon(
                Icons.login_rounded,
                size: 5.w,
              ),
              label: Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor:
                    Theme.of(context).colorScheme.primary.withAlpha(77),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Guest Mode Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onGuestMode();
              },
              icon: Icon(
                Icons.person_outline_rounded,
                size: 5.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Continue as Guest',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Additional Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                context: context,
                icon: Icons.trending_up_rounded,
                label: 'Market',
                onTap: onGuestMode, // Navigate to market insights
              ),
              _buildQuickActionButton(
                context: context,
                icon: Icons.pie_chart_rounded,
                label: 'Portfolio',
                onTap: onGuestMode, // Navigate to portfolio
              ),
              _buildQuickActionButton(
                context: context,
                icon: Icons.article_rounded,
                label: 'News',
                onTap: onGuestMode, // Navigate to news
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.5.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(51),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withAlpha(26),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 6.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
