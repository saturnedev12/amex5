import 'package:flutter/material.dart';

extension ContextExtention on BuildContext {
  ThemeData get themeData => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}
