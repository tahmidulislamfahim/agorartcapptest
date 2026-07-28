import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';

class IncomingCallDialog extends StatelessWidget {
  final CallModel callData;

  const IncomingCallDialog({super.key, required this.callData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallController>();

    return Dialog(
      backgroundColor: AppColor.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyle.glassDecoration(
          bgColor: AppColor.bgDark,
          borderColor: AppColor.primary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ring_volume_rounded, color: AppColor.secondary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Incoming ${callData.callType.toUpperCase()} Call',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.white),
            ),
            const SizedBox(height: 8),
            Text(
              '${callData.callerUsername} is calling you...',
              style: const TextStyle(color: AppColor.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.rejectCall(callData.id);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColor.accentReject,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end_rounded, color: AppColor.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      const Text('Decline', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                    ],
                  ),
                ),

                // Accept Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.acceptCall(callData);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColor.accentCall,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_rounded, color: AppColor.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      const Text('Accept', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
