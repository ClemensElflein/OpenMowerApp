import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:gauge_indicator/gauge_indicator.dart' as gauge_indicator;
import 'dart:math';
import 'temperature_gauge.dart';
import 'voltage_gauge_widget.dart';
import 'current_gauge_widget.dart';

class SensorWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    // Prepare some often used gauge vars for easier usage
    bool hasMinMax = (sensor?.hasMinMax ?? false);
    double minValue = (sensor?.minValue ?? 0);
    double maxValue = (sensor?.maxValue ?? 0);

    bool hasCriticalLow = (sensor?.hasCriticalLow ?? false);
    double lowerCriticalValue = (sensor?.lowerCriticalValue ?? 0);

    double minAxis = min(minValue, lowerCriticalValue);
    minAxis = (((minAxis + 5 - 1) / 5).toInt() * 5); // Next multiple of 5
    if (minAxis > 0) minAxis -= 5; // Previous multiple of 5

    switch (sensor?.unit.toUpperCase()) {
      case "RPM":
        // Use some reasonable defaults if not given
        lowerCriticalValue = hasCriticalLow ? lowerCriticalValue : 2300;
        minValue = hasMinMax ? minValue : 2800;
        maxValue = hasMinMax ? maxValue : 3800;

        return Material(
            elevation: 2,
            // RadialGauge Widget has issues with GaugeSegments when used in Column. Workaround by use of ListView
            child: n.ListView.children([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              gauge_indicator.RadialGauge(
                value: (sensor?.value ?? 0),
                axis: gauge_indicator.GaugeAxis(
                  max: maxValue,
                  degrees: 240,
                  progressBar: null,
                  segments: [
                    gauge_indicator.GaugeSegment(
                      from: 0,
                      to: lowerCriticalValue,
                      color: (Colors.red[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    gauge_indicator.GaugeSegment(
                      from: lowerCriticalValue,
                      to: minValue,
                      color: (Colors.orange[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    gauge_indicator.GaugeSegment(
                      from: minValue,
                      to: maxValue,
                      color: (Colors.green[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                  ],
                  style: const gauge_indicator.GaugeAxisStyle(
                    thickness: 10,
                    background: Colors.white54,
                    segmentSpacing: 4,
                  ),
                  pointer: const gauge_indicator.GaugePointer.triangle(
                      width: 15,
                      height: 20,
                      borderRadius: 1,
                      color: Colors.black54,
                      position: gauge_indicator.GaugePointerPosition.surface(
                          offset: Offset(0, 10)),
                      border: gauge_indicator.GaugePointerBorder(
                          color: Colors.white, width: 1)),
                ),
                child: n.Column([
                  (sensor?.unit ?? "rpm").bodyMedium..color = Colors.black54,
                  gauge_indicator.RadialGaugeLabel(
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    value: (sensor?.value ?? 0),
                  )
                ]),
              )
            ])
              ..p = 12
            //..center
            );
      case "A":
      case "V":
        // Vertical linear gauges
        return Material(
          elevation: 2,
          child: n.Row([
            Expanded(
                flex: 3,
                child: n.Column([
                  // 3 columns, evenly distributed
                  Expanded(
                      child: Container(
                          //color: Colors.green[50], child: Text("Col-Top")
                          )),
                  Expanded(
                      child: Container(
                          //color: Colors.yellow[50],
                          child: n.Column([
                    (sensor?.name ?? "N/A").bodyMedium
                      ..color = Colors.black54
                      ..center,
                    AutoSizeText(
                      "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit}",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    )
                  ]))),
                  Expanded(
                      child: Container(
                          //color: Colors.orange[50], child: Text("Col-Bot")
                          )),
                ])
                  ..center),
            Expanded(
                child: Container(
                    //color: Colors.blue[50],
                    child: Align(
                        alignment: Alignment.center,
                        child: (sensor?.unit.toUpperCase() == "V"
                            ? VoltageGaugeWidget(sensor: sensor)
                            : CurrentGaugeWidget(sensor: sensor)))))
          ])
            ..p = 12
            ..center,
        );
      default:
        // No, or horizontal gauge
        return Material(
            elevation: 2,
            child: n.Column([
              // 3 columns, evenly distributed
              Expanded(
                  child: Container(
                      //color: Colors.green[50], child: Text("Top-Col")
                      )),
              Expanded(
                  child: Container(
                      //color: Colors.yellow[50],
                      child: n.Column([
                (sensor?.name ?? "N/A").bodyMedium
                  ..color = Colors.black54
                  ..center,
                AutoSizeText(
                  "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit.replaceAll("deg.C", "°C")}",
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                )
              ]))),
              Expanded(
                  child: Container(
                      //color: Colors.orange[50],
                      child: (sensor?.unit.toUpperCase() == "DEG.C"
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: TemperatureGauge(sensor: sensor))
                          : null))),
            ])
              ..p = 12
              ..center);
    }
  }
}
