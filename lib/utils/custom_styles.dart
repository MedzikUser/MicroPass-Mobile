import 'package:flutter/material.dart';

class CustomStyles {
  static TextStyle sectionTextStyle(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.bodySmall!;

    final customStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return themeStyle.merge(customStyle);
  }
}
