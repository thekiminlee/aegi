# Arrived Mode Specification

## Overview
Arrived Mode supports post-birth tracking for newborns/toddlers. It has 4 tabs:

1. Baby Overview
2. Timeline
3. Analytics / Trends
4. Settings

The selected child must be available from the home header through a dropdown.

---

## Activity Event Model

Use a unified event model for all baby activity tracking.

```dart
enum BabyActivityType {
  feed,
  diaper,
  sleep,
  temperature,
  weight,
  height,
  note,
}

class BabyActivityEvent {
  final String id;
  final String childId;
  final BabyActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Metadata Examples

Feed:

```json
{ "feedType": "formula", "amountMl": 120 }
```

Diaper:

```json
{ "diaperType": "wet" }
```

Sleep:

```json
{ "quality": "optional" }
```

Temperature:

```json
{ "valueCelsius": 37.2 }
```

Weight:

```json
{ "valueKg": 4.8 }
```

Height:

```json
{ "valueCm": 56.0 }
```

---

## Tab 1 — Baby Overview

### Purpose
Show a quick summary of the baby's current day.

### Required Sections

Show:

- Last activity
- Last feed
- Last diaper
- Today's activity history
- Quick add actions

### Quick Add Actions

Accessible from overview:

- Feed
- Diaper
- Sleep
- Temperature

Use Cupertino-style bottom sheets for quick entry.

---

## Tab 2 — Timeline

### Purpose
Show a calendar-like hourly view of activities for a selected date.

### Required UI

- Date selector at top
- Summary metrics for selected day:
  - Total formula intake
  - Total sleep hours
  - Total diaper count
- Timeline below
  - Time on the left
  - Activities aligned to their timestamps
  - Similar to an hourly calendar/day agenda view

### Behavior

- User can select different dates.
- Events are filtered by selected child and selected date.
- Show empty state if no events exist.

---

## Tab 3 — Analytics / Trends

### Purpose
Show trends and deeper tracking insights.

### Required Metrics

Track and display:

- Total formula intake
- Total sleep duration
- Diaper count
- Weight
  - Last input date
  - Weekly trend
- Height
  - Last input date
  - Weekly trend
- Other useful infant metrics if already available from event data

### Analytics Requirements

Create reusable summary services/calculators:

```dart
class BabyAnalyticsSummary {
  final double totalFormulaMl;
  final Duration totalSleepDuration;
  final int diaperCount;
  final BabyMeasurement? latestWeight;
  final BabyMeasurement? latestHeight;
}
```

```dart
class BabyMeasurement {
  final String id;
  final String childId;
  final MeasurementType type;
  final double value;
  final DateTime measuredAt;
  final DateTime createdAt;
}

enum MeasurementType {
  weightKg,
  heightCm,
}
```

Analytics should be derived from local data and scoped to selected child.

---

## Quick Add Bottom Sheets

### Feed

Inputs:

- Feed type
  - Formula
  - Breast
- Amount
  - Store internally as ml
  - Display based on user unit preference

### Diaper

Inputs:

- Wet
- Dirty
- Both if useful

### Sleep

Inputs:

- Start sleep
- End sleep
- Or start/end timestamps

### Temperature

Inputs:

- Numeric value
- Unit based on user preference
- Store internally as Celsius

### Weight / Height

Can be available from analytics or settings/profile area.

- Store weight internally as kg
- Store height internally as cm

---

## Unit Conversion Rules

Store canonical units internally:

- Volume: ml
- Weight: kg
- Length: cm
- Temperature: Celsius

Display according to user settings.

---

## Expected Reusable Components

- `LastActivityCard`
- `TodaySummaryCard`
- `QuickActionGrid`
- `TimelineDayView`
- `TimelineHourRow`
- `TimelineActivityItem`
- `DailyTotalsBar`
- `TrendMetricCard`
- `MeasurementTrendChart`
- `QuickAddFeedSheet`
- `QuickAddDiaperSheet`
- `QuickAddSleepSheet`
- `QuickAddTemperatureSheet`
