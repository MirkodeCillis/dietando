import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dietando/services/data_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dietando/models/models.dart';

class ExportData {
  final List<DietItem> dietItems;
  final List<ExtraItem> extraItems;
  final List<ShoppingCategory> categories;
  final MealPlan mealPlan;
  final String exportDate;

  ExportData({
    required this.dietItems,
    required this.extraItems,
    required this.categories,
    required this.mealPlan,
    required this.exportDate,
  });

  Map<String, dynamic> toJson() => {
        'exportDate': exportDate,
        'dietItems': dietItems.map((item) => item.toJson()).toList(),
        'extraItems': extraItems.map((item) => item.toJson()).toList(),
        'categories': categories.map((item) => item.toJson()).toList(),
        'mealPlan': mealPlan.toJson(),
      };

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      exportDate: json['exportDate'] ?? DateTime.now().toIso8601String(),
      dietItems: (json['dietItems'] as List)
          .map((item) => DietItem.fromJson(item))
          .toList(),
        extraItems: (json['extraItems'] as List)
          .map((item) => ExtraItem.fromJson(item))
          .toList(),
      categories: (json['categories'] as List).map((item) => ShoppingCategory.fromJson(item)).toList(),
      mealPlan: MealPlan.fromJson(json['mealPlan']),
    );
  }
}

class ImportExportService {

  // ========== EXPORT ==========

  static Future<String> _exportToJson() async {
    final m = await DataService.loadMealPlan();
    final d = await DataService.loadDiet();
    final e = await DataService.loadExtras();
    final c = await DataService.loadCategories();
    
    final exportData = ExportData(
      dietItems: d,
      extraItems: e,
      mealPlan: m,
      categories: c,
      exportDate: DateTime.now().toIso8601String(),
    );

    final jsonString = jsonEncode(exportData.toJson());
    return jsonString;
  }

  static Future<bool> exportAndShare() async {
    try {
      final jsonString = await _exportToJson();

      final directory = await getTemporaryDirectory();
      final fileName = 'dietando_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Backup Dietando',
        text: 'Backup dei dati di Dietando del ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> exportToFile() async {
    try {
      final jsonString = await _exportToJson();
      final fileName = 'dietando_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      // Usa file_picker che gestisce tutte le piattaforme
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salva backup',
        fileName: fileName,
        bytes: bytes,
      );

      return result != null;
    } catch (e) {
      print('Errore export: $e');
      return false;
    }
  }

  static Future<bool> export() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await ImportExportService.exportAndShare();
    } else {
      return await ImportExportService.exportToFile();
    }
  }

  // ========== IMPORT ==========

  static Future<ExportData?> _importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return ExportData.fromJson(json);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      final exportedData = await _importFromJson(jsonString);

      if (exportedData == null) {
        return false;
      }

      DataService.saveMealPlan(exportedData.mealPlan);
      DataService.saveCategories(exportedData.categories);
      DataService.saveDiet(exportedData.dietItems);
      DataService.saveExtras(exportedData.extraItems);
      return true;
    } catch (e) {
      return false;
    }
  }
}