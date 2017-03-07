import 'package:collection/collection.dart' show lowerBound;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:in_tallinn_content/structure/site_structure.dart';
import 'package:in_tallinn_content/structure/page.dart';
import 'package:in_tallinn_content/structure/page_section.dart';

import 'package:intallinn_app/app/preferences.dart';
import 'package:intallinn_app/app/intallinn.dart';


// Displays a list of favorites sections.
class FavoritesPage extends StatefulWidget {
  FavoritesPage({ Key key}) : super(key: key);

  @override
  _FavoritesPageState createState() =>
      new _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  List<PageSection> favorites = [];

  @override
  void initState() {
    super.initState();
    new Preferences().read().then((Preferences prefs) {
      setState(() {
        favorites = prefs.favoriteSections;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle logoStyle = const IntallinnStyle(fontSize: 24.0,
        fontWeight: FontWeight.w200,
        color: Colors.white,
        fontFamily: "AlegreyaSansSC");

    List<Tab> myTabs = [];
    SiteStructure.pages.where((Page p) => p.includeInNav).forEach((Page p) {
      myTabs.add(new Tab(text: p.title));
    });


    return new Theme(
        data: Theme.of(context).copyWith(
            platform: Theme
                .of(context)
                .platform,
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
        child: new DefaultTabController(
            length: myTabs.length,
            child: new Scaffold(
              key: scaffoldKey,
              appBar: new AppBar(
                title: new Text('Bookmarks', style: logoStyle),

                actions: <Widget>[],
                bottom: null,
              ),
              body: new FavoritesLeaveBehind(
                sections: favorites,
                dismissHandler: (PageSection r) => new Preferences().store(),
                undoHandler: (PageSection r) => new Preferences().store(),
                tapHandler: (PageSection r) => showSectionPage(context, r),

              ),
            )
        )
    );
  }

  void showSectionPage(BuildContext context, PageSection section) {
    Navigator.push(context, new MaterialPageRoute<Null>(
      settings: const RouteSettings(name: "/section"),
      builder: (BuildContext context) {
        return new Theme(
          data: Theme.of(context).copyWith(platform: Theme
              .of(context)
              .platform),
          child: new ContentSectionPage(section: section),
        );
      },
    ));
  }
}

enum LeaveBehindAction {
  horizontalSwipe,
  leftSwipe,
  rightSwipe
}

class LeaveBehindItem implements Comparable<LeaveBehindItem> {
  LeaveBehindItem({ this.index, this.name, this.subject, this.body });

  LeaveBehindItem.from(LeaveBehindItem item)
      : index = item.index,
        name = item.name,
        subject = item.subject,
        body = item.body;

  final int index;
  final String name;
  final String subject;
  final String body;

  @override
  int compareTo(LeaveBehindItem other) => index.compareTo(other.index);
}

typedef void LeaveBehindDismissHandler(PageSection r);

typedef void LeaveBehindUndoHandler(PageSection r);

typedef void LeaveBehindTapHandler(PageSection r);

class FavoritesLeaveBehind extends StatefulWidget {
  FavoritesLeaveBehind(
      { Key key, this.sections, this.dismissHandler, this.undoHandler, this.tapHandler})
      : super(key: key);

  final List<PageSection> sections;
  final LeaveBehindDismissHandler dismissHandler;
  final LeaveBehindUndoHandler undoHandler;
  final LeaveBehindTapHandler tapHandler;

  @override
  FavoritesLeaveBehindState createState() => new FavoritesLeaveBehindState();
}


class FavoritesLeaveBehindState extends State<FavoritesLeaveBehind> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();
  DismissDirection _dismissDirection = DismissDirection.startToEnd;

  @override
  void initState() {
    super.initState();
  }

  void handleLeaveBehindAction(LeaveBehindAction action) {
    switch (action) {
      case LeaveBehindAction.horizontalSwipe:
        _dismissDirection = DismissDirection.horizontal;
        break;
      case LeaveBehindAction.leftSwipe:
        _dismissDirection = DismissDirection.endToStart;
        break;
      case LeaveBehindAction.rightSwipe:
        _dismissDirection = DismissDirection.startToEnd;
        break;
    }
  }

  void handleUndo(PageSection item) {
    int insertionIndex = lowerBound(config.sections, item);
    setState(() {
      config.sections.insert(insertionIndex, item);
    });
    if (config.undoHandler != null) {
      config.undoHandler(item);
    }
  }

  Widget buildItem(PageSection item) {
    final ThemeData theme = Theme.of(context);
    return new Dismissable(
        key: new ObjectKey(item),
        direction: _dismissDirection,
        onDismissed: (DismissDirection direction) {
          setState(() {
            config.sections.remove(item);
          });
          if (config.dismissHandler != null) {
            config.dismissHandler(item);
          }
          final String action = (direction == DismissDirection.endToStart)
              ? 'archived'
              : 'deleted';
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text('You $action item ${item.title}'),
              action: new SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    handleUndo(item);
                  }
              )
          ));
        },
        background: new Container(
            decoration: new BoxDecoration(backgroundColor: theme.primaryColor),
            child: new ListItem(
                leading: new Icon(Icons.delete, color: Colors.white, size: 36.0)
            )
        ),
        secondaryBackground: new Container(
            decoration: new BoxDecoration(backgroundColor: theme.primaryColor),
            child: new ListItem(
                trailing: new Icon(
                    Icons.archive, color: Colors.white, size: 36.0)
            )
        ),
        child: new Container(
            decoration: new BoxDecoration(
                backgroundColor: theme.canvasColor,
                border: new Border(
                    bottom: new BorderSide(color: theme.dividerColor))
            ),
            child: new ListItem(
              onTap: config.tapHandler != null
                  ? () => config.tapHandler(item)
                  : null,
              title: new Text(item.title),
              leading: new CircleAvatar(
                  child: new Icon(
                      new IconData(item.icon_data),
                      color: Colors.white
                  )
              ),
              isThreeLine: false,
            )
        )
    );
  }

  Widget buildEmptyFavoritesMessage() {
    return new Container(
        child: new Center(child: new Text("You have no bookmarks."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: config.sections.isEmpty ?
      buildEmptyFavoritesMessage()
          : new ListView(children: config.sections.map(buildItem).toList()),
    );
  }
}
