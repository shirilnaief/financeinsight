import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/app_info_widget.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/quick_access_buttons_widget.dart';
import './widgets/typewriter_tagline_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  final _authService = AuthService();

  bool _showContent = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    _contentController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _logoController.forward().then((_) {
      setState(() => _showContent = true);
      _contentController.forward();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      setState(() => _isCheckingAuth = false);

      // Check if user is already authenticated
      if (_authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.financialDashboard);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, AppRoutes.financialDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBackgroundWidget(
            child: SafeArea(
                child: Column(children: [
      Expanded(
          flex: 5,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Animated Logo
            AnimatedLogoWidget(),

            SizedBox(height: 4.h),

            // App Info
            const AppInfoWidget(),

            SizedBox(height: 2.h),

            // Typewriter Tagline
            if (_showContent) TypewriterTaglineWidget(),
          ])),

      // Bottom Section
      Expanded(
          flex: 2,
          child: Column(children: [
            // Loading or Auth Buttons
            if (_isCheckingAuth) ...[
              const LoadingIndicatorWidget(
                message: 'Initializing...',
                progress: null,
              ),
              SizedBox(height: 2.h),
              Text('Initializing...'),
            ] else if (!_authService.isAuthenticated) ...[
              // Quick Access Buttons for non-authenticated users
              QuickAccessButtonsWidget(
                onSignIn: _navigateToLogin,
                onGuestMode: _navigateToDashboard,
              ),

              SizedBox(height: 2.h),

              // Biometric Prompt (if available)
              BiometricPromptWidget(
                onAuthenticate: _navigateToDashboard,
              ),
            ],

            const Spacer(),

            // Copyright
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('© 2025 FinanceInsight. All rights reserved.',
                    textAlign: TextAlign.center)),

            SizedBox(height: 2.h),
          ])),
    ]))));
  }
}