import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final int progress;
  final String message;

  const LoadingIndicatorWidget({
    Key? key,
    required this.progress,
    required this.message,
  }) : super(key: key);

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular Progress Indicator with Percentage
        SizedBox(
          width: 20.w,
          height: 20.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 3.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary.withAlpha(26),
                  ),
                ),
              ),

              // Progress circle
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(
                    begin: 0.0,
                    end: widget.progress / 100.0,
                  ),
                  builder: (context, value, child) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Percentage text
              TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 500),
                tween: IntTween(begin: 0, end: widget.progress),
                builder: (context, value, child) => Text(
                  '$value%',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Rotating indicator
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationController.value * 2.0 * 3.14159,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(77),
                        width: 1.0,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 1.w,
                        height: 1.w,
                        margin: EdgeInsets.only(top: 0.5.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Loading message with typewriter effect
        TweenAnimationBuilder<int>(
          duration: const Duration(milliseconds: 300),
          tween: IntTween(begin: 0, end: widget.message.length),
          builder: (context, value, child) => Text(
            widget.message.substring(0, value),
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 1.h),

        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = widget.progress > (index * 25);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: isActive ? 3.w : 2.w,
              height: isActive ? 3.w : 2.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withAlpha(77),
              ),
            );
          }),
        ),
      ],
    );
  }
}
