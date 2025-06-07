#!/bin/bash

rm -rf ./build
flutter clean
flutter build web --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/

rm -rf ~/Dev/open_mower_ros/web

cp -r ./build/web ~/Dev/open_mower_ros
