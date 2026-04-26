# Expecting Mode Specification

## Overview
Expecting Mode supports pregnancy tracking before birth. It has 4 tabs:

1. Pregnancy Overview
2. Contraction Timer
3. Baby Journal
4. Settings

The selected child must be available from the home header through a dropdown.

---

## Tab 1 — Pregnancy Overview

### Purpose
Provide a clear overview of the pregnancy journey.

### Required Information

Show:

- Current pregnancy week
- Days/weeks elapsed
- Days/weeks remaining until due date
- Visual pregnancy progress timeline
- Current baby state / weekly description
- Daily kick counter
- Heartbeat log summary
- Mother activity summary
  - Water intake
  - Medications
  - Shots / injections

---

## Pregnancy Calculations

Assume pregnancy duration is 40 weeks unless configured otherwise.

```dart
int daysPregnant = now.difference(dueDate.subtract(Duration(days: 280))).inDays;
int currentWeek = (daysPregnant / 7).floor() + 1;
int daysRemaining = dueDate.difference(now).inDays;
double progress = daysPregnant / 280;
```

Clamp progress between 0 and 1.

---

## Pregnancy Log Model

```dart
enum PregnancyLogType {
  kick,
  heartbeat,
  water,
  medication,
  shot,
}

class PregnancyLog {
  final String id;
  final String childId;
  final PregnancyLogType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
}
```

### Metadata Examples

Kick:

```json
{ "count": 1 }
```

Heartbeat:

```json
{ "bpm": 145 }
```

Water:

```json
{ "amountMl": 250 }
```

Medication:

```json
{ "name": "Prenatal vitamin", "dose": "1 tablet" }
```

Shot:

```json
{ "name": "Injection name", "note": "optional" }
```

---

## Tab 2 — Contraction Timer

### Purpose
Help parents track contractions and estimate delivery readiness.

### UI Requirements

Show:

- Large start/stop timer button
- Current contraction duration
- Time since last contraction
- Current session stats
- List of contractions in current session

### Track Per Contraction

- Start time
- End time
- Duration
- Interval since previous contraction
- Intensity, optional

---

## Contraction Data Models

```dart
class ContractionSession {
  final String id;
  final String childId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<ContractionEntry> entries;
}

class ContractionEntry {
  final String id;
  final String sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int? intensity; // 1-10 optional
}
```

Computed values:

```dart
Duration get duration => endedAt.difference(startedAt);
Duration? intervalSincePrevious(ContractionEntry previous) =>
  startedAt.difference(previous.startedAt);
```

Session stats:

- Average contraction duration
- Average interval
- Session duration
- Number of contractions
- Recent contraction pattern

### Important Safety Copy

Include a non-intrusive disclaimer:

```text
This tool is for tracking only and does not replace medical advice. Contact your provider if unsure.
```

If medical provider phone exists, expose a quick-call action.

---

## Tab 3 — Baby Journal

### Purpose
Allow mother/parents to log pregnancy notes and milestones.

### Journal Model

```dart
class JournalEntry {
  final String id;
  final String childId;
  final DateTime timestamp;
  final String title;
  final String body;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### UI Requirements

- List of journal entries
- Add journal entry via bottom sheet or simple editor
- Support brief notes
- Optional milestone tags
- Empty state for no entries

---

## Expected Reusable Components

- `PregnancyProgressCard`
- `WeeklyBabyInfoCard`
- `PregnancyMetricCard`
- `KickCounterButton`
- `ContractionTimerButton`
- `ContractionStatsPanel`
- `ContractionEntryList`
- `JournalEntryCard`
