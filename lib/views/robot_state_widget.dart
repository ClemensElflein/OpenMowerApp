import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:niku/namespace.dart' as n;

class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  IconData getGpsIcon(percent) {
    if(percent > 0.75) {
      return Icons.gps_fixed;
    }
    if(percent >= 0.25) {
      return Icons.gps_not_fixed;
    }
    return Icons.gps_off;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 5,
        child: Obx(() =>n.Row([
          RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                const TextSpan(text: "MQTT: "),
                WidgetSpan(
                    child:
                        Icon(controller.robotState.value.isConnected ? Icons.link : Icons.link_off, color: Colors.black54),
                    alignment: PlaceholderAlignment.middle),
              ])),
          RichText(
              text: const TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                TextSpan(text: "WiFi: "),
                WidgetSpan(
                    child:
                        Icon(Icons.network_wifi_3_bar, color: Colors.black54),
                    alignment: PlaceholderAlignment.middle),
              ])),
          RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                const TextSpan(text: "GPS: "),
                WidgetSpan(
                    child: Obx(() => Icon(getGpsIcon(controller.robotState.value.gpsPercent), color: Colors.black54)),
                    alignment: PlaceholderAlignment.middle),
              ])),
          RichText(
              text: const TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                TextSpan(text: "Battery: "),
                WidgetSpan(
                    child: Icon(Icons.battery_4_bar, color: Colors.black54),
                    alignment: PlaceholderAlignment.middle),
              ]))
        ])
          ..mainAxisAlignment = MainAxisAlignment.end
          ..m = 16
          ..gap = 8));
  }
}
