import 'package:flutter/material.dart';
import 'package:piliplus/models/dynamics/result.dart' show ModuleBlocked;
import 'package:piliplus/pages/article/widgets/opus_content.dart'
    show moduleBlockedItem;

Widget blockedItem({
  required ThemeData theme,
  required ModuleBlocked blocked,
  required double maxWidth,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
    child: moduleBlockedItem(theme, blocked, maxWidth - 26),
  );
}
