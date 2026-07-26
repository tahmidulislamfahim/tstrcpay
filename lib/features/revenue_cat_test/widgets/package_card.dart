import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onBuy;

  const PackageCard({
    super.key,
    required this.package,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.bgDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Package Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.accentPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  package.packageType.name.toUpperCase(),
                  style: AppTextStyle.getTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.accentPurpleLight,
                  ),
                ),
              ),
              // Price tag
              Text(
                product.priceString,
                style: AppTextStyle.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColor.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Description
          Text(
            product.title.isNotEmpty ? product.title : package.identifier,
            style: AppTextStyle.getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColor.white,
            ),
          ),
          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              product.description,
              style: AppTextStyle.getTextStyle(
                fontSize: 12,
                color: AppColor.secondaryTextColor,
              ),
            ),
          ],
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, size: 14, color: AppColor.secondaryTextColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ID: ${product.identifier}',
                  style: AppTextStyle.getTextStyle(
                    fontSize: 11,
                    color: AppColor.secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Buy Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBuy,
              icon: const Icon(Icons.shopping_cart_checkout, size: 16),
              label: Text(
                'Buy Package (${product.priceString})',
                style: AppTextStyle.getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColor.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryBlue,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
