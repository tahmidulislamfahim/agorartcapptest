import 'package:get/get.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  UserModel? get currentUser => authController.currentUser.value;

  void logout() {
    authController.logout();
  }
}
