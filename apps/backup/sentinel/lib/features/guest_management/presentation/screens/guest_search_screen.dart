import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Guest Search screen placeholder
class GuestSearchScreen extends StatelessWidget {
  const GuestSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guest Search'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 80.w, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              'Guest Management',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: 8.h),
            const Text(
              'Search and manage guest entries',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}