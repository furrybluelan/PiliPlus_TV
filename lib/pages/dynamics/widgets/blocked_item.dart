import 'package:PiliPlus/models/dynamics/result.dart' show ModuleBlocked;
import 'package:PiliPlus/pages/article/widgets/opus_content.dart'
    show moduleBlockedItem;
import 'package:flutter/material.dart';

Widget blockedItem(ThemeData theme, ModuleBlocked moduleBlocked) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return moduleBlockedItem(theme, moduleBlocked, constraints.maxWidth);
      },
    ),
  );
}
