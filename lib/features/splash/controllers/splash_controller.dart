import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final token = await SharedPreferencesHelper.getAccessToken();
    debugPrint("SplashController: Token: $token");
    if (token != null && token.isNotEmpty) {
      if (Get.isRegistered<AuthController>()) {
        try {
          await Get.find<AuthController>().getMe();
        } catch (_) {}
      }
      Get.offAllNamed(AppRoutes.userListScreen);
    } else {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
