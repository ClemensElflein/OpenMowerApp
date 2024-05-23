import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:niku/namespace.dart' as n;

class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  Icon getMqttIcon(bool isConnected) {
    return isConnected
        ? Icon(Icons.link, color: Colors.green[300])
        : Icon(Icons.link_off, color: Colors.red[200]);
  }

  Icon getGpsIcon(percent) {
    // TODO: Need gps_enabled flag for a reliable gps_not_fixed/gps_off icon
    if (percent > 0.75) {
      return Icon(Icons.gps_fixed, color: Colors.green[200]);
    } else if (percent >= 0.25) {
      return Icon(Icons.gps_not_fixed, color: Colors.orange[200]);
    }
    return Icon(Icons.gps_off, color: Colors.grey[400]);
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
                    child: getMqttIcon(controller.robotState.value.isConnected),
                    alignment: PlaceholderAlignment.middle),
              ])),
          /*RichText(
              text: const TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                TextSpan(text: "WiFi: "),
                WidgetSpan(
                    child:
                        Icon(Icons.network_wifi_3_bar, color: Colors.black54),
                    alignment: PlaceholderAlignment.middle),
              ])),*/
          RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                const TextSpan(text: "GPS: "),
                WidgetSpan(
                    child: Obx(() => getGpsIcon(controller.robotState.value.gpsPercent)),
                    alignment: PlaceholderAlignment.middle),
              ])),
          RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                const TextSpan(text: "Battery: "),
                WidgetSpan(
                    child: Icon(getBatteryIcon(controller.robotState.value.batteryPercent, controller.robotState.value.isCharging), color: Colors.black54),
                    alignment: PlaceholderAlignment.middle),
              ]))
        ])
          ..mainAxisAlignment = MainAxisAlignment.end
          ..m = 16
          ..gap = 8));
  }

  IconData getBatteryIcon(double percentage, bool charging) {
    if(charging && percentage > 0.875){
      return Icons.battery_charging_full;
    }
    if(percentage > 0.875) {
      return Icons.battery_full;
    }
    if(percentage > 0.75) {
      return Icons.battery_6_bar;
    }
    if(percentage > 0.625) {
      return Icons.battery_5_bar;
    }
    if(percentage > 0.5) {
      return Icons.battery_4_bar;
    }
    if(percentage > 0.375) {
      return Icons.battery_3_bar;
    }
    if(percentage > 0.25) {
      return Icons.battery_2_bar;
    }
    if(percentage > 0.125) {
      return Icons.battery_1_bar;
    }
    return Icons.battery_0_bar;
  }
}
