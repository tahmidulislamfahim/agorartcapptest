import 'package:get/get.dart';
import 'package:agorartcapptest/features/splash/screens/splash_screen.dart';
import 'package:agorartcapptest/features/auth/screens/login_screen.dart';
import 'package:agorartcapptest/features/auth/screens/register_screen.dart';
import 'package:agorartcapptest/features/profile/screens/profile_screen.dart';
import 'package:agorartcapptest/features/user_list/screens/user_list_screen.dart';
import 'package:agorartcapptest/features/chat/screens/chat_screen.dart';
import 'package:agorartcapptest/features/call/screens/outgoing_call_screen.dart';
import 'package:agorartcapptest/features/call/screens/active_audio_call_screen.dart';
import 'package:agorartcapptest/features/call/screens/active_video_call_screen.dart';
import 'package:agorartcapptest/features/notification/screens/notification_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String profileScreen = '/profile';
  static const String userListScreen = '/user_list';
  static const String chatScreen = '/chat';
  static const String outgoingCallScreen = '/outgoing_call';
  static const String activeAudioCallScreen = '/active_audio_call';
  static const String activeVideoCallScreen = '/active_video_call';
  static const String notificationScreen = '/notification';

  static final List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: registerScreen, page: () => const RegisterScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: userListScreen, page: () => const UserListScreen()),
    GetPage(name: chatScreen, page: () => const ChatScreen()),
    GetPage(name: outgoingCallScreen, page: () => const OutgoingCallScreen()),
    GetPage(name: activeAudioCallScreen, page: () => const ActiveAudioCallScreen()),
    GetPage(name: activeVideoCallScreen, page: () => const ActiveVideoCallScreen()),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),
  ];
}
