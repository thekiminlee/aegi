import 'package:flutter/material.dart';

const String showcaseExpectingShownKey = 'showcase_expecting_shown';
const String showcaseContractionShownKey = 'showcase_contraction_shown';
const String showcaseArrivedShownKey = 'showcase_arrived_shown';

/// Showcase keys for the Expecting (pregnancy) overview tab + shared header.
class ExpectingShowcaseKeys {
  ExpectingShowcaseKeys._();

  static final metrics = GlobalKey();
  static final timeline = GlobalKey();
  static final journal = GlobalKey();
  static final settings = GlobalKey();

  static List<GlobalKey> get all => [metrics, timeline, journal, settings];
}

/// Showcase keys for the contraction timer tab.
class ContractionShowcaseKeys {
  ContractionShowcaseKeys._();

  static final kickTile = GlobalKey();
  static final contractionTile = GlobalKey();
  static final sessions = GlobalKey();

  static List<GlobalKey> get all => [kickTile, contractionTile, sessions];
}

/// Showcase keys for the Arrived overview tab + shared header.
class ArrivedShowcaseKeys {
  ArrivedShowcaseKeys._();

  static final metrics = GlobalKey();
  static final timeline = GlobalKey();
  static final journal = GlobalKey();
  static final settings = GlobalKey();

  static List<GlobalKey> get all => [metrics, timeline, journal, settings];
}
