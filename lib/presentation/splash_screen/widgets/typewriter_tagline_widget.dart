import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TypewriterTaglineWidget extends StatefulWidget {
  const TypewriterTaglineWidget({Key? key}) : super(key: key);

  @override
  State<TypewriterTaglineWidget> createState() =>
      _TypewriterTaglineWidgetState();
}

class _TypewriterTaglineWidgetState extends State<TypewriterTaglineWidget>
    with SingleTickerProviderStateMixin {
  static const String _tagline = 'Your Gateway to Smart Financial Insights';
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: _tagline.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          // Main tagline with typewriter effect
          AnimatedBuilder(
            animation: _characterCount,
            builder: (context, child) {
              final text = _tagline.substring(0, _characterCount.value);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Blinking cursor
                  if (_characterCount.value < _tagline.length)
                    _buildBlinkingCursor(context),
                ],
              );
            },
          ),

          SizedBox(height: 2.h),

          // Subtitle
          AnimatedOpacity(
            opacity: _controller.isCompleted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Empowering your financial decisions with AI-driven insights',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 3.h),

          // Feature highlights
          AnimatedOpacity(
            opacity: _controller.isCompleted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: _buildFeatureHighlights(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingCursor(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: (value * 2) % 2 > 1 ? 1.0 : 0.0,
              child: Container(
                width: 2,
                height: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    final features = [
      {'icon': Icons.analytics_rounded, 'text': 'Smart Analytics'},
      {'icon': Icons.trending_up_rounded, 'text': 'Real-time Data'},
      {'icon': Icons.security_rounded, 'text': 'Secure Platform'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(77),
                  width: 1.0,
                ),
              ),
              child: Icon(
                feature['icon'] as IconData,
                size: 5.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              feature['text'] as String,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
