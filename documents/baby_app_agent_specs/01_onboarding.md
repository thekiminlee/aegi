# Onboarding Flow Specification

## Goal
Create a simple 3-page onboarding flow shown only on first app launch.

Onboarding collects enough information to initialize the first child profile and app mode.

---

## Page 1 — Mode Selection

User chooses one of:

- Expecting
- Arrived

### If Expecting is selected

Show:

- Due date picker
- Optional medical provider phone number field

### If Arrived is selected

Show:

- Birth date picker

### Behavior

- Selected mode should visually change the form.
- User cannot continue without selecting mode and required date.
- Medical provider phone number is optional.

---

## Page 2 — Baby Information

Collect:

- Baby name
- Gender selection
  - Male
  - Female
  - Skip / Unspecified

### Behavior

- Baby name can be optional, but default to “Baby” if empty.
- Gender can be skipped.

---

## Page 3 — Welcome

Show a warm welcome message based on mode.

### Expecting message example

```text
You're all set. We'll help you follow the pregnancy journey and stay ready for delivery.
```

### Arrived message example

```text
You're all set. Start tracking your baby's day with quick, simple logs.
```

Primary CTA:

```text
Get Started
```

---

## Data Created on Completion

Create a `ChildProfile`.

```dart
ChildProfile(
  id: generatedUuid,
  name: enteredNameOrBaby,
  gender: selectedGenderOrUnspecified,
  mode: selectedMode,
  dueDate: expecting ? selectedDueDate : null,
  birthDate: arrived ? selectedBirthDate : null,
  medicalProviderPhone: expecting ? optionalPhone : null,
  createdAt: now,
  updatedAt: now,
)
```

Create initial `AppSettings`.

```dart
AppSettings(
  selectedChildId: child.id,
  volumeUnit: VolumeUnit.ml,
  weightUnit: WeightUnit.kg,
  lengthUnit: LengthUnit.cm,
  temperatureUnit: TemperatureUnit.celsius,
  notificationsEnabled: true,
  weeklyPregnancyReminderEnabled: selectedMode == AppMode.expecting,
  trackingReminderEnabled: false,
)
```

---

## UI Requirements

- Use a page view or stepper-style flow.
- Keep each page focused.
- Use large buttons and cards for mode selection.
- Avoid dense text.
- Use calm, warm copy.
- Match provided mockups if available.

---

## ViewModel Responsibilities

`OnboardingViewModel` should manage:

- Current page index
- Selected mode
- Due date
- Birth date
- Medical provider phone
- Baby name
- Gender
- Validation
- Completion action

---

## Completion Behavior

After completion:

- Persist child profile.
- Persist app settings.
- Mark onboarding as completed.
- Navigate to mode-aware app shell.
