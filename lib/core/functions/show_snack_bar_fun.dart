import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarFun({required BuildContext context, required String text}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}