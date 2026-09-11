import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class RoundedQrPainter extends CustomPainter {
  final String data;
  final int errorCorrectionLevel;
  final Color foregroundColor;
  final Color backgroundColor;
  final double roundness;

  RoundedQrPainter({
    required this.data,
    required this.errorCorrectionLevel,
    required this.foregroundColor,
    required this.backgroundColor,
    this.roundness = 0.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final ecLevel = [
      QrErrorCorrectLevel.L,
      QrErrorCorrectLevel.M,
      QrErrorCorrectLevel.Q,
      QrErrorCorrectLevel.H,
    ][errorCorrectionLevel];

    try {
      final safeData = data.trim().isEmpty ? 'https://www.example.com' : data;
      final qrCode = QrCode.fromData(data: safeData, errorCorrectLevel: ecLevel);
      final qrImage = QrImage(qrCode);

      final int moduleCount = qrImage.moduleCount;
      final double moduleSize = size.width / moduleCount;

      final fgPaint = Paint()
        ..color = foregroundColor
        ..style = PaintingStyle.fill;

      final bgFillPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;

      // Helper to check if (x, y) is part of finder patterns
      bool isFinderPattern(int x, int y) {
        if (x <= 6 && y <= 6) return true;
        if (x >= moduleCount - 7 && y <= 6) return true;
        if (x <= 6 && y >= moduleCount - 7) return true;
        return false;
      }

      // 1. Connected Components (4-way Flood-Fill) for 2D blob merging (horizontal & vertical)
      final visited = List.generate(moduleCount, (_) => List<bool>.filled(moduleCount, false));

      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (isFinderPattern(x, y)) continue;
          if (visited[y][x]) continue;
          if (qrImage.isDark(y, x) != true) continue;

          // BFS / Flood-fill to find connected component blob
          final queue = <Point<int>>[Point(x, y)];
          visited[y][x] = true;
          Path blobPath = Path();

          while (queue.isNotEmpty) {
            final p = queue.removeAt(0);

            final rect = Rect.fromLTWH(
              p.x * moduleSize - 0.4,
              p.y * moduleSize - 0.4,
              moduleSize + 0.8,
              moduleSize + 0.8,
            );
            final rrect = RRect.fromRectAndRadius(rect, Radius.circular(moduleSize * roundness));
            blobPath.addRRect(rrect);

            // 4-way neighbors (up, down, left, right)
            final neighbors = [Point(p.x, p.y - 1), Point(p.x, p.y + 1), Point(p.x - 1, p.y), Point(p.x + 1, p.y)];

            for (final n in neighbors) {
              if (n.x >= 0 &&
                  n.x < moduleCount &&
                  n.y >= 0 &&
                  n.y < moduleCount &&
                  !isFinderPattern(n.x, n.y) &&
                  !visited[n.y][n.x] &&
                  qrImage.isDark(n.y, n.x) == true) {
                visited[n.y][n.x] = true;
                queue.add(n);
              }
            }
          }

          canvas.drawPath(blobPath, fgPaint);
        }
      }

      // 2. Paint the 3 large finder pattern eyes as single large squircles
      void paintFinderPattern(double startX, double startY) {
        // Outer 7x7 frame
        final outerRect = Rect.fromLTWH(startX, startY, 7 * moduleSize, 7 * moduleSize);
        final outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(7 * moduleSize * 0.32));
        canvas.drawRRect(outerRRect, fgPaint);

        // Inner 5x5 background cutout
        final innerRect = Rect.fromLTWH(startX + moduleSize, startY + moduleSize, 5 * moduleSize, 5 * moduleSize);
        final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(5 * moduleSize * 0.28));
        canvas.drawRRect(innerRRect, bgFillPaint);

        // Center 3x3 dot
        final dotRect = Rect.fromLTWH(startX + 2 * moduleSize, startY + 2 * moduleSize, 3 * moduleSize, 3 * moduleSize);
        final dotRRect = RRect.fromRectAndRadius(dotRect, Radius.circular(3 * moduleSize * 0.32));
        canvas.drawRRect(dotRRect, fgPaint);
      }

      // Top-left finder
      paintFinderPattern(0, 0);
      // Top-right finder
      paintFinderPattern((moduleCount - 7) * moduleSize, 0);
      // Bottom-left finder
      paintFinderPattern(0, (moduleCount - 7) * moduleSize);
    } catch (e) {
      debugPrint('Error painting rounded QR: $e');
    }
  }

  @override
  bool shouldRepaint(covariant RoundedQrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.errorCorrectionLevel != errorCorrectionLevel ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roundness != roundness;
  }
}
