import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/auth/service/auth_service.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final TextEditingController loginUserCtrl = TextEditingController();
  final TextEditingController loginPassCtrl = TextEditingController();

  final TextEditingController regUserCtrl = TextEditingController();
  final TextEditingController regEmailCtrl = TextEditingController();
  final TextEditingController regPassCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final userMap = await SharedPreferencesHelper.getUser();
    if (userMap != null) {
      currentUser.value = UserModel.fromJson(userMap);
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final user = await _authService.getMe();
      currentUser.value = user;
      await SharedPreferencesHelper.saveUser(user.toJson());
      return user;
    } catch (_) {
      return null;
    }
  }


  Future<void> register() async {
    final username = regUserCtrl.text.trim();
    final email = regEmailCtrl.text.trim();
    final password = regPassCtrl.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      await _authService.register(username, email, password);
      isLoading.value = false;
      
      Get.snackbar('Success', 'Registration successful! Please login.', snackPosition: SnackPosition.BOTTOM);
      regUserCtrl.clear();
      regEmailCtrl.clear();
      regPassCtrl.clear();
      Get.offNamed(AppRoutes.loginScreen);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Registration Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login() async {
    final usernameOrEmail = loginUserCtrl.text.trim();
    final password = loginPassCtrl.text.trim();

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter username and password', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final data = await _authService.login(usernameOrEmail, password);
      final String token = data['access_token'];

      await SharedPreferencesHelper.saveAccessToken(token);


      // Fetch full profile
      final user = await _authService.getMe();
      currentUser.value = user;
      await SharedPreferencesHelper.saveUser(user.toJson());

      isLoading.value = false;

      loginUserCtrl.clear();
      loginPassCtrl.clear();

      Get.offAllNamed(AppRoutes.userListScreen);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Login Failed', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await SharedPreferencesHelper.clearAll();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.loginScreen);
  }
}
