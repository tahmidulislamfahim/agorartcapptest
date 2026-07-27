import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.userListScreen);
    } else {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
