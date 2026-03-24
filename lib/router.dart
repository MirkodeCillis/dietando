import 'package:dietando/pages/all.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const mealPlan = '/';
  static const inventory = '/inventory';
  static const extra = '/extra';
  static const shopping = '/shopping';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.mealPlan,
  routes: [
    GoRoute(
      path: AppRoutes.mealPlan,
      builder: (_, _) => const MealPlanPage(),
    ),
    GoRoute(
      path: AppRoutes.inventory,
      builder: (_, _) => const InventoryPage(),
    ),
    GoRoute(
      path: AppRoutes.extra,
      builder: (_, _) => const ExtraPage(),
    ),
    GoRoute(
      path: AppRoutes.shopping,
      builder: (_, _) => const ShoppingPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, _) => const SettingsPage(),
    ),
  ],
);
