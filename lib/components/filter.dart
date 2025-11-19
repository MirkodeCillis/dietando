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
    return Container(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: fieldCtrl,
                onChanged: onChange,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
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
