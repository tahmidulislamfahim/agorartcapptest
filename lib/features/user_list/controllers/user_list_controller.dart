import 'dart:async';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/user_list/service/user_list_service.dart';

class UserListController extends GetxController {
  final UserListService _userListService = UserListService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchUsers({bool showLoading = true}) async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      if (showLoading) isLoading.value = true;
      final fetched = await _userListService.getUsers();
      final myId = _authController.currentUser.value?.id;
      // Filter out self from list
      final otherUsers = fetched.where((u) => u.id != myId).toList();
      users.assignAll(otherUsers);
    } catch (_) {
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }
}
