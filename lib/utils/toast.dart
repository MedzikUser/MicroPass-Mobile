import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Toast {
  static void show(
    BuildContext context, {
    required String content,
    void Function()? retryAction,
  }) {
    SnackBar snackBar;

    if (retryAction != null) {
      snackBar = SnackBar(
        content: Text(content),
        action: SnackBarAction(
          label: FlutterI18n.translate(context, 'toast.retry'),
          onPressed: retryAction,
        ),
      );
    } else {
      snackBar = SnackBar(content: Text(content));
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
