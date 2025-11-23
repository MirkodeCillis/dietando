import 'package:flutter/material.dart';

// Controller per gestire il Filter dall'esterno
class FilterController {
  VoidCallback? _resetCallback;

  void _attach(VoidCallback callback) {
    _resetCallback = callback;
  }

  void _detach() {
    _resetCallback = null;
  }

  void reset() {
    _resetCallback?.call();
  }
}

class Filter<T> extends StatefulWidget {
  final List<T> list;
  final String Function(T) filterBy;
  final Function(List<T>) updateList;
  final FilterController? controller;

  const Filter({
    super.key,
    required this.list,
    required this.filterBy,
    required this.updateList,
    this.controller,
  });

  @override
  State<Filter<T>> createState() => _FilterState<T>();
}

class _FilterState<T> extends State<Filter<T>> {
  final TextEditingController fieldCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_reset);
  }

  @override
  void didUpdateWidget(Filter<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_reset);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    fieldCtrl.dispose();
    super.dispose();
  }

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

  void _reset() {
    fieldCtrl.clear();
    onChange('');
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                  onPressed: _reset,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
