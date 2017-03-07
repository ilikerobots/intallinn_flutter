import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'package:intallinn_app/app/intallinn.dart';

const enableDebbugingMenuItems = false;

Future<Null> main() async {
  debugPaintSizeEnabled = false;
  runApp(new IntallinnHome(
    enablePerformanceOverlay: enableDebbugingMenuItems,
    checkerboardRasterCacheImages: enableDebbugingMenuItems,
    enableTimeDilation: enableDebbugingMenuItems,
    enablePlatform: enableDebbugingMenuItems,
  ));
}
