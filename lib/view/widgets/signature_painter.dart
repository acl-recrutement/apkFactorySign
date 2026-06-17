// lib/view/widgets/signature_painter.dart
import 'package:flutter/material.dart';
import '../DedicatedSignaturePage.dart'; // ✅ Import pour accéder à StrokePoint

class SignaturePainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final List<StrokePoint> currentStroke;

  SignaturePainter(this.strokes, this.currentStroke);

  // 🎨 Calcul dynamique de l'épaisseur : 70% pression + 30% vitesse
  double _calculateWidth(StrokePoint p1, StrokePoint p2, StrokePoint p3) {
    final pressure = p2.pressure.clamp(0.0, 1.0);
    final speed =
        ((p2.offset - p1.offset).distance + (p3.offset - p2.offset).distance) /
        2;
    final speedFactor = (speed / 40).clamp(0.0, 1.0);
    final dynamicFactor = (pressure * 0.7) + (speedFactor * 0.3);
    // Plus pression/vitesse élevée = trait plus fin (effet stylo plume)
    return 2.0 + 5.0 * (1 - dynamicFactor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    // Fonction interne pour dessiner une série de points
    void drawStroke(List<StrokePoint> points) {
      if (points.length < 2) return;
      for (int i = 1; i < points.length; i++) {
        final p1 = points[i - 1];
        final p2 = points[i];
        final p3 = i < points.length - 1 ? points[i + 1] : points[i];

        paint.strokeWidth = _calculateWidth(p1, p2, p3);
        canvas.drawLine(p1.offset, p2.offset, paint);
      }
    }

    // Dessiner tous les traits terminés
    for (final stroke in strokes) {
      drawStroke(stroke);
    }

    // Dessiner le trait en cours
    if (currentStroke.length > 1) {
      drawStroke(currentStroke);
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}
