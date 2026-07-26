import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';
import '../controller/revenue_cat_controller.dart';

class StatusCard extends GetView<RevenueCatController> {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColor.accentPurpleLight, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'RevenueCat SDK Status',
                        style: AppTextStyle.getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final isInit = controller.isInitialized.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isInit
                        ? AppColor.successGreen.withValues(alpha: 0.15)
                        : AppColor.warningAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isInit ? AppColor.successGreen : AppColor.warningAmber,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: isInit ? AppColor.successGreen : AppColor.warningAmber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isInit ? 'CONNECTED' : 'DISCONNECTED',
                        style: AppTextStyle.getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isInit ? AppColor.successGreen : AppColor.warningAmber,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // API Key Input & Action
          Text(
            'API Key Configuration',
            style: AppTextStyle.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.apiKeyController,
                  style: AppTextStyle.getTextStyle(
                    fontSize: 13,
                    color: AppColor.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColor.bgDark,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    hintText: 'Enter RevenueCat API key',
                    hintStyle: AppTextStyle.getTextStyle(
                      fontSize: 13,
                      color: AppColor.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.accentPurple),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.initializeSdk(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.accentPurple,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: Text(
                  'Re-Init',
                  style: AppTextStyle.getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Active Entitlements Metric Row
          Obx(() {
            final activeCount = controller.activeEntitlements.length;
            final entitlements = controller.activeEntitlements;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.accentPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppColor.accentPurpleLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Entitlements ($activeCount)',
                          style: AppTextStyle.getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeCount == 0 ? 'No active entitlements' : entitlements.join(', '),
                          style: AppTextStyle.getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: activeCount > 0 ? AppColor.successGreen : AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
