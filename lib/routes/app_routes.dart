import 'package:flutter/material.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/financial_dashboard/financial_dashboard_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String userProfile = '/user-profile';
  static const String financialDashboard = '/financial-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const FinancialDashboardScreen(),
    userProfile: (context) => const UserProfile(),
    financialDashboard: (context) => const FinancialDashboardScreen(),
    // TODO: Add your other routes here
  };
}
