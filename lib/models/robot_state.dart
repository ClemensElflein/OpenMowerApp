import 'package:open_mower_app/models/sensor_state.dart';

class RobotState {
  String name = "Open Mower";
  double wifiPercent = 0.0;
  double gpsPercent = 0.0;
  double batteryPercent = 0.0;

  String currentState = "Unknown";
  String currentSubState = "Unknown";

  bool isRunning = false;

  bool isConnected = false;
}