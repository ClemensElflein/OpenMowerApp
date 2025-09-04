import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/views/emergency_widget.dart';
import 'package:niku/namespace.dart' as n;

class RobotStateWidget extends GetView<RobotStateController> {
  const RobotStateWidget({super.key});

  Widget getMqttWidget(bool isConnected) {
    final icon = isConnected
        ? const Icon(Icons.link, color: Colors.black54)
        : Icon(Icons.link_off, color: Colors.red[200]);
    
    final message = isConnected
        ? 'Connected'
        : 'Disconnected - check server connection';
        
    return Tooltip(
      message: message,
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      waitDuration: const Duration(milliseconds: 100),
      triggerMode: TooltipTriggerMode.tap,
      child: icon,
    );
  }

  Widget getWifiWidget() {
    if (controller.robotState.value.wifiPercent == 0) {
      // WiFi signal is not reported
      return const SizedBox.shrink();
    }

    const icon = Icon(Icons.network_wifi_3_bar, color: Colors.black54);
    
    // Convert wifiPercent to a human-readable format
    String wifiStrength;
    double percent = controller.robotState.value.wifiPercent;
    
    if (percent > 0.8) {
      wifiStrength = 'Excellent';
    } else if (percent > 0.6) {
      wifiStrength = 'Good';
    } else if (percent > 0.4) {
      wifiStrength = 'Moderate';
    } else if (percent > 0.2) {
      wifiStrength = 'Poor';
    } else {
      wifiStrength = 'Very Poor';
    }
    
    return Tooltip(
      message: 'WiFi Signal: $wifiStrength (${(percent * 100).toInt()}%)',
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      waitDuration: const Duration(milliseconds: 100),
      triggerMode: TooltipTriggerMode.tap,
      child: icon,
    );
  }

  Widget getGpsWidget(double percent) {
    Icon icon;
    String message;
    
    // Get GPS accuracy in centimeters
    double accuracyCm = controller.robotState.value.posAccuracy * 100;
    String accuracy = accuracyCm.toStringAsFixed(1); // Format to 1 decimal place
    
    if (percent > 0.75) {
      icon = Icon(Icons.gps_fixed, color: Colors.green[200]);
      message = 'GPS: strong\nAccuracy: $accuracy cm';
    } else if (percent >= 0.25) {
      icon = Icon(Icons.gps_not_fixed, color: Colors.orange[200]);
      message = 'GPS: moderate\nAccuracy: $accuracy cm';
    } else {
      icon = Icon(Icons.gps_off, color: Colors.grey[400]);
      message = 'GPS: weak or unavailable';
    }
    
    return Tooltip(
      message: message,
      textAlign: TextAlign.center,
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      waitDuration: const Duration(milliseconds: 100),
      triggerMode: TooltipTriggerMode.tap,
      child: icon,
    );
  }

  Widget getBatteryWidget(double percent, bool charging) {
    final icon = getBatteryIcon(percent, charging);
    String message;
    
    if (charging) {
      message = 'Battery: ${(percent * 100).toInt()}% (Charging)';
    } else {
      message = 'Battery: ${(percent * 100).toInt()}%';
    }
    
    return Tooltip(
      message: message,
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      waitDuration: const Duration(milliseconds: 100),
      triggerMode: TooltipTriggerMode.tap,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => n.Row([
          Tooltip(
            message: controller.robotState.value.isEmergency 
                ? 'Emergency Stop Activated'
                : 'Status: ${controller.robotState.value.currentState}',
            preferBelow: true,
            showDuration: const Duration(seconds: 3),
            waitDuration: const Duration(milliseconds: 100),
            triggerMode: TooltipTriggerMode.tap,
            child: EmergencyWidget(emergency: controller.robotState.value.isEmergency),
          ),
          getMqttWidget(controller.robotState.value.isConnected),
          getWifiWidget(),
          getGpsWidget(controller.robotState.value.gpsPercent),
          getBatteryWidget(controller.robotState.value.batteryPercent, controller.robotState.value.isCharging),
        ])
          ..mainAxisAlignment = MainAxisAlignment.end
          ..m = 8
          ..gap = 4);
  }

  /* Place this ugly function last.
   * Needs to be that ugly for not require --no-tree-shake-icons build option (Flutter >= 1.22),
   * which would disable Icon subsetting and thus blow up our code by about 350k
   */
  Icon getBatteryIcon(double percent, bool charging) {
    if (charging) {
      if (percent > 0.9) {
        return const Icon(MdiIcons.batteryCharging100, color: Colors.black54);
      } else if (percent > 0.8) {
        return const Icon(MdiIcons.batteryCharging90, color: Colors.black54);
      } else if (percent > 0.7) {
        return const Icon(MdiIcons.batteryCharging80, color: Colors.black54);
      } else if (percent > 0.6) {
        return const Icon(MdiIcons.batteryCharging70, color: Colors.black54);
      } else if (percent > 0.5) {
        return const Icon(MdiIcons.batteryCharging60, color: Colors.black54);
      } else if (percent > 0.4) {
        return const Icon(MdiIcons.batteryCharging50, color: Colors.black54);
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
        return const Icon(MdiIcons.battery, color: Colors.black54);
      } else if (percent > 0.8) {
        return const Icon(MdiIcons.battery90, color: Colors.black54);
      } else if (percent > 0.7) {
        return const Icon(MdiIcons.battery80, color: Colors.black54);
      } else if (percent > 0.6) {
        return const Icon(MdiIcons.battery70, color: Colors.black54);
      } else if (percent > 0.5) {
        return const Icon(MdiIcons.battery60, color: Colors.black54);
      } else if (percent > 0.4) {
        return const Icon(MdiIcons.battery50, color: Colors.black54);
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