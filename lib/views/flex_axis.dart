import 'package:open_mower_app/models/sensor_state.dart';
import 'dart:math';

/// A simple class which simplifies the handling of
/// flixible axis lengths/data
class FlexAxisData {
  double minAxis = 0;
  double maxAxis = 100;
  double axisRange = 100;

  double minValue = 0;
  double maxValue = 0;

  bool hasCriticalLow = false;
  double lowerCriticalValue = 0;

  bool hasCriticalHigh = false;
  double upperCriticalValue = 0;

  compute(DoubleSensorState? sensor) {
    // Prepare some often used gauge vars for easier usage
    minValue = (sensor?.minValue ?? 0);
    maxValue = (sensor?.maxValue ?? 0);

    hasCriticalLow = (sensor?.hasCriticalLow ?? false);
    lowerCriticalValue = (sensor?.lowerCriticalValue ?? 0);

    hasCriticalHigh = (sensor?.hasCriticalHigh ?? false);
    upperCriticalValue = (sensor?.upperCriticalValue ?? 0);

    // Calculative axis values
    minAxis = min(minValue, lowerCriticalValue);
    maxAxis = max(maxValue, upperCriticalValue).ceilToDouble();
    axisRange = (maxAxis - minAxis);

    // Optimize minAxis value
    double axisDivider = axisRange / 4; // Lets assume 4 divider over the range
    minAxis = (((minAxis + axisDivider - 1) / axisDivider).toInt() * axisDivider).ceilToDouble(); // Prev ceil divider

    axisRange = (maxAxis - minAxis);
  }
}

mixin FlexAxis {
  final FlexAxisData _axisData = FlexAxisData();

  void computeFlexAxis(DoubleSensorState? sensor) => _axisData.compute(sensor);

  double get minAxis => _axisData.minAxis;
  double get maxAxis => _axisData.maxAxis;
  double get axisRange => _axisData.axisRange;

  double get minValue => _axisData.minValue;
  double get maxValue => _axisData.maxValue;

  bool get hasCriticalLow => _axisData.hasCriticalLow;
  double get lowerCriticalValue => _axisData.lowerCriticalValue;
  
  bool get hasCriticalHigh => _axisData.hasCriticalHigh;
  double get upperCriticalValue => _axisData.upperCriticalValue;
}
