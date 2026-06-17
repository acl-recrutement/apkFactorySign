// lib/view/widgets/stroke_point.dart
import 'dart:ui';

/// Point de signature avec position + pression du stylet
class StrokePoint {
  final Offset offset;
  final double pressure; // 0.0 (léger) à 1.0 (fort)

  const StrokePoint(this.offset, this.pressure);
}
