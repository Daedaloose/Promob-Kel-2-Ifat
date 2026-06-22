#!/bin/bash
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:$PWD/flutter/bin"
flutter pub get
flutter build web --release