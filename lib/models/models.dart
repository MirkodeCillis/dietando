import 'package:flutter/material.dart';

enum Unit { Grammi, Pezzi, Litri }

class DietItem {
  String id;
  String name;
  String description;
  double weeklyTarget;
  double currentStock;
  Unit unit;

  DietItem({
    required this.id,
    required this.name,
    required this.description,
    required this.weeklyTarget,
    required this.currentStock,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weeklyTarget': weeklyTarget,
    'currentStock': currentStock,
    'unit': unit.index,
  };

  factory DietItem.fromJson(Map<String, dynamic> json) => DietItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    weeklyTarget: (json['weeklyTarget'] as num).toDouble(),
    currentStock: (json['currentStock'] as num).toDouble(),
    unit: Unit.values[json['unit']],
  );
}

enum MealType {
  colazione,
  spuntinoMattutino,
  pranzo,
  spuntinoPomeridiano,
  cena;

  String get displayName {
    switch (this) {
      case MealType.colazione:
        return 'Colazione';
      case MealType.spuntinoMattutino:
        return 'Spuntino Mattutino';
      case MealType.pranzo:
        return 'Pranzo';
      case MealType.spuntinoPomeridiano:
        return 'Spuntino Pomeridiano';
      case MealType.cena:
        return 'Cena';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.colazione:
        return Icons.breakfast_dining;
      case MealType.spuntinoMattutino:
        return Icons.apple;
      case MealType.pranzo:
        return Icons.lunch_dining;
      case MealType.spuntinoPomeridiano:
        return Icons.coffee;
      case MealType.cena:
        return Icons.dinner_dining;
    }
  }
}

enum DayOfWeek {
  lunedi,
  martedi,
  mercoledi,
  giovedi,
  venerdi,
  sabato,
  domenica;

  String get displayName {
    switch (this) {
      case DayOfWeek.lunedi:
        return 'Lunedì';
      case DayOfWeek.martedi:
        return 'Martedì';
      case DayOfWeek.mercoledi:
        return 'Mercoledì';
      case DayOfWeek.giovedi:
        return 'Giovedì';
      case DayOfWeek.venerdi:
        return 'Venerdì';
      case DayOfWeek.sabato:
        return 'Sabato';
      case DayOfWeek.domenica:
        return 'Domenica';
    }
  }
}

class MealPlanItem {
  final String id;
  final String dietItemId;
  final double quantity;

  MealPlanItem({
    required this.id,
    required this.dietItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dietItemId': dietItemId,
        'quantity': quantity,
      };

  factory MealPlanItem.fromJson(Map<String, dynamic> json) => MealPlanItem(
        id: json['id'],
        dietItemId: json['dietItemId'],
        quantity: (json['quantity'] as num).toDouble(),
      );
}

class MealPlan {
  Map<DayOfWeek, Map<MealType, List<MealPlanItem>>> plan;

  MealPlan() : plan = {} {
    for (var day in DayOfWeek.values) {
      plan[day] = {};
      for (var meal in MealType.values) {
        plan[day]![meal] = [];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonPlan = {};
    plan.forEach((day, meals) {
      final Map<String, dynamic> jsonMeals = {};
      meals.forEach((meal, items) {
        jsonMeals[meal.name] = items.map((item) => item.toJson()).toList();
      });
      jsonPlan[day.name] = jsonMeals;
    });
    return jsonPlan;
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final mealPlan = MealPlan();
    json.forEach((dayStr, meals) {
      final day = DayOfWeek.values.firstWhere((d) => d.name == dayStr);
      (meals as Map<String, dynamic>).forEach((mealStr, items) {
        final meal = MealType.values.firstWhere((m) => m.name == mealStr);
        mealPlan.plan[day]![meal] = (items as List)
            .map((item) => MealPlanItem.fromJson(item))
            .toList();
      });
    });
    return mealPlan;
  }
}

class ExtraItem {
  String id;
  String name;
  bool isBought;
  double? quantity;

  ExtraItem({
    required this.id,
    required this.name,
    this.isBought = false,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isBought': isBought,
    'quantity': quantity,
  };

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
    id: json['id'],
    name: json['name'],
    isBought: json['isBought'] ?? false,
    quantity: json['quantity'] != null
        ? (json['quantity'] as num).toDouble()
        : null,
  );
}

class ShoppingCategory {
  final String id;
  final String name;
  final int priority;

  ShoppingCategory({
    required this.id,
    required this.name,
    required this.priority,
  });

  ShoppingCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    int? priority,
  }) {
    return ShoppingCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'priority': priority,
  };

  factory ShoppingCategory.fromJson(Map<String, dynamic> json) => ShoppingCategory(
    id: json['id'],
    name: json['name'],
    priority: json['priority'] ?? 999,
  );
}

class SettingsData {
  String themeMode;
  String language;
  
  SettingsData({
    required this.themeMode,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode,
    'language': language,
  };

  factory SettingsData.fromJson(Map<String, dynamic> json) => SettingsData(
    themeMode: json['themeMode'] ?? 'system',
    language: json['language'] ?? 'it',
  );

  
  static SettingsData defaultSettings = SettingsData(themeMode: 'system', language: 'it');
}