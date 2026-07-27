import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agorartcapptest/core/binding/controller_binder.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agora Realtime App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.bgDark,
        primaryColor: AppColor.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.bgDark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      initialBinding: ControllerBinder(),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
    );
  }
}
