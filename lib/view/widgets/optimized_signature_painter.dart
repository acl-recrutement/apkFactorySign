// lib/view/widgets/optimized_signature_painter.dart
import 'package:flutter/material.dart';

// 📦 Structure stockant position + pression pour chaque point
class StrokePoint {
  final Offset offset;
  final double pressure; // 0.0 à 1.0
  const StrokePoint(this.offset, this.pressure);
}

// 📊 Modèle de dessin haute performance (évite les setState)
class SignatureModel extends ChangeNotifier {
  final List<List<StrokePoint>> strokes = [];
  final List<StrokePoint> currentStroke = [];
  bool isDrawing = false;

  void startStroke(Offset pos, double pressure) {
    isDrawing = true;
    currentStroke.clear();
    currentStroke.add(StrokePoint(pos, pressure));
    notifyListeners(); // Déclenche uniquement le repaint du CustomPainter
  }

  void continueStroke(Offset pos, double pressure) {
    if (isDrawing) {
      currentStroke.add(StrokePoint(pos, pressure));
      notifyListeners();
    }
  }

  void endStroke() {
    if (isDrawing && currentStroke.length > 2) {
      strokes.add(List.from(currentStroke));
    }
    currentStroke.clear();
    isDrawing = false;
    notifyListeners();
  }

  void clear() {
    strokes.clear();
    currentStroke.clear();
    isDrawing = false;
    notifyListeners();
  }
}

// 🎨 Painter optimisé avec pression & vitesse
class OptimizedSignaturePainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final List<StrokePoint> currentStroke;
  final double baseWidth;
  final double maxWidth;

  OptimizedSignaturePainter({
    required this.strokes,
    required this.currentStroke,
    this.baseWidth = 2.0,
    this.maxWidth = 7.0,
  });

  double _calculateWidth(StrokePoint prev, StrokePoint curr, StrokePoint next) {
    // 1. Facteur pression (prioritaire pour les stylets)
    final pressure = curr.pressure.clamp(0.0, 1.0);

    // 2. Facteur vitesse (fallback pour écrans tactiles sans pression)
    final speed =
        ((curr.offset - prev.offset).distance +
            (next.offset - curr.offset).distance) /
        2;
    final speedFactor = (speed / 40).clamp(0.0, 1.0);

    // Combinaison dynamique : 70% pression, 30% vitesse
    final dynamicFactor = (pressure * 0.7) + (speedFactor * 0.3);

    // Plus la pression/vitesse est haute → trait plus fin (effet stylo plume réaliste)
    return baseWidth + (maxWidth - baseWidth) * (1 - dynamicFactor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    void drawStroke(List<StrokePoint> points) {
      if (points.length < 2) return;
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final next = i < points.length - 1 ? points[i + 1] : points[i];

        paint.strokeWidth = _calculateWidth(prev, curr, next);
        canvas.drawLine(prev.offset, curr.offset, paint);
      }
    }

    for (final stroke in strokes) drawStroke(stroke);
    if (currentStroke.length > 1) drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(covariant OptimizedSignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}
