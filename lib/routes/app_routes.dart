import 'package:flutter/material.dart';

import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/financial_dashboard/financial_dashboard_screen.dart';
import '../presentation/ipo_analysis_dashboard/ipo_analysis_dashboard.dart';
import '../presentation/ipo_listings/ipo_listings.dart';
import '../presentation/market_news_insights/market_news_insights.dart';
import '../presentation/portfolio_tracker/portfolio_tracker.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/user_profile/user_profile.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String splashScreen = '/splash-screen';
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String userProfile = '/user-profile';
  static const String financialDashboard = '/financial-dashboard';
  static const String ipoListings = '/ipo-listings';
  static const String ipoAnalysisDashboard = '/ipo-analysis-dashboard';
  static const String marketNewsInsights = '/market-news-insights';
  static const String portfolioTracker = '/portfolio-tracker';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    initial: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    userProfile: (context) => const UserProfile(),
    financialDashboard: (context) => const FinancialDashboardScreen(),
    ipoListings: (context) => const IPOListingsScreen(),
    ipoAnalysisDashboard: (context) => const IPOAnalysisDashboard(),
    marketNewsInsights: (context) => const MarketNewsInsights(),
    portfolioTracker: (context) => const PortfolioTrackerScreen(),
    // TODO: Add your other routes here
  };
}
