#!/bin/bash

rm -rf ./build
flutter clean
flutter build web --no-web-resources-cdn --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/

# Replace built files in the `open_mower_ros` folder, which must be present in the same parent folder
rm -rf ../open_mower_ros/web/

cp -r ./build/web ../open_mower_ros
