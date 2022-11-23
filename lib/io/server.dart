import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

MqttClient get() {
  return MqttServerClient("","anon");
}

bool isWebSocket() {
  return false;
}