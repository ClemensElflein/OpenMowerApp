import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/widgets/emergency_widget.dart';

class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  Icon getMqttIcon(bool isConnected) {
    return isConnected
        ? Icon(Icons.link, color: Colors.black54)
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
          EmergencyIconButton(emergency: controller.robotState.value.isEmergency),
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
              ]))
        ])
          ..mainAxisAlignment = MainAxisAlignment.end
          ..m = 16
          ..gap = 8));
  }

  /* Place this ugly function last.
   * Needs to be that ugly for not require --no-tree-shake-icons build option (Flutter >= 1.22),
   * which would disable Icon subsetting and thus blow up our code by about 350k
   */
  Icon getBatteryIcon(double percent, bool charging) {
    if (charging) {
      if (percent > 0.9) {
        return Icon(MdiIcons.batteryCharging, color: Colors.black54);
      } else if (percent > 0.8) {
        return Icon(MdiIcons.batteryCharging90, color: Colors.black54);
      } else if (percent > 0.7) {
        return Icon(MdiIcons.batteryCharging80, color: Colors.black54);
      } else if (percent > 0.6) {
        return Icon(MdiIcons.batteryCharging70, color: Colors.black54);
      } else if (percent > 0.5) {
        return Icon(MdiIcons.batteryCharging60, color: Colors.black54);
      } else if (percent > 0.4) {
        return Icon(MdiIcons.batteryCharging50, color: Colors.black54);
      } else if (percent > 0.3) {
        return Icon(MdiIcons.batteryCharging40, color: Colors.orange[300]);
      } else if (percent > 0.2) {
        return Icon(MdiIcons.batteryCharging30, color: Colors.orange[300]);
      } else if (percent > 0.1) {
        return Icon(MdiIcons.batteryCharging20, color: Colors.red[200]);
      } else {
        return Icon(MdiIcons.batteryCharging10, color: Colors.red[200]);
      }
    } else {
      if (percent > 0.9) { 
        return Icon(MdiIcons.battery, color: Colors.black54);
      } else if (percent > 0.8) {
        return Icon(MdiIcons.battery90, color: Colors.black54);
      } else if (percent > 0.7) {
        return Icon(MdiIcons.battery80, color: Colors.black54);
      } else if (percent > 0.6) {
        return Icon(MdiIcons.battery70, color: Colors.black54);
      } else if (percent > 0.5) {
        return Icon(MdiIcons.battery60, color: Colors.black54);
      } else if (percent > 0.4) {
        return Icon(MdiIcons.battery50, color: Colors.black54);
      } else if (percent > 0.3) {
        return Icon(MdiIcons.battery40, color: Colors.orange[300]);
      } else if (percent > 0.2) {
        return Icon(MdiIcons.battery30, color: Colors.orange[300]);
      } else if (percent > 0.1) {
        return Icon(MdiIcons.battery20, color: Colors.red[200]);
      } else if (percent > 0) {
        return Icon(MdiIcons.battery10, color: Colors.red[200]);
      } else {
        return Icon(MdiIcons.batteryUnknown, color: Colors.grey[400]);
      }
    }
  }
}