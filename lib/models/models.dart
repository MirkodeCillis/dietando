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