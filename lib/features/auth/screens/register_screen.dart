import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/common/widgets/custom_button.dart';
import 'package:agorartcapptest/core/common/widgets/custom_textfield.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

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
                      Icons.person_add_outlined,
                      size: 48,
                      color: AppColor.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to make audio/video calls and chat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: controller.regUserCtrl,
                      hintText: 'Username',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.regEmailCtrl,
                      hintText: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.regPassCtrl,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => CustomButton(
                        text: 'Register Account',
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.register(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColor.textMuted),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.loginScreen),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColor.primary,
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
