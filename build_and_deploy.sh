#!/bin/bash

rm -rf ./build
flutter clean
flutter build web --web-renderer canvaskit

rm -rf ~/Dev/open_mower_ros/web

cp -r ./build/web ~/Dev/open_mower_ros
