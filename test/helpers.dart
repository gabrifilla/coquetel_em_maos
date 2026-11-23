import 'package:flutter_test/flutter_test.dart';

/// Liga "reduzir movimento": bolhas e confete param, e o pumpAndSettle termina.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
