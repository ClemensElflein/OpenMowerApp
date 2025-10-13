import 'dart:ui';

class MapModel {
    final List<Path> navigationAreas = [];
    final List<Path> mowingAreas = [];
    final List<Path> obstacles = [];
    double width = 0, height = 0, centerX = 0, centerY = 0, dockX = 0, dockY = 0, dockHeading = 0;
}
