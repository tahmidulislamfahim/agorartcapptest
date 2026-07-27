import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';

class ActiveVideoCallScreen extends GetView<CallController> {
  const ActiveVideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Remote Video View (Full Screen)
            Obx(() {
              final engine = controller.rtcEngine;
              final call = controller.activeCall.value;
              final myId = Get.find<AuthController>().currentUser.value?.id;
              final fallbackRemoteId = call != null
                  ? (call.callerId == myId ? call.receiverId : call.callerId)
                  : null;
              final remoteUid = controller.remoteUid.value ?? fallbackRemoteId;

              if (remoteUid != null && remoteUid > 0 && engine != null && call != null) {
                return AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: engine,
                    canvas: VideoCanvas(
                      uid: remoteUid,
                      renderMode: RenderModeType.renderModeHidden,
                    ),
                    connection: RtcConnection(channelId: call.channelName),
                    useAndroidSurfaceView: true,
                  ),
                );

              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColor.primary),
                    const SizedBox(height: 16),
                    Obx(() => Text(
                      controller.connectionStatus.value,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    )),
                  ],
                ),
              );
            }),

            // Live Agora debug log overlay (bottom-left)
            Positioned(
              bottom: 110,
              left: 10,
              right: 10,
              child: Obx(() {
                final logs = controller.agoraLog;
                if (logs.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 80,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (_, i) => Text(
                      logs[i],
                      style: TextStyle(
                        fontSize: 9,
                        color: logs[i].contains('ERROR') || logs[i].contains('EXCEPTION')
                            ? Colors.redAccent
                            : logs[i].contains('✅')
                                ? Colors.greenAccent
                                : Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                );
              }),
            ),

            // 2. Local Video View (Picture-in-Picture Top Right Window)
            Positioned(
              top: 20,
              right: 20,
              child: Obx(() {
                final engine = controller.rtcEngine;
                if (engine == null || controller.isVideoDisabled.value) {
                  return Container(
                    width: 110,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.cardBorder),
                    ),
                    child: const Icon(Icons.videocam_off, color: Colors.white54, size: 32),
                  );
                }
                return Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.primary, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: engine,
                      canvas: const VideoCanvas(
                        uid: 0,
                        renderMode: RenderModeType.renderModeHidden,
                        sourceType: VideoSourceType.videoSourceCamera,
                      ),
                      useAndroidSurfaceView: true,
                    ),
                  ),
                );
              }),
            ),

            // 3. Floating Control Bar (Mute Mic, Switch Camera, Toggle Video, End Call)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColor.cardBorder),
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute Microphone
                      IconButton(
                        onPressed: controller.toggleMute,
                        icon: Icon(
                          controller.isMuted.value ? Icons.mic_off : Icons.mic,
                          color: controller.isMuted.value ? AppColor.accentReject : Colors.white,
                          size: 26,
                        ),
                      ),
                      // Switch Front / Rear Camera
                      IconButton(
                        onPressed: controller.switchCamera,
                        icon: const Icon(
                          Icons.cameraswitch_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      // Toggle Video On / Off
                      IconButton(
                        onPressed: controller.toggleVideo,
                        icon: Icon(
                          controller.isVideoDisabled.value ? Icons.videocam_off : Icons.videocam,
                          color: controller.isVideoDisabled.value ? AppColor.accentReject : Colors.white,
                          size: 26,
                        ),
                      ),
                      // End Call Button
                      InkWell(
                        onTap: controller.endCall,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColor.accentReject,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
