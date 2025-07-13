import 'package:flutter/material.dart';

import '../presentation/financial_dashboard/financial_dashboard_screen.dart';
import '../presentation/ipo_listings/ipo_listings.dart';
import '../presentation/user_profile/user_profile.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String userProfile = '/user-profile';
  static const String financialDashboard = '/financial-dashboard';
  static const String ipoListings = '/ipo-listings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const FinancialDashboardScreen(),
    userProfile: (context) => const UserProfile(),
    financialDashboard: (context) => const FinancialDashboardScreen(),
    ipoListings: (context) => const IPOListingsScreen(),
    // TODO: Add your other routes here
  };
}
