import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../core/navigation/app_router.dart';

/// Home screen - Main dashboard for Sentinel App
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sentinel Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                // TODO: Implement logout
                NavigationUtils.logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Guard',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Manage access control efficiently',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _StatusIndicator(
                          icon: Icons.wifi,
                          label: 'Online',
                          color: Colors.green,
                        ),
                        SizedBox(width: 16.w),
                        _StatusIndicator(
                          icon: Icons.sync,
                          label: 'Synced',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Action Buttons Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.2,
                  children: [
                    _FeatureTile(
                      title: 'RFID Scan',
                      icon: Icons.nfc,
                      color: AppColors.primary,
                      onTap: () => NavigationUtils.navigateToRfidScan(context),
                    ),
                    _FeatureTile(
                      title: 'Guest Search',
                      icon: Icons.person_search,
                      color: Colors.orange,
                      onTap: () => NavigationUtils.navigateToGuestSearch(context),
                    ),
                    _FeatureTile(
                      title: 'Delivery Entry',
                      icon: Icons.local_shipping,
                      color: Colors.purple,
                      onTap: () => NavigationUtils.navigateToDeliveryEntry(context),
                    ),
                    _FeatureTile(
                      title: 'Incident Report',
                      icon: Icons.report_problem,
                      color: Colors.red,
                      onTap: () => NavigationUtils.navigateToIncidentReport(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // More Options Row
              Row(
                children: [
                  Expanded(
                    child: _FeatureTile(
                      title: 'Village Rules',
                      icon: Icons.gavel,
                      color: Colors.teal,
                      onTap: () => NavigationUtils.navigateToVillageRules(context),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _FeatureTile(
                      title: 'Announcements',
                      icon: Icons.campaign,
                      color: Colors.indigo,
                      onTap: () => NavigationUtils.navigateToAnnouncements(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status indicator widget
class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Icon(
          icon,
          size: 16,
          color: AppColors.onPrimary.withOpacity(0.8),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onPrimary.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Feature tile widget
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}