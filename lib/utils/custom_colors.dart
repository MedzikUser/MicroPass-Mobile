import 'package:flutter/material.dart';

class CustomColors {
  static TextStyle sectionTextStyle(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall!;
    return style.merge(TextStyle(color: Theme.of(context).colorScheme.primary));
  }
}
