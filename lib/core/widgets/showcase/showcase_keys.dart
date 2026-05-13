import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

const String showcaseExpectingShownKey = 'showcase_expecting_shown';
const String showcaseArrivedShownKey = 'showcase_arrived_shown';

/// Showcase keys for the Expecting overview tab.
class ExpectingShowcaseKeys {
  ExpectingShowcaseKeys._();

  static final weekTracker = GlobalKey();
  static final viewAll = GlobalKey();
  static final kickCounter = GlobalKey();
  static final recentLog = GlobalKey();
  static final addButton = GlobalKey();

  static List<GlobalKey> get all => [
        weekTracker,
        viewAll,
        kickCounter,
        recentLog,
        addButton,
      ];

  static void start(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase(all);
  }
}

/// Showcase keys for the Arrived overview tab.
class ArrivedShowcaseKeys {
  ArrivedShowcaseKeys._();

  static final monthTracker = GlobalKey();
  static final viewAll = GlobalKey();
  static final quickActions = GlobalKey();
  static final activityHistory = GlobalKey();
  static final addButton = GlobalKey();

  static List<GlobalKey> get all => [
        monthTracker,
        viewAll,
        quickActions,
        activityHistory,
        addButton,
      ];

  static void start(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase(all);
  }
}
