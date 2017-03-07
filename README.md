# InTallinn (app) 

A [travel tips app for visitors to Tallinn, Estonia](https://intallinn.ee). The code is written in Dart Flutter.  


## Content Assets

The content assets (photos and article text) are derived from
[https://github.com/ilikerobots/intallinn_content](intallinn_content).  To generate
this content, you will need to clone this repo to your filesystem.

The script "bin/sync_intallinn_content" must then be updated to point to this repo. E.g.
```dart
const INTALLINN_CONTENT_PATH = "/path/to/inTallinn_content/";
```

The sync script can then be run to sync image and article content:
```sh
dart bin/sync_intallinn_content.dart
```


## Building

You can follow these instructions to build the gallery app
and install it onto your device.

### Prereqs

If you are new to Flutter, please first follow
the [Flutter Setup](https://flutter.io/setup/) guide.

### Building and installing the Flutter app

* `flutter upgrade`
* `flutter run --release`

The `flutter run --release` command both builds and installs the Flutter app.

