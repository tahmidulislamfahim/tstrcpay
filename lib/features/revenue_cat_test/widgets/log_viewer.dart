import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/style/global_text_style.dart';
import '../../../core/constants/app_color.dart';
import '../controller/revenue_cat_controller.dart';

class LogViewer extends GetView<RevenueCatController> {
  const LogViewer({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal, color: AppColor.accentPurpleLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Activity & Trace Logs',
                    style: AppTextStyle.getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => controller.clearLogs(),
                icon: const Icon(Icons.delete_outline, color: AppColor.secondaryTextColor, size: 20),
                tooltip: 'Clear Logs',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final logs = controller.logs;
            if (logs.isEmpty) {
              return Container(
                height: 100,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.cardBorder),
                ),
                child: Text(
                  'No log entries yet. Perform actions to see traces.',
                  style: AppTextStyle.getTextStyle(
                    fontSize: 12,
                    color: AppColor.secondaryTextColor,
                  ),
                ),
              );
            }

            return Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.bgDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.cardBorder),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final isError = log.contains('[ERROR]');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      log,
                      style: AppTextStyle.getTextStyle(
                        fontSize: 11,
                        color: isError ? AppColor.errorRed : AppColor.accentPurpleLight,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
