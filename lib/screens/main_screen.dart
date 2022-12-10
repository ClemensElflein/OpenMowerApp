import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/screens/dashboard.dart';
import 'package:open_mower_app/screens/sensor_values.dart';
import 'package:open_mower_app/screens/settings.dart';
import 'package:open_mower_app/screens/remote_control.dart';
import 'package:open_mower_app/views/logo_widget.dart';
import 'package:open_mower_app/views/logo_widget_drawer.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  final widgetList = <Widget>[
    Dashboard(),const SensorValues(),const Settings()
  ];

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _index = 0;

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
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: buildDrawerList(),
          ),
        ),
        body: widget.widgetList[_index]
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
                child: LogoWidgetDrawer(size: 0.1))),
      ),
      ListTile(
        leading: n.Icon(Icons.speed),
        title: const Text('Dashboard'),
        onTap: () {
          Get.back();
          setState(() {
            _index = 0;
          });
        },
      ),
      ListTile(
        leading: n.Icon(Icons.line_axis),
        title: const Text('Sensor Values'),
        onTap: () {
          Get.back();
          setState(() {
            _index = 1;
          });
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
          setState(() {
            _index = 2;
          });
        },
      ));
    }

    return drawerList;
  }

}
