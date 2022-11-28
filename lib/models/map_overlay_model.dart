import 'dart:ui';

class MapOverlayModel {
    final List<OverlayPolygon> polygons = [];
}

class OverlayPolygon {
  final Path overlay;
  final bool isClosed;
  final double lineWidth;
  final String color;

  OverlayPolygon(this.overlay, this.isClosed, this.lineWidth, this.color);
}