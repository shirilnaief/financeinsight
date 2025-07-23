import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/app_info_widget.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/quick_access_buttons_widget.dart';
import './widgets/typewriter_tagline_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  bool _isLoading = true;
  bool _showBiometric = false;
  bool _showQuickAccess = false;
  bool _isConnected = true;
  int _loadingProgress = 0;
  String _loadingMessage = 'Initializing FinanceInsight...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeIn,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _startSplashSequence() async {
    try {
      // Start logo animation
      _logoAnimationController.forward();

      // Check connectivity
      await _checkConnectivity();

      // Simulate initialization steps with progress updates
      await _initializeApp();

      // Show biometric prompt for returning users
      await _checkBiometricAuth();

      // Wait minimum display time
      await Future.delayed(const Duration(seconds: 3));

      // Navigate to appropriate screen
      _navigateToNextScreen();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _initializeApp() async {
    final List<String> initSteps = [
      'Loading market data...',
      'Checking user preferences...',
      'Initializing security protocols...',
      'Preparing dashboard...',
    ];

    for (int i = 0; i < initSteps.length; i++) {
      setState(() {
        _loadingMessage = initSteps[i];
        _loadingProgress = ((i + 1) / initSteps.length * 100).round();
      });

      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() {
      _isLoading = false;
    });

    // Start content fade in
    _fadeAnimationController.forward();
  }

  Future<void> _checkBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isReturningUser = prefs.getBool('is_returning_user') ?? false;
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (isReturningUser && biometricEnabled) {
      setState(() {
        _showBiometric = true;
      });

      // Delay before showing quick access buttons
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _showQuickAccess = true;
      });
    } else {
      // Show quick access for new users
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _showQuickAccess = true;
      });
    }
  }

  void _handleError(String error) {
    setState(() {
      _hasError = true;
      _errorMessage = _isConnected
          ? 'Initialization failed. Please try again.'
          : 'No internet connection. Please check your network and retry.';
      _isLoading = false;
    });

    HapticFeedback.mediumImpact();
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isLoading = true;
      _loadingProgress = 0;
      _loadingMessage = 'Retrying initialization...';
    });

    _startSplashSequence();
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    String nextRoute;
    if (isFirstTime) {
      nextRoute = AppRoutes
          .financialDashboard; // For now, since onboarding isn't implemented
      await prefs.setBool('is_first_time', false);
    } else if (isAuthenticated) {
      nextRoute = AppRoutes.financialDashboard;
    } else {
      nextRoute = AppRoutes.financialDashboard; // Default to dashboard
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  void _handleGuestMode() {
    Navigator.pushReplacementNamed(context, AppRoutes.financialDashboard);
  }

  void _handleSignIn() {
    // For now, navigate to dashboard since auth isn't implemented
    Navigator.pushReplacementNamed(context, AppRoutes.financialDashboard);
  }

  void _handleBiometricAuth() async {
    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1000));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);

      _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _showBiometric = false;
        _showQuickAccess = true;
      });
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) => Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: const AnimatedLogoWidget(),
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Typewriter Tagline
                      AnimatedBuilder(
                        animation: _fadeAnimationController,
                        builder: (context, child) => Opacity(
                          opacity: _contentFadeAnimation.value,
                          child: const TypewriterTaglineWidget(),
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Loading Indicator or Error State
                      if (_isLoading)
                        LoadingIndicatorWidget(
                          progress: _loadingProgress,
                          message: _loadingMessage,
                        )
                      else if (_hasError)
                        _buildErrorState()
                      else
                        _buildInteractiveContent(),
                    ],
                  ),
                ),
              ),

              // App Info at bottom
              const AppInfoWidget(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 6.h,
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: 2.h),
        Text(
          _errorMessage,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),
        ElevatedButton.icon(
          onPressed: _retryInitialization,
          icon: const Icon(Icons.refresh),
          label: Text(
            'Retry',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveContent() {
    return AnimatedBuilder(
      animation: _fadeAnimationController,
      builder: (context, child) => Opacity(
        opacity: _contentFadeAnimation.value,
        child: Column(
          children: [
            // Biometric Prompt
            if (_showBiometric)
              BiometricPromptWidget(
                onAuthenticate: _handleBiometricAuth,
              ),

            if (_showBiometric) SizedBox(height: 3.h),

            // Quick Access Buttons
            if (_showQuickAccess)
              QuickAccessButtonsWidget(
                onGuestMode: _handleGuestMode,
                onSignIn: _handleSignIn,
              ),
          ],
        ),
      ),
    );
  }
}
