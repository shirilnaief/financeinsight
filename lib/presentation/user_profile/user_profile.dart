import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/toggle_settings_item_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool biometricEnabled = true;
  bool twoFactorEnabled = false;
  bool dataSyncEnabled = true;
  double alertThreshold = 0.7;
  String selectedCurrency = 'USD';

  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];

  final List<Map<String, dynamic>> activeSessions = [
    {
      "device": "iPhone 14 Pro",
      "location": "New York, NY",
      "lastActive": "Active now",
      "isCurrent": true,
    },
    {
      "device": "MacBook Pro",
      "location": "New York, NY",
      "lastActive": "2 hours ago",
      "isCurrent": false,
    },
    {
      "device": "iPad Air",
      "location": "Boston, MA",
      "lastActive": "1 day ago",
      "isCurrent": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ProfileHeaderWidget(),
              SizedBox(height: 3.h),

              // Account Section
              SettingsSectionWidget(
                title: 'Account',
                children: [
                  SettingsItemWidget(
                    icon: 'edit',
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _showEditProfileDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'lock',
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  ToggleSettingsItemWidget(
                    icon: 'fingerprint',
                    title: 'Biometric Settings',
                    subtitle: 'Use fingerprint or face ID',
                    value: biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        biometricEnabled = value;
                      });
                      _showSuccessSnackBar('Biometric settings updated');
                    },
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Preferences Section
              SettingsSectionWidget(
                title: 'Preferences',
                children: [
                  SettingsItemWidget(
                    icon: 'notifications',
                    title: 'Alert Thresholds',
                    subtitle: 'Risk level: ${(alertThreshold * 100).toInt()}%',
                    trailing: SizedBox(
                      width: 30.w,
                      child: Slider(
                        value: alertThreshold,
                        onChanged: (value) {
                          setState(() {
                            alertThreshold = value;
                          });
                        },
                        activeColor: AppTheme.lightTheme.colorScheme.primary,
                        inactiveColor: AppTheme.getAccentColor(true),
                      ),
                    ),
                    onTap: null,
                  ),
                  SettingsItemWidget(
                    icon: 'attach_money',
                    title: 'Currency Display',
                    subtitle: selectedCurrency,
                    trailing: DropdownButton<String>(
                      value: selectedCurrency,
                      underline: Container(),
                      items: currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCurrency = newValue;
                          });
                          _showSuccessSnackBar('Currency updated to $newValue');
                        }
                      },
                    ),
                    onTap: null,
                  ),
                  ToggleSettingsItemWidget(
                    icon: 'cloud_sync',
                    title: 'Data Sync Settings',
                    subtitle:
                        dataSyncEnabled ? 'Cloud sync enabled' : 'Offline only',
                    value: dataSyncEnabled,
                    onChanged: (value) {
                      setState(() {
                        dataSyncEnabled = value;
                      });
                      _showSuccessSnackBar(
                          value ? 'Cloud sync enabled' : 'Cloud sync disabled');
                    },
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // App Settings Section
              SettingsSectionWidget(
                title: 'App Settings',
                children: [
                  SettingsItemWidget(
                    icon: 'storage',
                    title: 'Offline Storage Management',
                    subtitle: '2.3 GB used of 5.0 GB available',
                    onTap: () => _showStorageDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'file_download',
                    title: 'Export Data',
                    subtitle: 'Download your financial insights',
                    onTap: () => _showExportDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'clear_all',
                    title: 'Clear Cache',
                    subtitle: 'Free up 156 MB of storage',
                    onTap: () => _showClearCacheDialog(),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Security Section
              SettingsSectionWidget(
                title: 'Security',
                children: [
                  SettingsItemWidget(
                    icon: 'devices',
                    title: 'Active Sessions',
                    subtitle: '${activeSessions.length} devices connected',
                    onTap: () => _showActiveSessionsDialog(),
                  ),
                  ToggleSettingsItemWidget(
                    icon: 'security',
                    title: 'Two-Factor Authentication',
                    subtitle: twoFactorEnabled ? 'Enabled' : 'Disabled',
                    value: twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        twoFactorEnabled = value;
                      });
                      _showSuccessSnackBar(
                          value ? '2FA enabled' : '2FA disabled');
                    },
                  ),
                  SettingsItemWidget(
                    icon: 'privacy_tip',
                    title: 'Privacy Settings',
                    subtitle: 'Manage your data privacy',
                    onTap: () => _showPrivacyDialog(),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Support Section
              SettingsSectionWidget(
                title: 'Support',
                children: [
                  SettingsItemWidget(
                    icon: 'help_center',
                    title: 'Help Center',
                    subtitle: 'FAQs and tutorials',
                    onTap: () => _showHelpDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'contact_support',
                    title: 'Contact Support',
                    subtitle: 'Get help from our team',
                    onTap: () => _showContactDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'star_rate',
                    title: 'Rate App',
                    subtitle: 'Share your feedback',
                    onTap: () => _showRateDialog(),
                  ),
                  SettingsItemWidget(
                    icon: 'gavel',
                    title: 'Legal Documents',
                    subtitle: 'Terms, privacy policy & licenses',
                    onTap: () => _showLegalDialog(),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              LogoutButtonWidget(
                onTap: () => _showLogoutDialog(),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Profile',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Profile updated successfully');
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Change Password',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Password changed successfully');
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Storage Management',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage Usage:',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              LinearProgressIndicator(
                value: 0.46,
                backgroundColor: AppTheme.getAccentColor(true),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '2.3 GB used of 5.0 GB available',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Documents: 1.8 GB\nCache: 0.3 GB\nSettings: 0.2 GB',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Storage optimized');
              },
              child: Text('Optimize'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Data',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Export your financial insights and analysis data. This will create a downloadable file with all your processed documents and insights.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Export started - check downloads');
              },
              child: Text('Export'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Cache',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'This will clear 156 MB of cached data. Your documents and settings will not be affected.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Cache cleared successfully');
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Active Sessions',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activeSessions.length,
              itemBuilder: (context, index) {
                final session = activeSessions[index];
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: session['isCurrent'] ? 'smartphone' : 'devices',
                    color: session['isCurrent']
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                  title: Text(
                    session['device'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${session['location']} • ${session['lastActive']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  trailing: session['isCurrent']
                      ? Chip(
                          label: Text(
                            'Current',
                            style: TextStyle(
                              color: AppTheme.getSuccessColor(true),
                              fontSize: 10.sp,
                            ),
                          ),
                          backgroundColor: AppTheme.getSuccessColor(true)
                              .withValues(alpha: 0.1),
                        )
                      : IconButton(
                          icon: CustomIconWidget(
                            iconName: 'logout',
                            color: AppTheme.getErrorColor(true),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              activeSessions.removeAt(index);
                            });
                            Navigator.of(context).pop();
                            _showSuccessSnackBar('Session terminated');
                          },
                        ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Settings',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Manage how your data is collected and used. You can control analytics, crash reporting, and data sharing preferences.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Privacy settings updated');
              },
              child: Text('Manage'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Help Center',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Access our comprehensive help center with tutorials, FAQs, and guides for using FinanceInsight effectively.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Opening help center...');
              },
              child: Text('Open'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Support',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get help from our support team:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Email: support@financeinsight.com\nPhone: +1 (555) 123-4567\nLive Chat: Available 24/7',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Opening support chat...');
              },
              child: Text('Chat Now'),
            ),
          ],
        );
      },
    );
  }

  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Rate FinanceInsight',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Enjoying FinanceInsight? Please take a moment to rate us on the App Store. Your feedback helps us improve!',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Opening App Store...');
              },
              child: Text('Rate Now'),
            ),
          ],
        );
      },
    );
  }

  void _showLegalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Legal Documents',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Terms of Service'),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
                onTap: () {},
              ),
              ListTile(
                title: Text('Privacy Policy'),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
                onTap: () {},
              ),
              ListTile(
                title: Text('Open Source Licenses'),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
                onTap: () {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getErrorColor(true),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Logged out successfully');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
