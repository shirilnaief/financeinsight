import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class BiometricPromptWidget extends StatefulWidget {
  final VoidCallback onAuthenticate;

  const BiometricPromptWidget({
    Key? key,
    required this.onAuthenticate,
  }) : super(key: key);

  @override
  State<BiometricPromptWidget> createState() => _BiometricPromptWidgetState();
}

class _BiometricPromptWidgetState extends State<BiometricPromptWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBiometricTap() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1000));

      HapticFeedback.mediumImpact();
      widget.onAuthenticate();
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometric authentication failed. Please try again.',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(26),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Biometric Icon Button
          GestureDetector(
            onTap: _handleBiometricTap,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _isAuthenticating ? 0.95 : _pulseAnimation.value,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isAuthenticating
                          ? [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(204),
                            ]
                          : [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(77),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isAuthenticating
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fingerprint_rounded,
                          size: 8.w,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Text(
            _isAuthenticating
                ? 'Authenticating...'
                : 'Use biometric authentication',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Alternative authentication options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBiometricOption(
                icon: Icons.fingerprint_rounded,
                isSelected: true,
                onTap: _handleBiometricTap,
              ),
              SizedBox(width: 3.w),
              _buildBiometricOption(
                icon: Icons.face_rounded,
                isSelected: false,
                onTap: _handleBiometricTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(26)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 5.w,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withAlpha(153),
        ),
      ),
    );
  }
}
