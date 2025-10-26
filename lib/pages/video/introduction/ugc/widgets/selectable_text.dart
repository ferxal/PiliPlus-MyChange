import 'package:flutter/material.dart';
import 'package:piliplus/utils/utils.dart';

Widget selectableText(
  String text, {
  TextStyle? style,
}) {
  if (Utils.isDesktop) {
    return SelectionArea(
      child: Text(
        style: style,
        text,
      ),
    );
  }
  return SelectableText(
    style: style,
    text,
  );
}

Widget selectableRichText(
  TextSpan textSpan, {
  TextStyle? style,
}) {
  if (Utils.isDesktop) {
    return SelectionArea(
      child: Text.rich(
        style: style,
        textSpan,
      ),
    );
  }
  return SelectableText.rich(
    style: style,
    textSpan,
  );
}
