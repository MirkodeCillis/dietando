import 'package:flutter/material.dart';

class Filter<T> extends StatefulWidget {
  final List<T> list;
  final String Function(T) filterBy;
  final Function(List<T>) updateList;

  const Filter({
    super.key,
    required this.list,
    required this.filterBy,
    required this.updateList
  });

  @override
  State<Filter<T>> createState() => _FilterState<T>();
}

class _FilterState<T> extends State<Filter<T>> {
  final TextEditingController fieldCtrl = TextEditingController();

  void onChange(String value) {
    if (value.length < 3) {
      widget.updateList(widget.list);
      return;
    }

    widget.updateList(
      widget.list.where((item) {
        final field = widget.filterBy(item).toLowerCase();
        return field.contains(value.toLowerCase());
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: fieldCtrl,
                onChanged: onChange,
                decoration: InputDecoration(
                  labelText: "Filtra",
                  suffix: IconButton(
                    icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                    onPressed: () {
                      fieldCtrl.clear();
                      onChange('');
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
