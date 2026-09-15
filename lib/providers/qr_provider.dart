import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_config.dart';
import '../platform/platform_io.dart';

class QRProvider with ChangeNotifier {
  QRCodeConfig _config = QRCodeConfig();
  List<CompanyTemplate> _templates = [];
  ThemeMode _themeMode = ThemeMode.system;

  QRCodeConfig get config => _config;
  List<CompanyTemplate> get templates => _templates;
  ThemeMode get themeMode => _themeMode;

  QRProvider() {
    Future.microtask(() => _loadTemplates());
  }

  void updateConfig(QRCodeConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void updateField(void Function(QRCodeConfig c) updateFn) {
    updateFn(_config);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String str = 'system';
      if (mode == ThemeMode.light) {
        str = 'light';
      } else if (mode == ThemeMode.dark) {
        str = 'dark';
      }
      await prefs.setString('app_theme_mode', str);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? themeStr = prefs.getString('app_theme_mode');
      if (themeStr != null) {
        if (themeStr == 'light') {
          _themeMode = ThemeMode.light;
        } else if (themeStr == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      }

      final String? jsonStr = prefs.getString('company_qr_templates');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _templates = decoded.map((e) => CompanyTemplate.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading templates/theme: $e');
    }
  }

  Future<void> saveTemplate(String name) async {
    final newTemplate = CompanyTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      config: _config.copyWith(),
    );
    _templates.add(newTemplate);
    await _persistTemplates();
    notifyListeners();
  }

  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await _persistTemplates();
    notifyListeners();
  }

  void loadTemplate(CompanyTemplate template) {
    _config = template.config.copyWith();
    notifyListeners();
  }

  Future<String?> exportTemplates() async {
    try {
      final String jsonStr = jsonEncode(_templates.map((t) => t.toJson()).toList());
      final bytes = utf8.encode(jsonStr);
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Company QR Templates As',
        fileName: 'company_qr_templates.json',
        bytes: Uint8List.fromList(bytes),
      );
      if (path != null) {
        await writeFileBytes(path, Uint8List.fromList(bytes));
        return path;
      }
      return null;
    } catch (e) {
      debugPrint('Error exporting templates: $e');
      return null;
    }
  }

  Future<bool> importTemplates() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        final jsonStr = utf8.decode(result.files.single.bytes!);
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final imported = decoded.map((e) => CompanyTemplate.fromJson(e)).toList();
        for (var t in imported) {
          if (!_templates.any((existing) => existing.id == t.id)) {
            _templates.add(t);
          }
        }
        await _persistTemplates();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error importing templates: $e');
    }
    return false;
  }

  Future<void> _persistTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(_templates.map((t) => t.toJson()).toList());
      await prefs.setString('company_qr_templates', jsonStr);
    } catch (e) {
      debugPrint('Error saving templates: $e');
    }
  }
}
