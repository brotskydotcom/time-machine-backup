#!/bin/bash
#
# This wonderful script taken from:
# https://stackoverflow.com/a/20703594/558006
# License on it is https://creativecommons.org/licenses/by-sa/4.0/
#
# Run it where there's a 1024x1024 icon called Icon1024.png
#
mkdir AppIcon.iconset
sips -z 16 16     Icon1024.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32     Icon1024.png --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32     Icon1024.png --out AppIcon.iconset/icon_32x32.png
sips -z 64 64     Icon1024.png --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128   Icon1024.png --out AppIcon.iconset/icon_128x128.png
sips -z 256 256   Icon1024.png --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256   Icon1024.png --out AppIcon.iconset/icon_256x256.png
sips -z 512 512   Icon1024.png --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512   Icon1024.png --out AppIcon.iconset/icon_512x512.png
cp Icon1024.png AppIcon.iconset/icon_512x512@2x.png
iconutil -c icns AppIcon.iconset
rm -R AppIcon.iconset