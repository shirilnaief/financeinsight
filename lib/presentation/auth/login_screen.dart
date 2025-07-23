import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text);

      if (result.isSuccess) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.financialDashboard);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Login failed'),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              
              // Logo and Title
              Column(
                children: [
                  Container(
                    height: 12.h,
                    width: 12.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                      ]),
                    child: CustomIconWidget(
                      iconName: 'finance',
                      size: 6.h,
                      color: Colors.white)),
                  SizedBox(height: 3.h),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor)),
                  SizedBox(height: 1.h),
                  Text(
                    'Sign in to your account to continue',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.subTextColor)),
                ]),
              
              SizedBox(height: 6.h),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.inter(color: AppTheme.subTextColor),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor)),
                        filled: true,
                        fillColor: AppTheme.inputBackgroundColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      }),
                    
                    SizedBox(height: 2.h),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.textColor),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.inter(color: AppTheme.subTextColor),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          }),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor)),
                        filled: true,
                        fillColor: AppTheme.inputBackgroundColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      }),
                    
                    SizedBox(height: 1.h),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500)))),
                    
                    SizedBox(height: 3.h),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          elevation: 2),
                        child: _isLoading
                            ? SizedBox(
                                height: 2.5.h,
                                width: 2.5.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)))),
                  ])),
              
              SizedBox(height: 4.h),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don\'t have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.subTextColor)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600))),
                ]),
              
              SizedBox(height: 4.h),
              
              // Demo Account Info
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor)),
                child: Column(
                  children: [
                    Text(
                      'Demo Account',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor)),
                    SizedBox(height: 1.h),
                    Text(
                      'Email: user@financeinsight.com\nPassword: user123',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppTheme.subTextColor)),
                  ])),
            ]))));
  }
}