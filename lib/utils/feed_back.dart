import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/services.dart' show HapticFeedback;

bool enableFeedback = GStorage.feedBackEnable;
void feedBack() {
  if (enableFeedback) {
    HapticFeedback.lightImpact();
  }
}
