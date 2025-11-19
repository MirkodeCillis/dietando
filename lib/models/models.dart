enum Unit { grams, pieces, liters }

class DietItem {
  String id;
  String name;
  double weeklyTarget;
  double currentStock;
  Unit unit;

  DietItem({
    required this.id,
    required this.name,
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
        weeklyTarget: (json['weeklyTarget'] as num).toDouble(),
        currentStock: (json['currentStock'] as num).toDouble(),
        unit: Unit.values[json['unit']],
      );
}

class ExtraItem {
  String id;
  String name;
  bool isBought;
  double? estimatedCost;

  ExtraItem({
    required this.id,
    required this.name,
    this.isBought = false,
    this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isBought': isBought,
        'estimatedCost': estimatedCost,
      };

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
        id: json['id'],
        name: json['name'],
        isBought: json['isBought'] ?? false,
        estimatedCost: json['estimatedCost'] != null
            ? (json['estimatedCost'] as num).toDouble()
            : null,
      );
}