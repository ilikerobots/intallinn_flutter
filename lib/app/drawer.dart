import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intallinn_app/app/intallinn_logo.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan({ TextStyle style, String url, String text }) : super(
      style: style,
      text: text ?? url,
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          UrlLauncher.launch(url);
        }
  );
}

class MainDrawerHeader extends StatefulWidget {
  const MainDrawerHeader({ Key key, this.light }) : super(key: key);

  final bool light;

  @override
  _MainDrawerHeaderState createState() =>
      new _MainDrawerHeaderState();
}

class _MainDrawerHeaderState extends State<MainDrawerHeader> {
  bool _logoHasName = true;
  bool _logoHorizontal = false;
  Map<int, Color> _swatch = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery
        .of(context)
        .padding
        .top;

    return new DrawerHeader(
        decoration: new IntallinnLogoDecoration(
          margin: new EdgeInsets.fromLTRB(
              12.0, 12.0 + systemTopPadding, 12.0, 12.0),
          style: _logoHasName ? _logoHorizontal ? IntallinnLogoStyle.horizontal
              : IntallinnLogoStyle.stacked
              : IntallinnLogoStyle.markOnly,
          textColor: config.light ? const Color(0xFF616161) : const Color(
              0xFF9E9E9E),
        ),
        duration: const Duration(milliseconds: 750),
        child: new GestureDetector(
            onLongPress: () {
              setState(() {
                _logoHorizontal = !_logoHorizontal;
                if (!_logoHasName)
                  _logoHasName = true;
              });
            },
            onTap: () {
              setState(() {
                _logoHasName = !_logoHasName;
              });
            },
            onDoubleTap: () {
              setState(() {
                final List<Map<int, Color>> options = <Map<int, Color>>[];
                if (_swatch != Colors.blue)
                  options.addAll(<Map<int, Color>>[
                    Colors.blue,
                    Colors.blue,
                    Colors.blue,
                    Colors.blue,
                    Colors.blue,
                    Colors.blue,
                    Colors.blue
                  ]);
                if (_swatch != Colors.amber)
                  options.addAll(
                      <Map<int, Color>>[Colors.amber, Colors.amber, Colors.amber
                      ]);
                if (_swatch != Colors.red)
                  options.addAll(
                      <Map<int, Color>>[Colors.red, Colors.red, Colors.red]);
                if (_swatch != Colors.indigo)
                  options.addAll(<Map<int, Color>>[
                    Colors.indigo, Colors.indigo, Colors.indigo]);
                if (_swatch != Colors.pink)
                  options.addAll(<Map<int, Color>>[Colors.pink]);
                if (_swatch != Colors.purple)
                  options.addAll(<Map<int, Color>>[Colors.purple]);
                if (_swatch != Colors.cyan)
                  options.addAll(<Map<int, Color>>[Colors.cyan]);
                _swatch = options[new math.Random().nextInt(options.length)];
              });
            }
        )
    );
  }
}

class MainDrawer extends StatelessWidget {
  MainDrawer({
    Key key,
    this.useLightTheme,
    this.onThemeChanged,
    this.timeDilation,
    this.onTimeDilationChanged,
    this.showPerformanceOverlay,
    this.onShowPerformanceOverlayChanged,
    this.checkerboardRasterCacheImages,
    this.onCheckerboardRasterCacheImagesChanged,
    this.onPlatformChanged,
    this.onSendFeedback,
  }) : super(key: key) {
    assert(onThemeChanged != null);
  }

  final bool useLightTheme;
  final ValueChanged<bool> onThemeChanged;

  final double timeDilation;
  final ValueChanged<double> onTimeDilationChanged;

  final bool showPerformanceOverlay;
  final ValueChanged<bool> onShowPerformanceOverlayChanged;

  final bool checkerboardRasterCacheImages;
  final ValueChanged<bool> onCheckerboardRasterCacheImagesChanged;

  final ValueChanged<TargetPlatform> onPlatformChanged;

  final VoidCallback onSendFeedback;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle aboutTextStyle = themeData.textTheme.body2;
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith(
        color: themeData.accentColor);


    final Widget themeSwitchItem = new DrawerItem(
        icon: new Icon(Icons.brightness_5),
        selected: false,
        child: new Row(
            children: <Widget>[
              new Expanded(child: new Text('Use dark theme')),
              new Switch(
                  value: !useLightTheme,
                  onChanged: (bool val) => onThemeChanged(!val)
              )
            ]
        )
    );


    final Widget sendFeedbackItem = new DrawerItem(
      icon: new Icon(Icons.comment),
      onPressed: onSendFeedback ?? () {
        UrlLauncher.launch('https://twitter.com/inTallinnEE');
      },
      child: new Text('Ask us!'),
    );

    final Widget aboutItem = new AboutDrawerItem(
        icon: new IntallinnLogo(),
        applicationVersion: '',
        applicationIcon: new IntallinnLogo(),
        applicationLegalese: '© 2017 StarHeight Media',
        aboutBoxChildren: <Widget>[
          new Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: new RichText(
                  text: new TextSpan(
                      children: <TextSpan>[
                        new TextSpan(
                            style: aboutTextStyle,
                            text: "inTallinn offers hints and tips from a pair of "
                                "Tallinn locals who love Tallinn.  inTallinn is not "
                                "affiliated with nor sponsored by any official tourism or "
                                "government organization. The information and views in this "
                                "website are our own and do not necessarily reflect the "
                                "opinion of anyone but ourselves. "
                        ),
                        new TextSpan(
                            style: aboutTextStyle,
                            text: "\n\nVisit the website at "
                        ),
                        new LinkTextSpan(
                            style: linkStyle,
                            url: 'https://intallinn.ee'
                        ),
                        new TextSpan(
                            style: aboutTextStyle,
                            text: "\n\nThis app is "
                        ),
                        new LinkTextSpan(
                            style: linkStyle,
                            url: 'https://github.com/ilikerobots/intallinn_flutter',
                            text: 'open source'
                        ),
                        new TextSpan(
                            style: aboutTextStyle,
                            text: "."
                        )
                      ]
                  )
              )
          )
        ]
    );

    final List<Widget> allDrawerItems = <Widget>[
      new MainDrawerHeader(light: useLightTheme),
      themeSwitchItem,
      new Divider(),
      sendFeedbackItem,
      aboutItem
    ];

    final List<Widget> debuggingDrawerItems = <Widget>[];

    if (onPlatformChanged != null) {
      debuggingDrawerItems.add(new DrawerItem(
      // on iOS, we don't want to show an Android phone icon
          icon: new Icon(
              defaultTargetPlatform == TargetPlatform.iOS ? Icons.star : Icons
                  .phone_android),
          onPressed: () {
            onPlatformChanged(TargetPlatform.android);
          },
          selected: Theme
              .of(context)
              .platform == TargetPlatform.android,
          child: new Row(
              children: <Widget>[
                new Expanded(child: new Text('Android')),
                new Radio<TargetPlatform>(
                  value: TargetPlatform.android,
                  groupValue: Theme
                      .of(context)
                      .platform,
                  onChanged: onPlatformChanged,
                )
              ]
          )
      )
      );

      debuggingDrawerItems.add(new DrawerItem(
      // on iOS, we don't want to show the iPhone icon
          icon: new Icon(defaultTargetPlatform == TargetPlatform.iOS
              ? Icons.star_border
              : Icons.phone_iphone),
          onPressed: () {
            onPlatformChanged(TargetPlatform.iOS);
          },
          selected: Theme
              .of(context)
              .platform == TargetPlatform.iOS,
          child: new Row(
              children: <Widget>[
                new Expanded(child: new Text('iOS')),
                new Radio<TargetPlatform>(
                  value: TargetPlatform.iOS,
                  groupValue: Theme
                      .of(context)
                      .platform,
                  onChanged: onPlatformChanged,
                )
              ]
          )
      )
      );
      debuggingDrawerItems.add(new Divider());
    }


    if (onTimeDilationChanged != null) {
      debuggingDrawerItems.add(new DrawerItem(
          icon: new Icon(Icons.hourglass_empty),
          selected: timeDilation != 1.0,
          onPressed: () {
            onTimeDilationChanged(timeDilation != 1.0 ? 1.0 : 20.0);
          },
          child: new Row(
              children: <Widget>[
                new Expanded(child: new Text('Animate Slowly')),
                new Checkbox(
                    value: timeDilation != 1.0,
                    onChanged: (bool value) {
                      onTimeDilationChanged(value ? 20.0 : 1.0);
                    }
                )
              ]
          )
      )
      );
    }


    if (onShowPerformanceOverlayChanged != null) {
      debuggingDrawerItems.add(new DrawerItem(
          icon: new Icon(Icons.assessment),
          onPressed: () {
            onShowPerformanceOverlayChanged(!showPerformanceOverlay);
          },
          selected: showPerformanceOverlay,
          child: new Row(
              children: <Widget>[
                new Expanded(child: new Text('Performance Overlay')),
                new Checkbox(
                    value: showPerformanceOverlay,
                    onChanged: (bool value) {
                      onShowPerformanceOverlayChanged(!showPerformanceOverlay);
                    }
                )
              ]
          )
      ));
    }

    if (onCheckerboardRasterCacheImagesChanged != null) {
      debuggingDrawerItems.add(new DrawerItem(
          icon: new Icon(Icons.assessment),
          onPressed: () {
            onCheckerboardRasterCacheImagesChanged(
                !checkerboardRasterCacheImages);
          },
          selected: checkerboardRasterCacheImages,
          child: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text('Checkerboard Raster Cache Images')),
                new Checkbox(
                    value: checkerboardRasterCacheImages,
                    onChanged: (bool value) {
                      onCheckerboardRasterCacheImagesChanged(
                          !checkerboardRasterCacheImages);
                    }
                )
              ]
          )
      ));
    }

    if (debuggingDrawerItems.length > 0) {
      allDrawerItems.add(new Divider());
      allDrawerItems.addAll(debuggingDrawerItems);
    }

    return new Drawer(child: new ListView(children: allDrawerItems));
  }
}
