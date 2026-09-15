import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class RoundedQrPainter extends CustomPainter {
  final String data;
  final int errorCorrectionLevel;
  final Color foregroundColor;
  final Color backgroundColor;
  final String dotStyle; // 'square', 'rounded', 'circular'
  final double roundness;

  final bool useGradient;
  final Color gradientEndColor;
  final String gradientDirection; // 'diagonal', 'vertical', 'horizontal', 'radial'

  final String eyeShape; // 'auto', 'rounded', 'circular', 'square', 'leaf'
  final Color? eyeColor;
  final Color? eyeInnerColor;

  RoundedQrPainter({
    required this.data,
    required this.errorCorrectionLevel,
    required this.foregroundColor,
    required this.backgroundColor,
    this.dotStyle = 'rounded',
    this.roundness = 0.5,
    this.useGradient = false,
    this.gradientEndColor = const Color(0xFF0EA5E9),
    this.gradientDirection = 'diagonal',
    this.eyeShape = 'auto',
    this.eyeColor,
    this.eyeInnerColor,
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
      final double cellSize = size.width / moduleCount;
      final double r = cellSize * roundness.clamp(0.0, 0.5);

      final fgPaint = Paint()
        ..color = foregroundColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      if (useGradient) {
        Gradient gradient;
        switch (gradientDirection) {
          case 'vertical':
            gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [foregroundColor, gradientEndColor],
            );
            break;
          case 'horizontal':
            gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [foregroundColor, gradientEndColor],
            );
            break;
          case 'radial':
            gradient = RadialGradient(
              center: Alignment.center,
              radius: 0.75,
              colors: [foregroundColor, gradientEndColor],
            );
            break;
          case 'diagonal':
          default:
            gradient = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [foregroundColor, gradientEndColor],
            );
            break;
        }
        fgPaint.shader = gradient.createShader(Offset.zero & size);
      }

      final bgFillPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      // Helper to check if (x, y) is part of finder patterns
      bool isFinderPattern(int x, int y) {
        if (x < 0 || y < 0 || x >= moduleCount || y >= moduleCount) return false;
        if (x <= 6 && y <= 6) return true;
        if (x >= moduleCount - 7 && y <= 6) return true;
        if (x <= 6 && y >= moduleCount - 7) return true;
        return false;
      }

      bool isDark(int x, int y) {
        if (x < 0 || y < 0 || x >= moduleCount || y >= moduleCount) return false;
        if (isFinderPattern(x, y)) return false;
        return qrImage.isDark(y, x) == true;
      }

      final Path dataPath = Path();

      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (isFinderPattern(x, y)) continue;

          final double px = x * cellSize;
          final double py = y * cellSize;

          if (isDark(x, y)) {
            if (dotStyle == 'circular') {
              dataPath.addOval(
                Rect.fromCircle(
                  center: Offset(px + (cellSize / 2), py + (cellSize / 2)),
                  radius: cellSize * 0.45,
                ),
              );
            } else if (dotStyle == 'square') {
              dataPath.addRect(Rect.fromLTWH(px, py, cellSize + 0.05, cellSize + 0.05));
            } else {
              // Smooth connected modules
              final bool top = isDark(x, y - 1);
              final bool bottom = isDark(x, y + 1);
              final bool left = isDark(x - 1, y);
              final bool right = isDark(x + 1, y);

              final rrect = RRect.fromRectAndCorners(
                Rect.fromLTWH(px, py, cellSize + 0.05, cellSize + 0.05),
                topLeft: Radius.circular((!top && !left) ? r : 0.0),
                topRight: Radius.circular((!top && !right) ? r : 0.0),
                bottomLeft: Radius.circular((!bottom && !left) ? r : 0.0),
                bottomRight: Radius.circular((!bottom && !right) ? r : 0.0),
              );
              dataPath.addRRect(rrect);
            }
          } else if (dotStyle == 'rounded') {
            // Check light cells for inner corner concave fillets.
            final bool top = isDark(x, y - 1);
            final bool bottom = isDark(x, y + 1);
            final bool left = isDark(x - 1, y);
            final bool right = isDark(x + 1, y);

            final bool topLeft = isDark(x - 1, y - 1);
            final bool topRight = isDark(x + 1, y - 1);
            final bool bottomLeft = isDark(x - 1, y + 1);
            final bool bottomRight = isDark(x + 1, y + 1);

            // Top-Left inner fillet: requires top, left, and topLeft to be dark
            if (top && left && topLeft) {
              final fillet = Path()
                ..moveTo(px, py)
                ..lineTo(px + r, py)
                ..arcToPoint(
                  Offset(px, py + r),
                  radius: Radius.circular(r),
                  clockwise: false,
                )
                ..lineTo(px, py)
                ..close();
              dataPath.addPath(fillet, Offset.zero);
            }

            // Top-Right inner fillet: requires top, right, and topRight to be dark
            if (top && right && topRight) {
              final fillet = Path()
                ..moveTo(px + cellSize, py)
                ..lineTo(px + cellSize - r, py)
                ..arcToPoint(
                  Offset(px + cellSize, py + r),
                  radius: Radius.circular(r),
                  clockwise: true,
                )
                ..lineTo(px + cellSize, py)
                ..close();
              dataPath.addPath(fillet, Offset.zero);
            }

            // Bottom-Left inner fillet: requires bottom, left, and bottomLeft to be dark
            if (bottom && left && bottomLeft) {
              final fillet = Path()
                ..moveTo(px, py + cellSize)
                ..lineTo(px + r, py + cellSize)
                ..arcToPoint(
                  Offset(px, py + cellSize - r),
                  radius: Radius.circular(r),
                  clockwise: true,
                )
                ..lineTo(px, py + cellSize)
                ..close();
              dataPath.addPath(fillet, Offset.zero);
            }

            // Bottom-Right inner fillet: requires bottom, right, and bottomRight to be dark
            if (bottom && right && bottomRight) {
              final fillet = Path()
                ..moveTo(px + cellSize, py + cellSize)
                ..lineTo(px + cellSize - r, py + cellSize)
                ..arcToPoint(
                  Offset(px + cellSize - r, py + cellSize),
                  radius: Radius.circular(r),
                  clockwise: false,
                )
                ..lineTo(px + cellSize, py + cellSize)
                ..close();
              dataPath.addPath(fillet, Offset.zero);
            }
          }
        }
      }

      canvas.drawPath(dataPath, fgPaint);

      // Eye Paints
      final eyeOuterPaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      if (eyeColor != null) {
        eyeOuterPaint.color = eyeColor!;
      } else if (useGradient) {
        eyeOuterPaint.shader = fgPaint.shader;
      } else {
        eyeOuterPaint.color = foregroundColor;
      }

      final eyeInnerPaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      if (eyeInnerColor != null) {
        eyeInnerPaint.color = eyeInnerColor!;
      } else if (eyeColor != null) {
        eyeInnerPaint.color = eyeColor!;
      } else if (useGradient) {
        eyeInnerPaint.shader = fgPaint.shader;
      } else {
        eyeInnerPaint.color = foregroundColor;
      }

      // Determine effective eye shape
      final String effectiveEyeShape = eyeShape == 'auto'
          ? (dotStyle == 'circular' ? 'circular' : (dotStyle == 'square' ? 'square' : 'rounded'))
          : eyeShape;

      // Paint 3 finder pattern eyes
      void paintFinderPattern(double startX, double startY) {
        final outerRect = Rect.fromLTWH(startX, startY, 7 * cellSize, 7 * cellSize);
        final innerRect = Rect.fromLTWH(startX + cellSize, startY + cellSize, 5 * cellSize, 5 * cellSize);
        final dotRect = Rect.fromLTWH(startX + 2 * cellSize, startY + 2 * cellSize, 3 * cellSize, 3 * cellSize);

        if (effectiveEyeShape == 'circular') {
          canvas.drawRRect(RRect.fromRectAndRadius(outerRect, Radius.circular(7 * cellSize * 0.5)), eyeOuterPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(5 * cellSize * 0.5)), bgFillPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(dotRect, Radius.circular(3 * cellSize * 0.5)), eyeInnerPaint);
        } else if (effectiveEyeShape == 'square') {
          canvas.drawRect(outerRect, eyeOuterPaint);
          canvas.drawRect(innerRect, bgFillPaint);
          canvas.drawRect(dotRect, eyeInnerPaint);
        } else if (effectiveEyeShape == 'leaf') {
          // Leaf shape with diagonal rounded corners
          final outerLeaf = RRect.fromRectAndCorners(
            outerRect,
            topLeft: Radius.circular(7 * cellSize * 0.45),
            bottomRight: Radius.circular(7 * cellSize * 0.45),
          );
          final innerLeaf = RRect.fromRectAndCorners(
            innerRect,
            topLeft: Radius.circular(5 * cellSize * 0.40),
            bottomRight: Radius.circular(5 * cellSize * 0.40),
          );
          final dotLeaf = RRect.fromRectAndCorners(
            dotRect,
            topLeft: Radius.circular(3 * cellSize * 0.45),
            bottomRight: Radius.circular(3 * cellSize * 0.45),
          );
          canvas.drawRRect(outerLeaf, eyeOuterPaint);
          canvas.drawRRect(innerLeaf, bgFillPaint);
          canvas.drawRRect(dotLeaf, eyeInnerPaint);
        } else {
          // Default: Rounded squircle
          final outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(7 * cellSize * 0.32));
          final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(5 * cellSize * 0.28));
          final dotRRect = RRect.fromRectAndRadius(dotRect, Radius.circular(3 * cellSize * 0.32));
          canvas.drawRRect(outerRRect, eyeOuterPaint);
          canvas.drawRRect(innerRRect, bgFillPaint);
          canvas.drawRRect(dotRRect, eyeInnerPaint);
        }
      }

      // Top-left finder
      paintFinderPattern(0, 0);
      // Top-right finder
      paintFinderPattern((moduleCount - 7) * cellSize, 0);
      // Bottom-left finder
      paintFinderPattern(0, (moduleCount - 7) * cellSize);
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
        oldDelegate.dotStyle != dotStyle ||
        oldDelegate.roundness != roundness ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientEndColor != gradientEndColor ||
        oldDelegate.gradientDirection != gradientDirection ||
        oldDelegate.eyeShape != eyeShape ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.eyeInnerColor != eyeInnerColor;
  }
}
