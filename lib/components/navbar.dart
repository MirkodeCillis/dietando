import 'package:dietando/l10n/app_localizations.dart';
import 'package:dietando/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentRoute});

  final String currentRoute;

  static const _routes = [
    AppRoutes.mealPlan,
    AppRoutes.inventory,
    AppRoutes.extra,
    AppRoutes.shopping,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final index = _routes.indexOf(currentRoute).clamp(0, _routes.length - 1);
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => context.push(_routes[i]),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          label: l10n.navDiet,
        ),
        NavigationDestination(
          icon: const Icon(Icons.food_bank_outlined),
          label: l10n.navInventory,
        ),
        NavigationDestination(
          icon: const Icon(Icons.checklist_outlined),
          label: l10n.navExtra,
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_basket_outlined),
          label: l10n.navShopping,
        ),
      ],
    );
  }
}
