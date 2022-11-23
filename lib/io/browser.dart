import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

MqttClient get() {
 return MqttBrowserClient("","anon");
}


bool isWebSocket() {
 return true;
}