import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';

class OutgoingCallScreen extends GetView<CallController> {
  const OutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final target = controller.targetUser.value;
    final callType = controller.activeCall.value?.callType ?? 'audio';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Calling ${target?.username ?? 'User'}...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Outgoing ${callType.toUpperCase()} Call',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Animated Pulsing Avatar
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.2),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primary.withValues(alpha: 0.2),
                            border: Border.all(
                              color: AppColor.primary.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColor.primary,
                            child: Text(
                              target != null && target.username.isNotEmpty
                                  ? target.username[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Cancel Call Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => controller.endCall(),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColor.accentReject,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.redAccent,
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: AppColor.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cancel Call',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
