import 'package:dietando/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: context.canPop() ? BackButton(
        onPressed: () => context.pop(),
      ) : null,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 2,
      actions: [
        if (GoRouterState.of(context).matchedLocation != AppRoutes.settings)
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
      ],
    );
  }
}
