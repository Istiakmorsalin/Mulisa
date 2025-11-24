import 'package:flutter/material.dart';

// Small extension so we can write: theme.textStyleForBPTitle
extension TextThemeBP on ThemeData {
  TextStyle? get textStyleForBPTitle =>
      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);
}
