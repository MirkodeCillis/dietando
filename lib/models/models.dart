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