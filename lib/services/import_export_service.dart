import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dietando/models/models.dart';
import 'package:dietando/providers/categories_provider.dart';
import 'package:dietando/providers/diet_items_provider.dart';
import 'package:dietando/providers/extra_items_provider.dart';
import 'package:dietando/providers/meal_plan_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Conditional import: downloadFileWeb() is resolved per platform target.
import 'download_service_stub.dart'
    if (dart.library.js_interop) 'download_service_web.dart';

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
      categories: (json['categories'] as List)
          .map((item) => ShoppingCategory.fromJson(item))
          .toList(),
      mealPlan: MealPlan.fromJson(json['mealPlan']),
    );
  }
}

class ImportExportService {
  // ========== EXPORT ==========

  static String _toJson(ExportData data) =>
      jsonEncode(data.toJson());

  static Future<bool> _exportAndShare(String jsonString) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName =
          'dietando_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Backup Dietando',
        text:
            'Backup dei dati di Dietando del ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Errore export share: $e');
      return false;
    }
  }

  static Future<bool> _exportToFile(String jsonString) async {
    try {
      final fileName =
          'dietando_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      if (kIsWeb) {
        downloadFileWeb(bytes, fileName);
        return true;
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salva backup',
        fileName: fileName,
        bytes: bytes,
      );

      return result != null;
    } catch (e) {
      debugPrint('Errore export file: $e');
      return false;
    }
  }

  /// Exports all app data. Reads current state from Riverpod providers via [ref].
  static Future<bool> export(WidgetRef ref) async {
    final dietItems = ref.read(dietItemsProvider).valueOrNull ?? [];
    final extraItems = ref.read(extraItemsProvider).valueOrNull ?? [];
    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    final mealPlan =
        ref.read(mealPlanProvider).valueOrNull ?? MealPlan();

    final data = ExportData(
      dietItems: dietItems,
      extraItems: extraItems,
      categories: categories,
      mealPlan: mealPlan,
      exportDate: DateTime.now().toIso8601String(),
    );

    final jsonString = _toJson(data);

    if (kIsWeb) return _exportToFile(jsonString);
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return _exportAndShare(jsonString);
      } else {
        return _exportToFile(jsonString);
      }
    } catch (e) {
      debugPrint('Platform check failed, using file picker: $e');
      return _exportToFile(jsonString);
    }
  }

  // ========== IMPORT ==========

  static Future<ExportData?> _parseJson(String jsonString) async {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return ExportData.fromJson(json);
    } catch (e) {
      debugPrint('Errore import JSON: $e');
      return null;
    }
  }

  /// Imports data from a file and writes it through Riverpod notifiers via [ref].
  static Future<bool> importFromFile(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return false;

      String jsonString;

      if (kIsWeb) {
        final bytes = result.files.first.bytes;
        if (bytes == null) {
          debugPrint('Errore: bytes null su web');
          return false;
        }
        jsonString = utf8.decode(bytes);
      } else {
        final path = result.files.first.path;
        if (path == null) {
          debugPrint('Errore: path null');
          return false;
        }
        jsonString = await File(path).readAsString();
      }

      final exported = await _parseJson(jsonString);
      if (exported == null) return false;

      await ref
          .read(mealPlanProvider.notifier)
          .replaceAll(exported.mealPlan);
      await ref
          .read(categoriesProvider.notifier)
          .replaceAll(exported.categories);
      await ref
          .read(dietItemsProvider.notifier)
          .replaceAll(exported.dietItems);
      await ref
          .read(extraItemsProvider.notifier)
          .replaceAll(exported.extraItems);

      return true;
    } catch (e) {
      debugPrint('Errore import: $e');
      return false;
    }
  }

  static bool willUseShare() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }
}
