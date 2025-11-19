import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';
import 'package:gestore_spesa/services/gemini_service.dart';

class AiPage extends StatefulWidget {
  final List<DietItem> dietItems;
  final List<ExtraItem> extraItems;

  const AiPage({super.key, required this.dietItems, required this.extraItems});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  String _response = "";
  bool _loading = false;

  void _askGemini() async {
    setState(() { _loading = true; _response = ""; });
    final text = await GeminiService.getAdvice(widget.dietItems, widget.extraItems);
    setState(() { _loading = false; _response = text; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 60, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text("Analisi Intelligente", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Chiedi a Gemini consigli su ricette e bilanciamento.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _loading ? null : _askGemini,
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              icon: _loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.play_arrow),
              label: Text(_loading ? "Analisi in corso..." : "Genera Consigli"),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade50),
              ),
              child: SingleChildScrollView(
                child: Text(_response.isEmpty ? "I consigli appariranno qui..." : _response, 
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}