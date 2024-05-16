import 'package:flutter/material.dart';

extension NavigatorExtension on BuildContext {
  void pushToView({required Widget view}) {
    Navigator.push(this, MaterialPageRoute(builder: (context) => view));
  }

  void popView() {
    Navigator.pop(this);
  }
}
