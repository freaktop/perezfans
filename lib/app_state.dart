import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _websiteURL = prefs.getString('ff_websiteURL') ?? _websiteURL;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _newVideo = '';
  String get newVideo => _newVideo;
  set newVideo(String value) {
    _newVideo = value;
  }

  String _websiteURL = 'perezfans.com';
  String get websiteURL => _websiteURL;
  set websiteURL(String value) {
    _websiteURL = value;
    prefs.setString('ff_websiteURL', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
