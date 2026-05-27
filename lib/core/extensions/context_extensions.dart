import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  void closeKeyboard() {
    final focusScope = FocusScope.of(this);
    if (!focusScope.hasPrimaryFocus) {
      focusScope.unfocus();
    }
  }
}
