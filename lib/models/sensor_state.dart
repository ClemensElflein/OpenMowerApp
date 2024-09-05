class DoubleSensorState {
  final String name;

  double value = 0;
  final double minValue;
  final double maxValue;
  final bool hasMinMax;
  final double lowerCriticalValue;
  final bool hasCriticalLow;
  final double upperCricticalValue;
  final bool hasCriticalHigh;
  final String unit;

  DoubleSensorState(this.name, this.unit, this.minValue, this.maxValue, this.hasMinMax, this.lowerCriticalValue, this.hasCriticalLow, this.upperCricticalValue, this.hasCriticalHigh);
}