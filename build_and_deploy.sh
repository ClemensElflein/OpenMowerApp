#!/bin/bash

flutter build web --web-renderer canvaskit

rm -rf ~/Dev/open_mower_ros/web

cp -r ./build/web ~/Dev/open_mower_ros
