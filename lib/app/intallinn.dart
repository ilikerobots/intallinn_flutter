import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:in_tallinn_content/structure/site_structure.dart';
import 'package:in_tallinn_content/structure/page.dart';
import 'package:in_tallinn_content/structure/page_section.dart';
import 'package:in_tallinn_content/structure/content_page.dart';

import 'package:intallinn_app/markdown/markdown_converter.dart';
import 'package:intallinn_app/app/preferences.dart';
import 'package:intallinn_app/app/favorites.dart';
import 'package:intallinn_app/app/drawer.dart';


String sectionImagePath(PageSection p) =>
    "assets/image/section/${p.photoId.id.toLowerCase()}.jpg";

bool isSectionPage(Page p) => p.includeInNav && p is ContentPage;

typedef void LinkCallback(String href);

class IntallinnHome extends StatefulWidget {
  IntallinnHome({ Key key,
    this.enablePerformanceOverlay: false,
    this.checkerboardRasterCacheImages: false,
    this.enableTimeDilation: false,
    this.enablePlatform: false,
    this.onSendFeedback}) : super(key: key);

  static const String routeName = '/intallinnpesto';

  final bool enablePerformanceOverlay;

  final bool checkerboardRasterCacheImages;

  final bool enableTimeDilation;

  final bool enablePlatform;

  final VoidCallback onSendFeedback;

  @override
  IntallinnHomeState createState() => new IntallinnHomeState();
}

class IntallinnHomeState extends State<IntallinnHome>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  bool _useLightTheme = true;
  bool _showPerformanceOverlay = false;
  bool _checkerboardRasterCacheImages = false;
  double _timeDilation = 1.0;
  TargetPlatform _platform = defaultTargetPlatform;

  Timer _timeDilationTimer;

  @override
  void initState() {
    super.initState();

    new Preferences().read().then((Preferences prefs) {
      setState(() {
        _useLightTheme = !prefs.useDarkTheme;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      new MaterialApp(
          title: 'inTallinn',
          color: Colors.grey[500],
          theme: (_useLightTheme ? kTheme : kThemeDark).copyWith(
              platform: _platform),
          showPerformanceOverlay: _showPerformanceOverlay,
          checkerboardRasterCacheImages: _checkerboardRasterCacheImages,
          home: new ContentSectionGridPage(
            useLightTheme: _useLightTheme,
            onThemeChanged: (bool value) {
              setState(() {
                _useLightTheme = value;
              });
              new Preferences()
                ..useDarkTheme = !value
                ..store();
            },
            showPerformanceOverlay: _showPerformanceOverlay,
            onShowPerformanceOverlayChanged: config.enablePerformanceOverlay ? (
                bool value) {
              setState(() {
                _showPerformanceOverlay = value;
              });
            } : null,
            checkerboardRasterCacheImages: _checkerboardRasterCacheImages,
            onCheckerboardRasterCacheImagesChanged: config
                .checkerboardRasterCacheImages ? (bool value) {
              setState(() {
                _checkerboardRasterCacheImages = value;
              });
            } : null,
            onPlatformChanged: config.enablePlatform ? (TargetPlatform value) {
              setState(() {
                _platform = value;
              });
            } : null,
            timeDilation: _timeDilation,
            onTimeDilationChanged: config.enableTimeDilation ? (double value) {
              setState(() {
                _timeDilationTimer?.cancel();
                _timeDilationTimer = null;
                _timeDilation = value;
                if (_timeDilation > 1.0) {
                  // We delay the time dilation change long enough that the user can see
                  // that the checkbox in the drawer has started reacting, then we slam
                  // on the brakes so that they see that the time is in fact now dilated.
                  _timeDilationTimer =
                  new Timer(const Duration(milliseconds: 150), () {
                    timeDilation = _timeDilation;
                  });
                } else {
                  timeDilation = _timeDilation;
                }
              });
            } : null,
            onSendFeedback: config.onSendFeedback,
          )
      );
}

//const String _kSmallLogoImage = 'packages/flutter_gallery_assets/pesto/logo_small.png';
//const String _kMediumLogoImage = 'packages/flutter_gallery_assets/pesto/logo_medium.png';
//const double _kAppBarHeight = 128.0;
const double _kAppBarHeight = 164.0;
const double _kFabHalfSize = 28.0; // TODO(mpcomplete): needs to adapt to screen size
const double _kSectionPageMaxWidth = 500.0;

const Map<int, Color> EstonianBlue = const <int, Color>{
  50: const Color(0xFF0072CE),
  100: const Color(0xFF0072CE),
  200: const Color(0xFF0072CE),
  300: const Color(0xFF0072CE),
  400: const Color(0xFF0072CE),
  500: const Color(0xFF0072CE),
  600: const Color(0xFF0072CE),
  700: const Color(0xFF0072CE),
  800: const Color(0xFF0072CE),
  900: const Color(0xFF0072CE),
};

final ThemeData kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: EstonianBlue,
  accentColor: EstonianBlue[400],
);


final ThemeData kThemeDark = new ThemeData(
  brightness: Brightness.dark,
  primarySwatch: EstonianBlue,
  accentColor: Colors.lightBlueAccent[200],
);

class IntallinnStyle extends TextStyle {
  const IntallinnStyle({
    double fontSize: 12.0,
    FontWeight fontWeight,
    Color color: Colors.black87,
    double letterSpacing,
    double height,
    String fontFamily: 'Quicksand',
  }) : super(
    inherit: false,
    color: color,
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    textBaseline: TextBaseline.alphabetic,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// Displays a grid of section cards.
class ContentSectionGridPage extends StatefulWidget {
  ContentSectionGridPage({
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
  _ContentSectionGridPageState createState() =>
      new _ContentSectionGridPageState();
}

class _ContentSectionGridPageState extends State<ContentSectionGridPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Page> sections = [];
  List<Tab> myTabs = [];
  TabController _controller;

  @override
  void initState() {
    super.initState();
    sections = SiteStructure.pages.where(isSectionPage).toList();
    sections.forEach((Page p) {
      myTabs.add(new Tab(text: p.title));
    });
    _controller = new TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle logoStyle = const IntallinnStyle(fontSize: 24.0,
        fontWeight: FontWeight.w200,
        color: Colors.white,
        fontFamily: "AlegreyaSansSC");

    final double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    return new Theme(
        data: Theme.of(context).copyWith(
            platform: Theme
                .of(context)
                .platform,
            indicatorColor: Colors.white,
            primaryTextTheme: Theme
                .of(context)
                .primaryTextTheme
                .copyWith(
            // Tabs
              body2: Theme
                  .of(context)
                  .primaryTextTheme
                  .body2
                  .copyWith(fontFamily: "Quicksand"),
            )
        ),
        child: new Scaffold(
            key: scaffoldKey,
            drawer: new MainDrawer(
              useLightTheme: config.useLightTheme,
              onThemeChanged: config.onThemeChanged,
              timeDilation: config.timeDilation,
              onTimeDilationChanged: config.onTimeDilationChanged,
              showPerformanceOverlay: config.showPerformanceOverlay,
              onShowPerformanceOverlayChanged: config
                  .onShowPerformanceOverlayChanged,
              checkerboardRasterCacheImages: config
                  .checkerboardRasterCacheImages,
              onCheckerboardRasterCacheImagesChanged: config
                  .onCheckerboardRasterCacheImagesChanged,
              onPlatformChanged: config.onPlatformChanged,
              onSendFeedback: config.onSendFeedback,
            ),
            appBar: new AppBar(
              title: new Text('inTallinn', style: logoStyle),

              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.collections_bookmark),
                  tooltip: 'Show Favorites',
                  onPressed: () {
                    showFavoritesPage(context);
                  },
                ),
              ],
              bottom: new TabBar(
                tabs: myTabs,
                isScrollable: true,
                controller: _controller,
              ),
            ),

            body: new TabBarView(
                controller: _controller,
                children: sections.map((Page p) {
                  return _buildBodyPlainGrid(context, statusBarHeight, p);
                }).toList()
            )
        )
    );
  }

  void processLink(String url) {
    Uri uri = Uri.parse(url);
    if (uri.hasScheme) {
      UrlLauncher.launch(uri.toString());
    } else {
      List<String> parts = uri.toString().split("#");
      String page = parts[0];
      String section = "";
      if (parts.length > 1) {
        section = parts[1];
        PageSection sec = SiteStructure.getSection(section);
        Navigator.push(context, new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: "/section"),
          builder: (BuildContext context) {
            return new Theme(
              data: Theme.of(context).copyWith(platform: Theme
                  .of(context)
                  .platform),
              child: new ContentSectionPage(section: sec),
            );
          },
        ));
      } else { //no section provided, go to tab
        int tabIndex = -1;
        List<String> tabs = sections.map((Page p) => p.id).toList();
        for (int i = 0; i < tabs.length; i++) {
          if (tabs[i] == page) {
            tabIndex = i;
            break;
          }
        }
        if (tabIndex >= 0) {
          Navigator.pop(context);
          _controller.index = tabIndex;
        }
      }
    }
  }


  Widget _buildBodyPlainGrid(BuildContext context, double statusBarHeight,
      Page p) {
    final double width = MediaQuery
        .of(context)
        .size
        .width;
    //one col per 320 px with a min and max
    final minCols = 1;
    final maxCols = 4;
    final int cols = math.max(
        minCols, math.min(maxCols, (width / 240.0).floor()));

    List<PageSection> sections = [];
    if (p is ContentPage) {
      sections.addAll(p.sections);
    }

    return new GridView.count(
      crossAxisCount: cols,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      childAspectRatio: 4.0 / 3.0,
      children: sections.map((PageSection sec) {
        return new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: new ContentSectionCard(
              section: sec,
              onTap: () {
                showSectionPage(context, sec);
              },
            )

        );
      }).toList(),
    );
  }


  void showFavoritesPage(BuildContext context) {
    Navigator.of(context).push(new PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return new FavoritesPage();
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return new SlideTransition(
            position: new Tween<FractionalOffset>(
                begin: new FractionalOffset(-1.0, 0.0),
                end: new FractionalOffset(0.0, 0.0)
            ).animate(animation),
            child: child,
          );
        }
    ));
  }

  void showSectionPage(BuildContext context, PageSection section) {
    Navigator.push(context, new MaterialPageRoute<Null>(
      settings: const RouteSettings(name: "/section"),
      builder: (BuildContext context) {
        return new Theme(
          data: Theme.of(context).copyWith(platform: Theme
              .of(context)
              .platform),
          child: new ContentSectionPage(
              section: section, onTapLink: processLink),
        );
      },
    ));
  }
}


// A card displaying a summary of the section (photo/title/etc)
class ContentSectionCard extends StatelessWidget {

  ContentSectionCard({ Key key, this.section, this.onTap}) : super(key: key);

  final PageSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(
        fontSize: 24.0, fontWeight: FontWeight.w500, fontFamily: "Quicksand");


    return new GestureDetector(
      onTap: onTap,
      child: new Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Hero(
                tag: section.photoId.id,
                child: new Image.asset(
                    sectionImagePath(section), fit: ImageFit.contain)
            ),
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new Icon(new IconData(section.icon_data))
                  ),
                  new Expanded(
                    child:
                    new Text(section.title, style: titleStyle,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Displays one section
class ContentSectionPage extends StatefulWidget {
  ContentSectionPage({ Key key, this.section, this.onTapLink })
      : super(key: key);

  final PageSection section;
  final LinkCallback onTapLink;

  @override
  _ContentSectionPageState createState() => new _ContentSectionPageState();
}

class _ContentSectionPageState extends State<ContentSectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextStyle menuItemStyle = new IntallinnStyle(
      fontSize: 15.0, color: Colors.black54, height: 24.0 / 15.0);

  List<PageSection> favorites;
  bool isFavorite = false;

//  double _getAppBarHeight(BuildContext context) => MediaQuery.of(context).size.height * 0.3;
  double _getAppBarHeight(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .height * 0.25;

  void initState() {
    super.initState();
    new Preferences().read().then((Preferences prefs) {
      setState(() {
        favorites = prefs.favoriteSections;
        isFavorite = favorites.contains(config.section);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // The full page content with the section's image behind it. This
    // adjusts based on the size of the screen. If the section sheet touches
    // the edge of the screen, use a slightly different layout.
    final double appBarHeight = _getAppBarHeight(context);
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final bool fullWidth = (screenSize.width < _kSectionPageMaxWidth);
    return new Scaffold(
      key: _scaffoldKey,
      body: new Stack(
        children: <Widget>[
          new Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: appBarHeight + _kFabHalfSize,
            child: new Hero(
              tag: config.section.photoId.id,
              child: new Image.asset(
                sectionImagePath(config.section),
                fit: fullWidth ? ImageFit.fitWidth : ImageFit.cover,
              ),
            ),
          ),
          new CustomScrollView(
            slivers: <Widget>[
              new SliverAppBar(
                expandedHeight: appBarHeight - _kFabHalfSize,
                backgroundColor: Colors.transparent,
                flexibleSpace: new FlexibleSpaceBar(
                  background: new DecoratedBox(
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                        begin: const FractionalOffset(0.5, 0.2),
                        end: const FractionalOffset(0.5, 0.60),
                        colors: <Color>[
                          const Color(0x90000000), const Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
              new SliverToBoxAdapter(
                  child: new Stack(
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.only(top: _kFabHalfSize),
                        width: fullWidth ? null : _kSectionPageMaxWidth,
                        child: new ContentSectionSheet(
                            section: config.section,
                            onTapLink: config.onTapLink),
                      ),
                      new Positioned(
                        right: 16.0,
                        child: new FloatingActionButton(
                          child: new Icon(isFavorite ? Icons.bookmark : Icons
                              .bookmark_border),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Null> _toggleFavorite() async {
    Preferences f = new Preferences();
    await f.read();
    setState(() {
      isFavorite = !isFavorite;
      if (f.favoriteSections.contains(config.section))
        f.favoriteSections.remove(config.section);
      else
        f.favoriteSections.add(config.section);
      f.store();
    });
  }


}

/// Displays the section full layout
class ContentSectionSheet extends StatefulWidget {
  final TextStyle descriptionStyle = const IntallinnStyle(
      fontSize: 15.0, color: Colors.black54, height: 24.0 / 15.0);
  final TextStyle itemStyle = const IntallinnStyle(
      fontSize: 15.0, height: 24.0 / 15.0);
  final TextStyle itemAmountStyle = new IntallinnStyle(
      fontSize: 15.0, color: kTheme.primaryColor, height: 24.0 / 15.0);
  final TextStyle headingStyle = const IntallinnStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, height: 24.0 / 15.0);

  ContentSectionSheet({ Key key, this.section, this.onTapLink})
      : super(key: key);

  final PageSection section;
  final LinkCallback onTapLink;

  _ContentSectionSheetState createState() =>
      new _ContentSectionSheetState();

}

class _ContentSectionSheetState extends State<ContentSectionSheet> {

  String _markdownContent = "";

  @override
  void initState() {
    super.initState();
    _loadAsset('assets/content/${config.section.id}.md').then((String content) {
      setState(() {
        _markdownContent = content;
      });
    });
  }

  Future<String> _loadAsset(String assetName) =>
      rootBundle.loadString(assetName);

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(fontSize: 34.0, fontFamily: "Quicksand");

    final ThemeData mdThemeData = Theme.of(context).copyWith(
      textTheme: new TextTheme(
        body1: Theme
            .of(context)
            .textTheme
            .body1
            .copyWith(
          fontFamily: 'Quicksand',
          fontSize: 14.0,
        ),
        title: Theme
            .of(context)
            .textTheme
            .headline
            .copyWith(
          fontFamily: 'Quicksand',
        ),
        subhead: Theme
            .of(context)
            .textTheme
            .subhead
            .copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w600
        ),
        body2: Theme
            .of(context)
            .textTheme
            .body1
            .copyWith(
            fontSize: 12.0
        ),
      ),
    );


    return new Material(


        child: new Material(
          type: MaterialType.card,
          elevation: 0,
          child: new Padding(
            padding: const EdgeInsets.only(
                left: 4.0, top: 8.0, right: 4.0, bottom: 4.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: new Text(
                          config.section.title, style: titleStyle),
                    ),
                  ],
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new SizedBox(height: 24.0),
                      //sampleRichText(context),
                      new MarkdownBody(
                          onTapLink: config.onTapLink,
                          data: new MarkdownConverter().convert(
                              _markdownContent),
                          markdownStyle: new MarkdownStyle.defaultFromTheme(
                              mdThemeData)
                      ),
                      new SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }


}


