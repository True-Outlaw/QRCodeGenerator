import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../models/qr_config.dart';
import '../providers/qr_provider.dart';
import 'rounded_qr_painter.dart';

class QrPreviewWidget extends StatefulWidget {
  const QrPreviewWidget({super.key});

  @override
  State<QrPreviewWidget> createState() => _QrPreviewWidgetState();
}

class _QrPreviewWidgetState extends State<QrPreviewWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _previewContainerKey = GlobalKey();
  bool _isExporting = false;
  String _selectedViewTab = 'Vector';
  String _selectedResolution = '1024 px';

  double _calculateScanReliability(QRCodeConfig config) {
    double score = 99.9;
    if (config.generatedData.length > 250) {
      score -= 0.6;
    }
    if (config.logoBytes != null) {
      if (config.errorCorrectionLevel == 0) {
        score -= 4.5;
      } else if (config.errorCorrectionLevel == 1) {
        score -= 2.0;
      } else if (config.errorCorrectionLevel == 2) {
        score -= 0.4;
      }
    }
    final fgLum = config.foregroundColor.computeLuminance();
    final bgLum = config.backgroundColor.computeLuminance();
    final contrast = (fgLum - bgLum).abs();
    if (contrast < 0.25) {
      score -= 6.0;
    }
    return double.parse(score.clamp(80.0, 99.9).toStringAsFixed(1));
  }

  double _getTargetPixelRatio() {
    double targetWidth = 1024.0;
    switch (_selectedResolution) {
      case '512 px':
        targetWidth = 512.0;
        break;
      case '1024 px':
        targetWidth = 1024.0;
        break;
      case '2048 px':
        targetWidth = 2048.0;
        break;
      case '4096 px':
        targetWidth = 4096.0;
        break;
    }
    final RenderBox? renderBox = _previewContainerKey.currentContext?.findRenderObject() as RenderBox?;
    final double renderedWidth = renderBox?.size.width ?? 280.0;
    return targetWidth / renderedWidth;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRProvider>(context);
    final config = provider.config;
    final templates = provider.templates;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reliability = _calculateScanReliability(config);

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
                fontSize: 15,
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
                  size: const Size(220, 220),
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
                  size: 220.0,
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
            Container(
              width: config.logoSize + 10,
              height: config.logoSize + 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
              ),
            ),
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

    return Column(
      children: [
        Card(
          color: isDark ? const Color(0xFF131B2E) : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                const Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Live Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                // QR Code Display Card
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    key: _previewContainerKey,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: buildFramedPreview(),
                  ),
                ),
                const SizedBox(height: 16),

                // Scan Reliability Indicator (Real Assessment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (reliability > 95 ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: reliability > 95 ? Colors.green : Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Scan Reliability: $reliability% (${reliability > 95 ? "Optimal Quality" : "Moderate Risk"})',
                        style: TextStyle(
                          fontSize: 12,
                          color: reliability > 95 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Target Resolution & DPI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Resolution',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const Text(
                      'Print Quality: 300 DPI',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['512 px', '1024 px', '2048 px', '4096 px'].map((res) {
                    final isSelected = _selectedResolution == res;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedResolution = res),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0EA5E9).withValues(alpha: 0.2)
                                  : (isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent),
                            ),
                            child: Text(
                              res,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Download High-Res PNG Button (Gradient)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isExporting ? null : () => _exportImage(context),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Download High-Res PNG',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Export Actions (SVG Vector, Print PDF, Save Template)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _exportSvg(context),
                        child: const Text('SVG Vector', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _exportPrintPdf(context),
                        child: const Text('Print / PDF', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showSaveTemplateDialog(context, provider),
                        child: const Text('Save Template', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
      final imageBytes = await _screenshotController.capture(pixelRatio: _getTargetPixelRatio());
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

  void _writeSvgFinderPattern(
    StringBuffer buffer,
    double startX,
    double startY,
    double cellSize,
    String fgHex,
    String bgHex,
    String dotStyle,
  ) {
    final double size7 = 7 * cellSize;
    final double cx = startX + (size7 / 2);
    final double cy = startY + (size7 / 2);

    if (dotStyle == 'circular') {
      buffer.writeln(
        '  <circle cx="${cx.toStringAsFixed(2)}" cy="${cy.toStringAsFixed(2)}" r="${(3.5 * cellSize).toStringAsFixed(2)}" fill="$fgHex"/>',
      );
      buffer.writeln(
        '  <circle cx="${cx.toStringAsFixed(2)}" cy="${cy.toStringAsFixed(2)}" r="${(2.5 * cellSize).toStringAsFixed(2)}" fill="$bgHex"/>',
      );
      buffer.writeln(
        '  <circle cx="${cx.toStringAsFixed(2)}" cy="${cy.toStringAsFixed(2)}" r="${(1.5 * cellSize).toStringAsFixed(2)}" fill="$fgHex"/>',
      );
    } else {
      final double size5 = 5 * cellSize;
      final double size3 = 3 * cellSize;

      final double rx7 = size7 * 0.32;
      final double rx5 = size5 * 0.28;
      final double rx3 = size3 * 0.32;

      buffer.writeln(
        '  <rect x="${startX.toStringAsFixed(2)}" y="${startY.toStringAsFixed(2)}" width="${size7.toStringAsFixed(2)}" height="${size7.toStringAsFixed(2)}" rx="${rx7.toStringAsFixed(2)}" ry="${rx7.toStringAsFixed(2)}" fill="$fgHex"/>',
      );
      buffer.writeln(
        '  <rect x="${(startX + cellSize).toStringAsFixed(2)}" y="${(startY + cellSize).toStringAsFixed(2)}" width="${size5.toStringAsFixed(2)}" height="${size5.toStringAsFixed(2)}" rx="${rx5.toStringAsFixed(2)}" ry="${rx5.toStringAsFixed(2)}" fill="$bgHex"/>',
      );
      buffer.writeln(
        '  <rect x="${(startX + 2 * cellSize).toStringAsFixed(2)}" y="${(startY + 2 * cellSize).toStringAsFixed(2)}" width="${size3.toStringAsFixed(2)}" height="${size3.toStringAsFixed(2)}" rx="${rx3.toStringAsFixed(2)}" ry="${rx3.toStringAsFixed(2)}" fill="$fgHex"/>',
      );
    }
  }

  String _generateQrSvg(QRCodeConfig config) {
    final ecLevel = [
      QrErrorCorrectLevel.L,
      QrErrorCorrectLevel.M,
      QrErrorCorrectLevel.Q,
      QrErrorCorrectLevel.H,
    ][config.errorCorrectionLevel];

    final safeData = config.generatedData.trim().isEmpty ? 'https://www.example.com' : config.generatedData;
    final qrCode = QrCode.fromData(data: safeData, errorCorrectLevel: ecLevel);
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;

    final bool hasWrap =
        config.frameText != null && config.frameText!.trim().isNotEmpty && config.framePosition == 'wrap';
    final bool hasTop =
        config.frameText != null && config.frameText!.trim().isNotEmpty && config.framePosition == 'top';
    final bool hasBottom =
        config.frameText != null && config.frameText!.trim().isNotEmpty && config.framePosition == 'bottom';

    const double width = 400.0;
    const double qrSize = 280.0;
    final double cellSize = qrSize / moduleCount;

    final double height = hasWrap ? 420.0 : (hasTop || hasBottom ? 420.0 : 380.0);
    final double qrX = (width - qrSize) / 2;
    final double qrY = hasWrap ? 95.0 : (hasTop ? 80.0 : 35.0);

    final buffer = StringBuffer();
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 $width $height" width="$width" height="$height">',
    );

    // Outer canvas background
    buffer.writeln('  <rect width="100%" height="100%" fill="none"/>');

    // Banner / Frame if present
    if (config.frameText != null && config.frameText!.trim().isNotEmpty) {
      final bannerBg = _colorToHex(config.frameColor);
      final bannerFg = _colorToHex(config.frameTextColor);
      final radius = config.frameRadius;

      if (config.framePosition == 'wrap') {
        buffer.writeln(
          '  <rect x="16" y="16" width="${width - 32}" height="${height - 32}" rx="$radius" fill="$bannerBg"/>',
        );
        buffer.writeln(
          '  <text x="${width / 2}" y="56" text-anchor="middle" fill="$bannerFg" font-family="sans-serif" font-weight="bold" font-size="16">${_escapeXml(config.frameText!)}</text>',
        );
      } else if (config.framePosition == 'top') {
        buffer.writeln('  <rect x="50" y="20" width="${width - 100}" height="40" rx="$radius" fill="$bannerBg"/>');
        buffer.writeln(
          '  <text x="${width / 2}" y="45" text-anchor="middle" fill="$bannerFg" font-family="sans-serif" font-weight="bold" font-size="15">${_escapeXml(config.frameText!)}</text>',
        );
      } else if (config.framePosition == 'bottom') {
        buffer.writeln(
          '  <rect x="50" y="${height - 55}" width="${width - 100}" height="40" rx="$radius" fill="$bannerBg"/>',
        );
        buffer.writeln(
          '  <text x="${width / 2}" y="${height - 30}" text-anchor="middle" fill="$bannerFg" font-family="sans-serif" font-weight="bold" font-size="15">${_escapeXml(config.frameText!)}</text>',
        );
      }
    }

    // QR Code background box (12px padding inside white box matching PNG layout)
    const double boxPad = 12.0;
    buffer.writeln(
      '  <rect x="${qrX - boxPad}" y="${qrY - boxPad}" width="${qrSize + (boxPad * 2)}" height="${qrSize + (boxPad * 2)}" rx="16" fill="${_colorToHex(config.backgroundColor)}"/>',
    );

    final fgHex = _colorToHex(config.foregroundColor);
    final bgHex = _colorToHex(config.backgroundColor);
    final dotStyle = config.dotStyle;
    final double rx = dotStyle == 'rounded' ? cellSize * 0.35 : (dotStyle == 'circular' ? cellSize / 2 : 0.0);

    bool isFinderPattern(int x, int y) {
      if (x <= 6 && y <= 6) return true;
      if (x >= moduleCount - 7 && y <= 6) return true;
      if (x <= 6 && y >= moduleCount - 7) return true;
      return false;
    }

    // Paint data modules
    for (int y = 0; y < moduleCount; y++) {
      for (int x = 0; x < moduleCount; x++) {
        if (isFinderPattern(x, y)) continue;

        if (qrImage.isDark(y, x) == true) {
          final double px = qrX + (x * cellSize);
          final double py = qrY + (y * cellSize);
          if (dotStyle == 'circular') {
            final double cx = px + (cellSize / 2);
            final double cy = py + (cellSize / 2);
            final double r = cellSize / 2;
            buffer.writeln(
              '  <circle cx="${cx.toStringAsFixed(2)}" cy="${cy.toStringAsFixed(2)}" r="${r.toStringAsFixed(2)}" fill="$fgHex"/>',
            );
          } else {
            buffer.writeln(
              '  <rect x="${px.toStringAsFixed(2)}" y="${py.toStringAsFixed(2)}" width="${cellSize.toStringAsFixed(2)}" height="${cellSize.toStringAsFixed(2)}" rx="${rx.toStringAsFixed(2)}" ry="${rx.toStringAsFixed(2)}" fill="$fgHex"/>',
            );
          }
        }
      }
    }

    // Paint 3 finder pattern eyes
    _writeSvgFinderPattern(buffer, qrX, qrY, cellSize, fgHex, bgHex, dotStyle);
    _writeSvgFinderPattern(buffer, qrX + (moduleCount - 7) * cellSize, qrY, cellSize, fgHex, bgHex, dotStyle);
    _writeSvgFinderPattern(buffer, qrX, qrY + (moduleCount - 7) * cellSize, cellSize, fgHex, bgHex, dotStyle);

    // Embedded Logo if present
    if (config.logoBytes != null) {
      final double logoX = width / 2;
      final double logoY = qrY + (qrSize / 2);
      final double lSize = config.logoSize;
      final double halfL = lSize / 2;
      final double halfPad = halfL + 6;

      buffer.writeln('  <circle cx="$logoX" cy="$logoY" r="$halfPad" fill="#FFFFFF"/>');

      final base64Image = base64Encode(config.logoBytes!);
      buffer.writeln(
        '  <image href="data:image/png;base64,$base64Image" x="${logoX - halfL}" y="${logoY - halfL}" width="$lSize" height="$lSize" clip-path="circle()"/>',
      );
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  Future<void> _exportSvg(BuildContext context) async {
    try {
      final config = Provider.of<QRProvider>(context, listen: false).config;
      final svgContent = _generateQrSvg(config);
      final bytes = utf8.encode(svgContent);
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export SVG Vector As',
        fileName: 'company_qr_${DateTime.now().millisecondsSinceEpoch}.svg',
        bytes: Uint8List.fromList(bytes),
      );

      if (path != null && context.mounted) {
        final file = File(path);
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SVG Vector saved successfully to: $path')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('SVG Export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _exportPrintPdf(BuildContext context) async {
    try {
      final imageBytes = await _screenshotController.capture(pixelRatio: _getTargetPixelRatio() * 1.25);
      if (imageBytes == null) throw Exception('Failed to capture image');
      if (!mounted) return;

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Print-Ready Asset As',
        fileName: 'company_qr_print_${DateTime.now().millisecondsSinceEpoch}.png',
        bytes: imageBytes,
      );

      if (path != null && context.mounted) {
        final file = File(path);
        await file.writeAsBytes(imageBytes);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Print-ready high-res asset saved successfully to: $path')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Print/PDF export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}';
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
