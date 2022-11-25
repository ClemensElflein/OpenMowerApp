import 'package:get/get.dart';
import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

class RobotStateController extends GetxController {
  final robotState = RobotState().obs;

  final map = MapModel().obs;

  var availableActions = <String>{}.obs;

  void start() {
    robotState.value.isRunning = true;
    robotState.refresh();
  }

  void stop() {
    robotState.value.isRunning = false;
    robotState.refresh();
  }

  void setConnected(bool isConnected) {
    robotState.value.isConnected = isConnected;
    robotState.refresh();
  }

  bool hasAction(String action) {
    return availableActions.contains(action);
  }

}