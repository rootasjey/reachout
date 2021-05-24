import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'colors.g.dart';

class StateColors = StateColorsBase with _$StateColors;

abstract class StateColorsBase with Store {
  @observable
  Color background = Colors.white;

  @observable
  Color foreground = Colors.black;

  /// Primary application's color.
  @observable
  Color primary = Color(0xFF796AD2);

  /// Secondary application's color.
  @observable
  Color secondary = Colors.orange.shade600;

  final Color dark = Color(0xFF303030);
  final Color deletion = Color(0xfff55c5c);
  final Color light = Color(0xFFEEEEEE);
  final Color lightBackground = Color(0xFfe3e6ec);
  final Color validation = Color(0xff38d589);

  ThemeData themeData;

  @action
  void refreshTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      foreground = Colors.white;
      background = Colors.black;
      return;
    }

    foreground = Colors.black;
    background = Colors.white;
  }

  @action
  void setPrimaryColor(Color color) {
    primary = color;
  }

  @action
  void setSecondaryColor(Color color) {
    secondary = color;
  }
}

final stateColors = StateColors();
