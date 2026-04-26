# Settings and Profile Specification

## Overview
Settings is the fourth tab in both Expecting and Arrived modes.

Settings manages:

- Baby information
- Multiple children
- Units
- Mode switching
- Notification preferences
- Data export hooks
- Premium hooks, if implemented later

---

## Required Settings Sections

### 1. Child Profile

Fields:

- Baby name
- Gender
- Due date
- Birth date
- Medical provider phone, especially for Expecting mode

Allow editing current child profile.

---

## 2. Multi-Child Management

Support:

- Add child
- Switch child
- Edit child
- Delete child, with confirmation

Current child should be selected from a dropdown in the home/header.

Each child must maintain independent:

- Pregnancy logs
- Contraction sessions
- Journal entries
- Baby activity events
- Measurements

---

## 3. Units

Allow user to configure:

- Volume: ml / oz
- Weight: kg / lb
- Length: cm / inch
- Temperature: °C / °F

Internally store canonical values:

- ml
- kg
- cm
- Celsius

Use conversion helpers for display/input.

---

## 4. Mode Update

Allow switching between:

- Expecting
- Arrived

### Expected Flow

If switching from Expecting to Arrived:

- Ask for birth date if missing
- Confirm transition
- Update selected child mode
- Navigation tabs should change immediately

If switching from Arrived to Expecting:

- Allow it, but confirm because it is uncommon
- Ask for due date if missing

---

## 5. Notification Preferences

Allow toggles for:

- Notifications enabled
- Weekly pregnancy reminders
- Tracking reminders

Actual push/local notification implementation can be stubbed if not in MVP, but the settings model should support it.

---

## 6. Data Export

Add placeholder UI action:

- Export data

Implementation can initially export JSON locally or be left as a repository stub if not part of MVP.

---

## Settings ViewModel Responsibilities

`SettingsViewModel` should manage:

- Current child profile
- Child list
- Selected units
- Notification preferences
- Mode switching
- Add/edit/delete child actions
- Validation for dates and required fields

---

## Required Components

- `SettingsSection`
- `SettingsRow`
- `UnitSelectorRow`
- `ModeSwitchCard`
- `ChildManagementSheet`
- `EditChildProfileSheet`
- `NotificationToggleRow`

---

## UX Requirements

- Keep settings simple and grouped.
- Use confirmation dialogs for destructive actions.
- Use Cupertino-style bottom sheets for editing child profile or adding a child.
- Avoid overwhelming the user with technical settings.
