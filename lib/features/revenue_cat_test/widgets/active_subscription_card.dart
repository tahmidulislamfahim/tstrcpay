import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';
import '../controller/revenue_cat_controller.dart';

class ActiveSubscriptionCard extends GetView<RevenueCatController> {
  const ActiveSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeList = controller.activeEntitlementsDetails;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.successGreen, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColor.successGreen.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.successGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: AppColor.successGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Subscription',
                              style: AppTextStyle.getTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Purchased & Verified by RevenueCat',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.getTextStyle(
                                fontSize: 11,
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.successGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PRO ACTIVE',
                    style: AppTextStyle.getTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColor.bgDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColor.cardBorder),
            const SizedBox(height: 12),

            // Active Entitlement Details List
            ...activeList.map((entitlement) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entitlement: ${entitlement.identifier.toUpperCase()}',
                          style: AppTextStyle.getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.accentPurpleLight,
                          ),
                        ),
                        Text(
                          entitlement.willRenew
                              ? 'Auto-Renewing'
                              : 'One-Time / Expiring',
                          style: AppTextStyle.getTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: entitlement.willRenew
                                ? AppColor.successGreen
                                : AppColor.warningAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      'Product ID',
                      entitlement.productIdentifier,
                    ),
                    _buildDetailRow(
                      'Purchase Date',
                      _formatDate(entitlement.latestPurchaseDate),
                    ),
                    if (entitlement.expirationDate != null)
                      _buildDetailRow(
                        'Expiration Date',
                        _formatDate(entitlement.expirationDate!),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            // Actions: Restore / Refresh
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.restorePurchases(),
                    icon: const Icon(Icons.restore, size: 16),
                    label: Text(
                      'Re-verify Purchase',
                      style: AppTextStyle.getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.white,
                      side: const BorderSide(color: AppColor.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.getTextStyle(
              fontSize: 11,
              color: AppColor.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.getTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
