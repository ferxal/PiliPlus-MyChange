import 'package:flutter/services.dart' show HapticFeedback;
import 'package:piliplus/utils/storage_pref.dart';

bool enableFeedback = Pref.feedBackEnable;
void feedBack() {
  if (enableFeedback) {
    HapticFeedback.lightImpact();
  }
}
