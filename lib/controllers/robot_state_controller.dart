import 'package:get/get.dart';
import 'package:open_mower_app/models/robot_state.dart';

class RobotStateController extends GetxController {
  final robotState = RobotState().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print("RSC ON INIT");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    print("RSC ON CLOSE");
  }

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
}