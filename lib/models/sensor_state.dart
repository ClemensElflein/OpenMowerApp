class DoubleSensorState {
  final String name;

  double value = 0;
  final double minValue;
  final double maxValue;
  final String unit;

  DoubleSensorState(this.name, this.minValue, this.maxValue, this.unit);
}