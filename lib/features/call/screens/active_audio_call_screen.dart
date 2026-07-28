import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';

class ActiveAudioCallScreen extends GetView<CallController> {
  const ActiveAudioCallScreen({super.key});

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Obx(
                    () => Text(
                      controller.targetUser.value?.username ?? 'Connected User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _formatDuration(controller.callDurationSeconds.value),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Live connection status badge
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.connectionStatus.value,
                      style: TextStyle(
                        fontSize: 11,
                        color: controller.connectionStatus.value.startsWith('In call')
                            ? AppColor.accentCall
                            : controller.connectionStatus.value.contains('Error') || controller.connectionStatus.value.contains('Failed')
                                ? AppColor.accentReject
                                : AppColor.secondary,
                      ),
                    ),
                  )),
                ],
              ),

              // Audio Wave Avatar Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primary.withOpacity(0.2),
                  border: Border.all(color: AppColor.primary, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColor.primary,
                  child: Icon(Icons.mic_rounded, size: 54, color: AppColor.white),
                ),
              ),

              // Control Bar: Mute, Speaker, End Call
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Toggle Mute
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        controller.isMuted.value ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: controller.isMuted.value ? AppColor.accentReject : AppColor.white,
                      ),
                      onPressed: () => controller.toggleMute(),
                    ),

                    // End Call
                    GestureDetector(
                      onTap: () => controller.endCall(),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: AppColor.accentReject,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end_rounded, color: AppColor.white, size: 32),
                      ),
                    ),

                    // Toggle Speaker
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        controller.isSpeakerOn.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: controller.isSpeakerOn.value ? AppColor.secondary : AppColor.white,
                      ),
                      onPressed: () => controller.toggleSpeaker(),
                    ),
                  ],
                ),
              ),
              // Agora Debug Log (tap to expand)
              Obx(() {
                final logs = controller.agoraLog;
                if (logs.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (_, i) => Text(
                      logs[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: logs[i].contains('ERROR') || logs[i].contains('EXCEPTION')
                            ? AppColor.redAccent
                            : logs[i].contains('✅')
                                ? AppColor.greenAccent
                                : AppColor.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
