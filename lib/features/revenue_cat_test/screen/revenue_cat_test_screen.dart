import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';
import '../controller/revenue_cat_controller.dart';
import '../widgets/active_subscription_card.dart';
import '../widgets/log_viewer.dart';
import '../widgets/package_card.dart';
import '../widgets/status_card.dart';
import '../widgets/user_identity_card.dart';

class RevenueCatTestScreen extends GetView<RevenueCatController> {
  const RevenueCatTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgDark,
      appBar: AppBar(
        backgroundColor: AppColor.cardDark,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.accentPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColor.accentPurpleLight, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'RevenueCat Tester',
              style: AppTextStyle.getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh, color: AppColor.white),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status & API Key Configuration Card
              const StatusCard(),
              const SizedBox(height: 16),

              // 2. User Identity Card (Step 1: Login / Step 2: Customer Header)
              const UserIdentityCard(),
              const SizedBox(height: 16),

              // Conditional Section based on Customer Login & Subscription state
              Obx(() {
                final isLoggedIn = controller.isLoggedIn.value;
                final hasActiveSub = controller.hasActiveSubscription;

                if (!isLoggedIn) {
                  // Not logged in view
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColor.cardBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColor.warningAmber, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'Subscriptions Locked',
                          style: AppTextStyle.getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please enter your Customer ID above to view your active purchases or buy a subscription.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.getTextStyle(
                            fontSize: 12,
                            color: AppColor.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Logged In Customer View
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasActiveSub) ...[
                      // CASE A: Customer HAS an active subscription -> Show active purchased subscription ONLY
                      const ActiveSubscriptionCard(),
                      const SizedBox(height: 20),
                    ] else ...[
                      // CASE B: Customer does NOT have an active subscription -> Show Paywall / Offerings Catalog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No Active Subscription',
                            style: AppTextStyle.getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => controller.restorePurchases(),
                            icon: const Icon(Icons.restore, size: 16),
                            label: const Text('Restore Purchases'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.cardDark,
                              foregroundColor: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AppColor.cardBorder),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Offerings & Packages Catalog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Offerings Catalog',
                            style: AppTextStyle.getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColor.white,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => controller.fetchOfferings(),
                            icon: const Icon(Icons.download, size: 16, color: AppColor.accentPurpleLight),
                            label: Text(
                              'Fetch Offerings',
                              style: AppTextStyle.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.accentPurpleLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Obx(() {
                        final offering = controller.currentOffering.value;
                        if (offering == null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColor.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColor.cardBorder),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inventory_2_outlined, color: AppColor.secondaryTextColor, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'No Current Offering Available',
                                  style: AppTextStyle.getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ensure packages & offerings are configured in your RevenueCat dashboard for this key.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.getTextStyle(
                                    fontSize: 12,
                                    color: AppColor.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final packages = offering.availablePackages;
                        if (packages.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColor.cardBorder),
                            ),
                            child: Text(
                              'Offering "${offering.identifier}" contains 0 packages.',
                              style: AppTextStyle.getTextStyle(
                                fontSize: 13,
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Current Offering: ${offering.identifier}',
                                style: AppTextStyle.getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.accentPurpleLight,
                                ),
                              ),
                            ),
                            ...packages.map((package) => PackageCard(
                                  package: package,
                                  onBuy: () => controller.buyPackage(package),
                                )),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Customer Info Summary Card
                    Text(
                      'Customer Info Summary',
                      style: AppTextStyle.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final summary = controller.rawCustomerInfoSummary.value;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.cardBorder),
                        ),
                        child: Text(
                          summary.isNotEmpty ? summary : 'Customer info pending fetch...',
                          style: AppTextStyle.getTextStyle(
                            fontSize: 12,
                            color: AppColor.white,
                            height: 1.4,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // Console & Trace Log Viewer
              const LogViewer(),
            ],
          ),
        ),
      ),
    );
  }
}
