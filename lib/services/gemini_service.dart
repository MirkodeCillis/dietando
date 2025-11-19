import 'package:gestore_spesa/models/models.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ IMPORTANTE: Sostituisci con la tua chiave API reale
  static const String apiKey = 'INSERISCI_QUI_LA_TUA_API_KEY';

  static Future<String> getAdvice(List<DietItem> diet, List<ExtraItem> extras) async {
    if (apiKey.startsWith('INSERISCI')) return "Errore: Configura l'API Key nel codice Flutter.";

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final dietContext = diet.map((item) =>
      "- ${item.name}: Target ${item.weeklyTarget}, Attuale ${item.currentStock}. (Necessario: ${item.weeklyTarget - item.currentStock > 0 ? item.weeklyTarget - item.currentStock : 0})"
    ).join('\n');

    final extraContext = extras.map((item) =>
      "- ${item.name} (${item.isBought ? 'Comprato' : 'Da comprare'})"
    ).join('\n');

    final prompt = '''
      Sei un nutrizionista.
      DIETA:
      $dietContext
      EXTRA:
      $extraContext
      
      1. Analizza se l'utente è indietro.
      2. Suggerisci 2 ricette veloci con ciò che l'utente HA GIÀ (CurrentStock > 0).
      3. Consiglio breve.
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Nessun consiglio generato.";
    } catch (e) {
      return "Errore connessione Gemini: $e";
    }
  }
}
