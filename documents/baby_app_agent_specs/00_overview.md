# Baby Parent App — Flutter Implementation Overview

## Goal
Build a production-ready Flutter app for expecting parents and parents of newborns/toddlers. The app has two primary modes:

1. **Expecting Mode** — pre-birth pregnancy support
2. **Arrived Mode** — post-birth baby activity tracking

The app should feel calm, modern, minimal, and optimized for tired parents. Most common actions should be reachable in 1–2 taps.

The user will provide design mockups. Implement the UI to match the mockups while following the product behavior and architecture described in these specs.

---

## Tech Requirements

- Framework: Flutter
- App shell: `MaterialApp`
- Modal bottom sheets: use Cupertino-style bottom sheet/modal patterns where appropriate
- State management: Riverpod or Provider-compatible MVVM pattern
- Architecture: MVVM with repository layer
- Storage: local-first
  - Preferred: Isar or Hive
  - Keep repositories abstracted for future sync support
- Backend: none required for MVP
- Code style:
  - Lean
  - Reusable components
  - Avoid duplicated UI logic
  - Keep feature modules isolated

---

## App Modes

The app supports two modes:

```dart
enum AppMode {
  expecting,
  arrived,
}
```

Users select a mode during onboarding. Users can later switch modes from Settings. The most common transition is:

```text
Expecting -> Arrived
```

Each mode has a distinct navigation structure and UI emphasis.

---

## Navigation Structure

Use a bottom navigation bar with 4 tabs in both modes.

### Expecting Mode Tabs

1. Pregnancy Overview
2. Contraction Timer
3. Baby Journal
4. Settings / Profile

### Arrived Mode Tabs

1. Baby Overview
2. Timeline
3. Analytics / Trends
4. Settings / Profile

When the user switches modes, tab icons, labels, and screens should update accordingly.

---

## Multi-Child Support

The app must support multiple children.

- Each child has independent data.
- The currently selected child should be available globally.
- Home/header should include a child selector dropdown.
- Events, journals, measurements, and settings should be scoped by `childId`.

---

## Recommended Folder Structure

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
    enums/
    utils/
    widgets/
      app_scaffold.dart
      child_selector.dart
      empty_state.dart
      metric_card.dart
      primary_button.dart
      segmented_toggle.dart
      cupertino_action_sheet.dart
  data/
    models/
      child_profile.dart
      app_settings.dart
      pregnancy_log.dart
      contraction_session.dart
      contraction_entry.dart
      baby_activity_event.dart
      baby_measurement.dart
      journal_entry.dart
    repositories/
      child_repository.dart
      settings_repository.dart
      pregnancy_repository.dart
      contraction_repository.dart
      activity_repository.dart
      measurement_repository.dart
      journal_repository.dart
    local/
      local_database.dart
  features/
    onboarding/
      onboarding_screen.dart
      onboarding_view_model.dart
    expecting/
      pregnancy_overview/
      contraction_timer/
      journal/
    arrived/
      baby_overview/
      timeline/
      analytics/
    settings/
      settings_screen.dart
      settings_view_model.dart
```

---

## Core Data Models

### ChildProfile

```dart
class ChildProfile {
  final String id;
  final String name;
  final Gender? gender;
  final AppMode mode;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String? medicalProviderPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Gender

```dart
enum Gender {
  male,
  female,
  unspecified,
}
```

### AppSettings

```dart
class AppSettings {
  final String selectedChildId;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  final TemperatureUnit temperatureUnit;
  final bool notificationsEnabled;
  final bool weeklyPregnancyReminderEnabled;
  final bool trackingReminderEnabled;
}
```

### Unit Enums

```dart
enum VolumeUnit { ml, oz }
enum WeightUnit { kg, lb }
enum LengthUnit { cm, inch }
enum TemperatureUnit { celsius, fahrenheit }
```

---

## Shared UI Components

Build reusable widgets instead of duplicating UI.

Required reusable components:

- `AppScaffold`
- `ModeAwareBottomNav`
- `ChildSelectorDropdown`
- `MetricCard`
- `TimelineEventCard`
- `PrimaryButton`
- `SecondaryButton`
- `SegmentedToggle<T>`
- `CupertinoBottomSheet`
- `EmptyState`
- `DateSelector`
- `ActivitySummaryCard`

---

## MVVM Pattern

Each feature should follow:

```text
Screen -> ViewModel -> Repository -> LocalDataSource
```

Rules:

- Screens should be mostly declarative UI.
- ViewModels own screen state and actions.
- Repositories abstract persistence and future sync.
- Models should be serializable.
- Avoid business logic directly inside widgets.

---

## Local-First Persistence

All data should work offline.

Repositories should support CRUD operations and expose reactive streams where useful.

Example repository style:

```dart
abstract class ActivityRepository {
  Stream<List<BabyActivityEvent>> watchEventsForChild(String childId);
  Future<List<BabyActivityEvent>> getEventsForDate(String childId, DateTime date);
  Future<void> addEvent(BabyActivityEvent event);
  Future<void> updateEvent(BabyActivityEvent event);
  Future<void> deleteEvent(String eventId);
}
```

---

## Design Implementation Rules

- Match provided mockups when available.
- Use large tap targets.
- Keep primary actions in thumb-reachable areas.
- Prefer bottom sheets over full-screen forms for quick entry.
- Use soft, modern visual hierarchy.
- Avoid clutter and dense dashboards.
- Avoid ad placements in core flows.

---

## First Implementation Milestones

1. Set up project structure, theme, models, repositories, and local database.
2. Implement onboarding flow.
3. Implement mode-aware root shell and bottom navigation.
4. Implement Expecting Mode screens.
5. Implement Arrived Mode screens.
6. Implement Settings and multi-child switching.
7. Add unit conversion helpers and summary calculations.
8. Add tests for data models, repositories, and core calculations.
