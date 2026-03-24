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
    final index = _routes.indexOf(currentRoute).clamp(0, _routes.length - 1);
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => context.push(_routes[i]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Dieta',
        ),
        NavigationDestination(
          icon: Icon(Icons.food_bank_outlined),
          label: 'Inventario',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_outlined),
          label: 'Extra',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_basket_outlined),
          label: 'Spesa',
        ),
      ],
    );
  }
}
