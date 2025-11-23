import 'package:flutter/material.dart';
import 'package:dietando/models/models.dart';

class ShoppingListDietItem extends StatefulWidget {
  final DietItem item;
  final Function(num amount) onUpdateDiet;

  const ShoppingListDietItem({
    super.key, 
    required this.item, 
    required this.onUpdateDiet,
  });
  
  @override
  State<ShoppingListDietItem> createState() => _ShoppingListItemDietState();
}

class _ShoppingListItemDietState extends State<ShoppingListDietItem> {
  late TextEditingController fieldCtrl = TextEditingController();
  late num missing;

  @override
  void initState() {
    super.initState();
    missing = widget.item.weeklyTarget - widget.item.currentStock;
    fieldCtrl = TextEditingController(text: missing.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(ShoppingListDietItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      missing = widget.item.weeklyTarget - widget.item.currentStock;
      fieldCtrl.text = missing.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    fieldCtrl.dispose();
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
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.shopping_basket,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(widget.item.name),
          subtitle: Text("Mancano $missing ${widget.item.unit.name}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicWidth(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: fieldCtrl,
                  decoration: InputDecoration(
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    labelText: "Q.tà",
                    hintText: "0000",
                  ),
                )
              ),
              SizedBox(width: 8,),
              IconButton(
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                onPressed: () {widget.onUpdateDiet(fieldCtrl.text.isEmpty ? missing : num.parse(fieldCtrl.text));},
              )
            ],
          ),
        ),
      ),
    );
  }
}