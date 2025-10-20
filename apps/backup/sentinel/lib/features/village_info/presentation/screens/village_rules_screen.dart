import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Village Rules screen placeholder
class VillageRulesScreen extends StatelessWidget {
  const VillageRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Village Rules'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 80.w, color: Colors.teal),
            SizedBox(height: 16.h),
            Text(
              'Village Rules',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: 8.h),
            const Text(
              'View community rules and regulations',
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