import 'package:flutter/material.dart';

const isProduction = bool.fromEnvironment('dart.vm.product');

void debugCatch(Object err, StackTrace stacktrace) {
  if (!isProduction) {
    debugPrint(err.toString());
    debugPrint(stacktrace.toString());
  }
}
