import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'temperature_gauge.dart';
import 'voltage_gauge_widget.dart';
import 'current_gauge_widget.dart';
import 'rpm_gauge_widget.dart';

class SensorWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    switch (sensor?.unit.toUpperCase()) {
      case "RPM":
        return Material(
            elevation: 2,
            // RadialGauge Widget has issues with GaugeSegments when used in Column and most other widgets.
            // But ListView is working
            child: n.ListView.children([RpmGaugeWidget(sensor: sensor)])
              ..p = 12
              ..primary = false // Disable scroll
            );
      case "A":
      case "V":
        // Vertical linear gauges
        return Material(
          elevation: 2,
          child: n.Row([
            // 2 rows in 3/1 flex
            Expanded(
                flex: 3,
                child: n.Column([
                  // 3 columns, evenly distributed
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: (sensor?.name ?? "N/A").bodyMedium
                            ..color = Colors.black54
                            ..textAlign = TextAlign.center)),
                  Expanded(
                      child: AutoSizeText(
                    "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit}",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  )),
                  Expanded(
                      child: Container(
                          //color: Colors.orange[50], child: Text("Col-Bot")
                          )),
                ])
                  ..center),
            Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: (sensor?.unit.toUpperCase() == "V"
                        ? VoltageGaugeWidget(sensor: sensor)
                        : CurrentGaugeWidget(sensor: sensor))))
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
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: (sensor?.name ?? "N/A").bodyMedium
                        ..color = Colors.black54
                        ..textAlign = TextAlign.center)),
              Expanded(
                  child: AutoSizeText(
                "${sensor?.value.toStringAsFixed(
                  sensor?.unit.toUpperCase() == "M" ? 3 : 2
                ) ?? "N/A"} ${sensor?.unit.replaceAll("deg.C", "°C")}",
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              )),
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
