import 'package:get/get.dart';
import 'package:open_mower_app/models/robot_state.dart';
import 'package:open_mower_app/models/sensor_state.dart';

class SensorsController extends GetxController {
  final sensorStates = <String, DoubleSensorState>{}.obs;
}