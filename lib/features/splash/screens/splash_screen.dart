import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/splash/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Touch controller to trigger Get.lazyPut instantiation
    controller.onInit;


    return Scaffold(
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primary.withOpacity(0.2),
                  border: Border.all(color: AppColor.primary, width: 2),
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  size: 48,
                  color: AppColor.secondary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Agora Realtime App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Audio, Video, Chat & Notifications',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.textMuted,
                ),
              ),
              const SizedBox(height: 48),
              const SpinKitFadingCircle(
                color: AppColor.primary,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
