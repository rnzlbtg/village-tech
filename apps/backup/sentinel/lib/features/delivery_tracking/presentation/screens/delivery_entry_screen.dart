import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Delivery Entry screen placeholder
class DeliveryEntryScreen extends StatelessWidget {
  const DeliveryEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Entry'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 80.w, color: Colors.purple),
            SizedBox(height: 16.h),
            Text(
              'Delivery Tracking',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: 8.h),
            const Text(
              'Log and track deliveries',
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