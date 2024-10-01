import 'package:open_mower_app/models/sensor_state.dart';
import 'dart:math';

/// A simple class which simplifies the handling of
/// flexible axis lengths/data
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

  /// Compute some often used axis vars for easier usage
  compute(DoubleSensorState? sensor, double maxAxisDefault) {
    minValue = (sensor?.minValue ?? 0);
    maxValue = (sensor?.maxValue ?? 0);

    hasCriticalLow = (sensor?.hasCriticalLow ?? false);
    lowerCriticalValue = (sensor?.lowerCriticalValue ?? 0);

    hasCriticalHigh = (sensor?.hasCriticalHigh ?? false);
    upperCriticalValue = (sensor?.upperCriticalValue ?? 0);

    // Calculative axis values
    minAxis = min(minValue, lowerCriticalValue).floorToDouble();
    maxAxis = max(maxValue, upperCriticalValue).ceilToDouble();

    // Some reasonable default if we don't have a maxValue nor upperCritical
    if (maxAxis == 0) maxAxis = maxAxisDefault;

    axisRange = (maxAxis - minAxis);

    // GeekyAnts linear gauge, at least the vertical one, has issue with misplaced pointer,
    // if the axisRange is > 1 but uneven (i.e. with an axis range of 9)
    if (axisRange > 1 && axisRange.floor().isOdd) {
      if (minAxis.floor().isOdd) {
        minAxis--;
      } else {
        maxAxis++;
      }
      axisRange = (maxAxis - minAxis);
    }
  }
}

/// A simple mixin which simplifies the handling of
/// flexible axis lengths/data in gauge widgets
mixin FlexAxis {
  final FlexAxisData _axisData = FlexAxisData();

  /// Compute the flexible axis values out of the [sensor]'s thresholds.
  /// Use some reasonable [maxAxisDefault] for those cases where the maxAxis value can't be calculated
  /// because the sensor has no max- nor upperCritical- Value.
  void computeFlexAxis(DoubleSensorState? sensor, double maxAxisDefault) =>
      _axisData.compute(sensor, maxAxisDefault);

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
