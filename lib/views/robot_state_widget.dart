import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/views/emergency_widget.dart';
import 'package:niku/namespace.dart' as n;

/**
 * The widget that is being displayed in top right corner of the screen.
 * It shows:
 * - Emergency status
 * - MQTT connection status
 * - GPS status
 * - Battery status and percentage value
 */
class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  Icon getMqttIcon(bool isConnected) {
    return isConnected
        ? const Icon(Icons.link, color: Colors.black54)
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
          EmergencyWidget(emergency: controller.robotState.value.isEmergency),
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
                    child: getBatteryIcon(controller.robotState.value.batteryPercent, controller.robotState.value.isCharging),
                    alignment: PlaceholderAlignment.middle),
                TextSpan(
                  text: " ${(controller.robotState.value.batteryPercent * 100).toInt()}%",
                  style: TextStyle(
                    color: getBatteryColor(controller.robotState.value.batteryPercent),
                  ),
                )
              ]))
        ])
          ..mainAxisAlignment = MainAxisAlignment.end
          ..m = 16
          ..gap = 8));
  }

  Color getBatteryColor(double percent) {
    if (percent > 0.3) {
      return Colors.black54;
    } else if (percent > 0.2) {
      return Colors.orange[300]!;
    } else {
      return Colors.red[200]!;
    }
  }

  IconData getChargingBatteryIcon(double percent) {
    if (percent > 0.9) {
      return MdiIcons.batteryCharging100;
    } else if (percent > 0.8) {
      return MdiIcons.batteryCharging90;
    } else if (percent > 0.7) {
      return MdiIcons.batteryCharging80;
    } else if (percent > 0.6) {
      return MdiIcons.batteryCharging70;
    } else if (percent > 0.5) {
      return MdiIcons.batteryCharging60;
    } else if (percent > 0.4) {
      return MdiIcons.batteryCharging50;
    } else if (percent > 0.3) {
      return MdiIcons.batteryCharging40;
    } else if (percent > 0.2) {
      return MdiIcons.batteryCharging30;
    } else if (percent > 0.1) {
      return MdiIcons.batteryCharging20;
    } else {
      return MdiIcons.batteryCharging10;
    }
  }

  IconData getNonChargingBatteryIcon(double percent) {
    if (percent > 0.9) {
      return MdiIcons.battery;
    } else if (percent > 0.8) {
      return MdiIcons.battery90;
    } else if (percent > 0.7) {
      return MdiIcons.battery80;
    } else if (percent > 0.6) {
      return MdiIcons.battery70;
    } else if (percent > 0.5) {
      return MdiIcons.battery60;
    } else if (percent > 0.4) {
      return MdiIcons.battery50;
    } else if (percent > 0.3) {
      return MdiIcons.battery40;
    } else if (percent > 0.2) {
      return MdiIcons.battery30;
    } else if (percent > 0.1) {
      return MdiIcons.battery20;
    } else if (percent > 0) {
      return MdiIcons.battery10;
    } else {
      return MdiIcons.batteryUnknown;
    }
  }

  /**
   * It would indicate if battery is charging while docked.
   * It will be colored based on the battery charge level.
   */
  Icon getBatteryIcon(double percent, bool charging) {
    final iconData = charging ? getChargingBatteryIcon(percent) : getNonChargingBatteryIcon(percent);
    final color = percent == 0 ? Colors.grey[400]! : getBatteryColor(percent);
    return Icon(iconData, color: color);
  }
}