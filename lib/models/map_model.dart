import 'dart:ui';

class MapModel {
    final List<MapAreaModel> navigationAreas = [];
    final List<MapAreaModel> mowingAreas = [];
    double width = 0, height = 0, centerX = 0, centerY = 0;
}

class MapAreaModel {
  final Path outline;
  final List<Path> obstacles;

  MapAreaModel(this.outline, this.obstacles);
}