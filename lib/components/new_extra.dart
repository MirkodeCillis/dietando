import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';
import 'package:uuid/uuid.dart';

class NewExtra extends StatelessWidget {
  final Function(ExtraItem) onUpdate;

  const NewExtra({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final qtyCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final fieldDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4), 
        borderSide: BorderSide.none
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      filled: true,
      fillColor: Colors.white,
      floatingLabelStyle: TextStyle(color: Colors.transparent, fontWeight: FontWeight.bold, letterSpacing: 2),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(0xFFF59E0B),
      ),
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: nameCtrl,
                decoration: fieldDecoration.copyWith(
                  labelText: "Nuovo Extra",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1, 
              child: TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration.copyWith(
                  labelText: "Quantità",
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                  onUpdate(ExtraItem(
                    id: const Uuid().v4(),
                    name: nameCtrl.text,
                    quantity: double.tryParse(qtyCtrl.text),
                    isBought: false,
                  ));
                  nameCtrl.clear();
                  qtyCtrl.clear();
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(const Color(0xFF10B981)),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: const Icon(Icons.add, size: 24),
                )
            )
          ],
        ),
      )
    );
  }
}