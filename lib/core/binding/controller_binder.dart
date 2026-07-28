import 'package:get/get.dart';
import 'package:agorartcapptest/features/splash/controllers/splash_controller.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/profile/controllers/profile_controller.dart';
import 'package:agorartcapptest/features/user_list/controllers/user_list_controller.dart';
import 'package:agorartcapptest/features/chat/controllers/chat_controller.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';
import 'package:agorartcapptest/features/notification/controllers/notification_controller.dart';

import 'package:agorartcapptest/core/services/rtm_service/rtm_service.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put(RtmService(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(CallController(), permanent: true);
    Get.put(NotificationController(), permanent: true);

    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<UserListController>(() => UserListController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}
