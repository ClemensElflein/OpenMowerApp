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
      mqttConnection.sendJoystick(callback.x, callback.z, false)
    }, time: const Duration(milliseconds: 20));

    // for safety, if joystick command wasnt changed for some time, send a 0
    debounce(joystickCommand, (callback) => {mqttConnection.sendJoystick(0,0, true)}
        , time: const Duration(milliseconds: 100));
  }

  void forceSendUpdate(value) {
    joystickCommand.value = value;
    // Make sure the update gets there
    mqttConnection.sendJoystick(value.x, value.z, true);
  }
}