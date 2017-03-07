import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show PathProvider;

import 'package:in_tallinn_content/structure/site_structure.dart';
import 'package:in_tallinn_content/structure/page_section.dart';

class Preferences {
  static final Preferences _singleton = new Preferences._internal();
  static const favoritesKey = "favorites";
  static const useDarkThemeKey = "useDark";

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal();

  bool useDarkTheme = false;

  List<PageSection> favoriteSections = <PageSection>[];


  Future<Preferences> read() async {
    if (favoriteSections == null) {
      await _readPreferences();
    }
    return this;
  }

  Future<Null> store() => _writePreferences();

  static Future<File> _getPreferencesFile() async {
    // get the path to the document directory.
    String dir = (await PathProvider.getApplicationDocumentsDirectory()).path;
    return new File('$dir/favorites.json');
  }

  Future<Null> _readPreferences() async {
    try {
      List<PageSection> faves = new List<PageSection>();
      File file = await _getPreferencesFile();
      String contents = await file.readAsStringSync();

      Map<String, dynamic> prefs = JSON.decode(contents);

      if (prefs.containsKey(favoritesKey)) {
        List<String> faveIds = prefs[favoritesKey];

        for (String faveid in faveIds) {
          PageSection sec = SiteStructure.getSection(faveid);
          if (sec != null) {
            faves.add(sec);
          }
        }
        favoriteSections = faves;
      }

      if (prefs.containsKey(useDarkThemeKey)) {
        useDarkTheme = prefs[useDarkThemeKey];
      }
    } on FileSystemException {
      favoriteSections = new List<PageSection>();
    }
  }

  Future<Null> _writePreferences() async {
    String contents = JSON.encode({
      favoritesKey: favoriteSections.map((PageSection r) => r.id).toList(),
      useDarkThemeKey: useDarkTheme,
    });
    try {
      await (await _getPreferencesFile()).writeAsString(contents);
    } on Exception catch (e) {
      print("Failed to store favorites:\n$e");
    }
  }
}


