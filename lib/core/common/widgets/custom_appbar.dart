import 'package:flutter/material.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.cardBg,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      iconTheme: const IconThemeData(color: AppColor.textMain),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColor.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
