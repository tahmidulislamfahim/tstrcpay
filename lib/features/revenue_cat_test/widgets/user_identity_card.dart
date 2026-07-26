import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';
import '../controller/revenue_cat_controller.dart';

class UserIdentityCard extends GetView<RevenueCatController> {
  const UserIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoggedIn = controller.isLoggedIn.value;
      final currentUserId = controller.appUserId.value;

      if (!isLoggedIn) {
        // Step 1: Customer Login Card
        return Container(
          decoration: BoxDecoration(
            color: AppColor.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.accentCyan.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColor.accentCyan.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.accentCyan.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_outlined, color: AppColor.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Login Required',
                        style: AppTextStyle.getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.white,
                        ),
                      ),
                      Text(
                        'Enter your Customer ID to access subscriptions',
                        style: AppTextStyle.getTextStyle(
                          fontSize: 12,
                          color: AppColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.customUserIdController,
                style: AppTextStyle.getTextStyle(
                  fontSize: 14,
                  color: AppColor.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColor.bgDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: 'Enter Customer ID (e.g. user_101 or john_doe)',
                  hintStyle: AppTextStyle.getTextStyle(
                    fontSize: 13,
                    color: AppColor.secondaryTextColor,
                  ),
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColor.secondaryTextColor, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColor.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColor.accentCyan, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => controller.logInUser(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.logInUser(),
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(
                    'Log In & View Subscriptions',
                    style: AppTextStyle.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.bgDark,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.accentCyan,
                    foregroundColor: AppColor.bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Step 2: Logged In Customer Header Card
      return Container(
        decoration: BoxDecoration(
          color: AppColor.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.cardBorder, width: 1),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.successGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user, color: AppColor.successGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Customer Account',
                    style: AppTextStyle.getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentUserId,
                    style: AppTextStyle.getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.logOutUser(),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Switch'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.errorRed,
                side: const BorderSide(color: AppColor.errorRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
      );
    });
  }
}
