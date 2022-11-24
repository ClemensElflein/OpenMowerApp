import 'package:get/get.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/joystick_command.dart';

class RemoteController extends GetxController {

  final MqttConnection mqttConnection = Get.find();
  final joystickCommand = const JoystickCommand(0,0).obs;

  @override
  void onInit() {
    super.onInit();

    interval(joystickCommand, (callback) => {
      mqttConnection.sendJoystick(callback.x, callback.z)
    }, time: const Duration(milliseconds: 20));
  }
}