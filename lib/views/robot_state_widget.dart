import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:niku/namespace.dart' as n;

class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  IconData getGpsIcon(percent) {
    if (percent > 0.75) {
      return Icons.gps_fixed;
    }
    if (percent >= 0.25) {
      return Icons.gps_not_fixed;
    }
    return Icons.gps_off;
  }

  @override
  Widget build(BuildContext context) {
    var stateWidgets = <Widget>[
      Obx(() => controller.robotState.value.currentState.h5..m = 4),
      Obx(() => controller.robotState.value.currentSubState.h6..m = 4),
    ];

    var stateCol = n.Column([
      Card(elevation: 3, child: n.Row(stateWidgets)..p = 16),
    ])
      ..p = 16
      ..mainAxisAlignment = MainAxisAlignment.start
      ..crossAxisAlignment = CrossAxisAlignment.start;

    var iconsCol = n.Column([
      Obx(() => n.Row([
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                  const TextSpan(text: "MQTT: "),
                  WidgetSpan(
                      child: Icon(
                          controller.robotState.value.isConnected
                              ? Icons.link
                              : Icons.link_off,
                          color: Colors.black54),
                      alignment: PlaceholderAlignment.middle),
                ])),
            // RichText(
            //       text: const TextSpan(
            //           style: TextStyle(color: Colors.black87),
            //           children: [
            //         TextSpan(text: "WiFi: "),
            //         WidgetSpan(
            //             child:
            //                 Icon(Icons.network_wifi_3_bar, color: Colors.black54),
            //             alignment: PlaceholderAlignment.middle),
            //       ])),
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                  const TextSpan(text: "GPS: "),
                  WidgetSpan(
                      child: Obx(() => Icon(
                          getGpsIcon(controller.robotState.value.gpsPercent),
                          color: Colors.black54)),
                      alignment: PlaceholderAlignment.middle),
                ])),
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                  const TextSpan(text: "Battery: "),
                  WidgetSpan(
                      child: Icon(
                              getBatteryIcon(
                                  controller.robotState.value.batteryPercent,
                                  controller.robotState.value.isCharging),
                              color: getBatteryColor(
                                  controller.robotState.value.batteryPercent,
                                  controller.robotState.value.isCharging)),

                      alignment: PlaceholderAlignment.middle),
                      TextSpan(text:
                        (controller.robotState.value.batteryPercent * 100)
                            .toStringAsFixed(0) +
                            "%",
                        style: TextStyle(fontSize: 12,color: Colors.black87),
                      ),
                ]))
          ])
            ..mainAxisAlignment = MainAxisAlignment.end
            ..m = 16
            ..gap = 8)
    ])
      ..p = 16
      ..expanded;

    return n.Row([stateCol, iconsCol]);
  }

  Color getBatteryColor(double percentage, bool charging) {
    if (charging) {
      return Colors.green;
    }

    return Colors.black54;
  }

  IconData getBatteryIcon(double percentage, bool charging) {
    if (charging && percentage > 0.875) {
      return Icons.battery_charging_full;
    }
    if (percentage > 0.875) {
      return Icons.battery_full;
    }
    if (percentage > 0.75) {
      return Icons.battery_6_bar;
    }
    if (percentage > 0.625) {
      return Icons.battery_5_bar;
    }
    if (percentage > 0.5) {
      return Icons.battery_4_bar;
    }
    if (percentage > 0.375) {
      return Icons.battery_3_bar;
    }
    if (percentage > 0.25) {
      return Icons.battery_2_bar;
    }
    if (percentage > 0.125) {
      return Icons.battery_1_bar;
    }
    return Icons.battery_0_bar;
  }
}
