import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/qr_provider.dart';
import 'rounded_qr_painter.dart';

class QrPreviewWidget extends StatefulWidget {
  const QrPreviewWidget({super.key});

  @override
  State<QrPreviewWidget> createState() => _QrPreviewWidgetState();
}

class _QrPreviewWidgetState extends State<QrPreviewWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRProvider>(context);
    final config = provider.config;
    final templates = provider.templates;

    Widget? buildBanner() {
      if (config.frameText == null || config.frameText!.trim().isEmpty) return null;
      IconData? iconData;
      switch (config.frameIcon) {
        case 'scan':
          iconData = Icons.qr_code_scanner;
          break;
        case 'wifi':
          iconData = Icons.wifi;
          break;
        case 'link':
          iconData = Icons.link;
          break;
        case 'phone':
          iconData = Icons.phone;
          break;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: config.frameColor, borderRadius: BorderRadius.circular(config.frameRadius)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[Icon(iconData, color: config.frameTextColor, size: 20), const SizedBox(width: 8)],
            Text(
              config.frameText!,
              style: TextStyle(
                color: config.frameTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    final qrWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: config.backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          config.dotStyle == 'rounded'
              ? CustomPaint(
                  size: const Size(240, 240),
                  painter: RoundedQrPainter(
                    data: config.generatedData,
                    errorCorrectionLevel: config.errorCorrectionLevel,
                    foregroundColor: config.foregroundColor,
                    backgroundColor: config.backgroundColor,
                  ),
                )
              : QrImageView(
                  data: config.generatedData,
                  version: QrVersions.auto,
                  size: 240.0,
                  backgroundColor: config.backgroundColor,
                  eyeStyle: QrEyeStyle(
                    eyeShape: config.dotStyle == 'circular' ? QrEyeShape.circle : QrEyeShape.square,
                    color: config.foregroundColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: config.dotStyle == 'circular'
                        ? QrDataModuleShape.circle
                        : QrDataModuleShape.square,
                    color: config.foregroundColor,
                  ),
                  errorCorrectionLevel: _getEcLevel(config.errorCorrectionLevel),
                ),
          if (config.logoBytes != null) ...[
            // White padding background (quiet zone) behind logo
            Container(
              width: config.logoSize + 10,
              height: config.logoSize + 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
              ),
            ),
            // Actual logo image on top of the white padding background
            SizedBox(
              width: config.logoSize,
              height: config.logoSize,
              child: ClipOval(child: Image.memory(config.logoBytes!, fit: BoxFit.cover)),
            ),
          ],
        ],
      ),
    );

    Widget buildFramedPreview() {
      final banner = buildBanner();
      if (banner == null || config.framePosition == 'top' || config.framePosition == 'bottom') {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (banner != null && config.framePosition == 'top') ...[banner, const SizedBox(height: 12)],
            qrWidget,
            if (banner != null && config.framePosition == 'bottom') ...[const SizedBox(height: 12), banner],
          ],
        );
      } else {
        // 'wrap' mode: banner/frame wraps around the QR code as a container border
        IconData? iconData;
        switch (config.frameIcon) {
          case 'scan':
            iconData = Icons.qr_code_scanner;
            break;
          case 'wifi':
            iconData = Icons.wifi;
            break;
          case 'link':
            iconData = Icons.link;
            break;
          case 'phone':
            iconData = Icons.phone;
            break;
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: config.frameColor, borderRadius: BorderRadius.circular(config.frameRadius)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconData != null) ...[
                    Icon(iconData, color: config.frameTextColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    config.frameText!,
                    style: TextStyle(
                      color: config.frameTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              qrWidget,
            ],
          ),
        );
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Preview & Export', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.bookmark_added, color: Colors.blue),
                  tooltip: 'Templates Menu',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [Icon(Icons.upload_file, size: 18), SizedBox(width: 8), Text('Export Templates...')],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Import Templates...')],
                      ),
                    ),
                    const PopupMenuDivider(),
                    if (templates.isEmpty)
                      const PopupMenuItem(enabled: false, child: Text('No saved templates'))
                    else
                      ...templates.map(
                        (t) => PopupMenuItem(
                          value: 'load_${t.id}',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.name),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                  provider.deleteTemplate(t.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  onSelected: (value) async {
                    if (value == 'export') {
                      final path = await provider.exportTemplates();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(path != null ? 'Templates exported to: $path' : 'Export cancelled')),
                        );
                      }
                    } else if (value == 'import') {
                      final success = await provider.importTemplates();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Templates imported successfully!' : 'Import cancelled or failed'),
                          ),
                        );
                      }
                    } else if (value.startsWith('load_')) {
                      final id = value.substring(5);
                      final template = templates.firstWhere((t) => t.id == id);
                      provider.loadTemplate(template);
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Loaded template: ${template.name}')));
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // QR Code with Frame Screenshot Target
            Screenshot(
              controller: _screenshotController,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16)),
                child: buildFramedPreview(),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isExporting ? null : () => _exportImage(context),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isExporting ? 'Exporting...' : 'Save PNG As...'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                  onPressed: () => _showSaveTemplateDialog(context, provider),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getEcLevel(int level) {
    switch (level) {
      case 0:
        return QrErrorCorrectLevel.L;
      case 1:
        return QrErrorCorrectLevel.M;
      case 2:
        return QrErrorCorrectLevel.Q;
      case 3:
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.M;
    }
  }

  Future<void> _exportImage(BuildContext context) async {
    setState(() => _isExporting = true);
    try {
      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) throw Exception('Failed to capture image');
      if (!mounted) return;

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save QR Code As',
        fileName: 'company_qr_${DateTime.now().millisecondsSinceEpoch}.png',
        bytes: imageBytes,
      );

      if (!mounted) return;
      if (path != null) {
        final file = File(path);
        await file.writeAsBytes(imageBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Code saved successfully to: $path')));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save cancelled')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSaveTemplateDialog(BuildContext context, QRProvider provider) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Company QR Template'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Template Name (e.g. Brand Primary Blue)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await provider.saveTemplate(nameController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Template saved successfully!')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
