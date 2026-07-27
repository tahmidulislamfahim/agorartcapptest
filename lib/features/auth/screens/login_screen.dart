import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/common/widgets/custom_button.dart';
import 'package:agorartcapptest/core/common/widgets/custom_textfield.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: AppStyle.glassDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: AppColor.secondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log in to access your Agora Call & Chat account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: controller.loginUserCtrl,
                      hintText: 'Username or Email',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.loginPassCtrl,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => CustomButton(
                        text: 'Log In',
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.login(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppColor.textMuted),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.registerScreen),
                          child: const Text(
                            'Register Now',
                            style: TextStyle(
                              color: AppColor.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
