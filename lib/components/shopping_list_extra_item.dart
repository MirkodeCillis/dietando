import 'package:flutter/material.dart';
import 'package:dietando/models/models.dart';

class ShoppingListExtraItem extends StatefulWidget {
  final ExtraItem item;
  final Function() onUpdateExtra;

  const ShoppingListExtraItem({
    super.key, 
    required this.item, 
    required this.onUpdateExtra,
  });
  
  @override
  State<ShoppingListExtraItem> createState() => _ShoppingListExtraItemState();
}

class _ShoppingListExtraItemState extends State<ShoppingListExtraItem> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ShoppingListExtraItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id || 
        oldWidget.item.quantity != widget.item.quantity) {
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              size: 20,
            ),
          ),
          title: Text(widget.item.name),
          subtitle: Text(
            widget.item.quantity != null
              ? "Quantità: ${widget.item.quantity!.toStringAsFixed(2)}" 
              : "Quantità non specificata"
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.check_circle_outline,
            ),
            onPressed: () {widget.onUpdateExtra();},
          ),
        ),
      ),
    );
  }
}