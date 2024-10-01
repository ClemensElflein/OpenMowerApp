import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/screens/dashboard.dart';
import 'package:open_mower_app/screens/sensor_values.dart';
import 'package:open_mower_app/screens/settings.dart';
import 'package:open_mower_app/views/logo_widget.dart';
import 'package:open_mower_app/views/logo_widget_drawer.dart';

class MainScreen extends GetView<RobotStateController> {
  MainScreen({super.key});

  final widgetList = <Widget>[
    Dashboard(),const SensorValues(),const Settings()
  ];

  final _index = 0.obs;

  final RobotStateController robotStateController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const LogoWidget(size: 200),
          titleSpacing: 0,
          elevation: 10,
          shadowColor: Colors.black,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Column(children:<Widget>[
            Expanded(child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: buildDrawerList(),
            )), Obx(() => Text(robotStateController.softwareVersion.value).paddingAll(10))]),
        ),
        body: Obx(()=>widgetList[_index.value])
    );
  }

  List<Widget> buildDrawerList() {
    final drawerList = <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Padding(
            padding: EdgeInsets.all(24),
            child: FittedBox(
                child: LogoWidgetDrawer(size: 0.2))), // AH20240627 size 0.1 had issues with rendering 'n' and 'r' in android browser 
      ),
      ListTile(
        leading: n.Icon(Icons.speed),
        title: const Text('Dashboard'),
        onTap: () {
          Get.back();
          _index.value= 0;
        },
      ),
      ListTile(
        leading: n.Icon(Icons.line_axis),
        title: const Text('Sensor Values'),
        onTap: () {
          Get.back();
          _index.value= 1;
        },
      ),
    ];

    if(!kReleaseMode || !kIsWeb) {
      // show the settings screen on debug versions and on native versions
      drawerList.add(ListTile(
        leading: n.Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Get.back();
          _index.value= 2;
        },
      ));
    }

    return drawerList;
  }
}
