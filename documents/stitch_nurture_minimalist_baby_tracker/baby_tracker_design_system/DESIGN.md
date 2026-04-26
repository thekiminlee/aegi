---
name: Baby Tracker Design System
colors:
  surface: '#FFFFFF'
  surface-dim: '#ddd9d9'
  surface-bright: '#fdf8f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3f2'
  surface-container: '#f1edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#46464a'
  inverse-surface: '#313030'
  inverse-on-surface: '#f4f0ef'
  outline: '#77767b'
  outline-variant: '#c7c6ca'
  surface-tint: '#5f5e60'
  primary: '#010102'
  on-primary: '#ffffff'
  primary-container: '#1c1c1e'
  on-primary-container: '#858486'
  inverse-primary: '#c8c6c8'
  secondary: '#5e5e63'
  on-secondary: '#ffffff'
  secondary-container: '#e0dfe4'
  on-secondary-container: '#626267'
  tertiary: '#010100'
  on-tertiary: '#ffffff'
  tertiary-container: '#1f1b1a'
  on-tertiary-container: '#8a8381'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e4e2e4'
  primary-fixed-dim: '#c8c6c8'
  on-primary-fixed: '#1b1b1d'
  on-primary-fixed-variant: '#474649'
  secondary-fixed: '#e3e2e7'
  secondary-fixed-dim: '#c7c6cb'
  on-secondary-fixed: '#1a1b1f'
  on-secondary-fixed-variant: '#46464b'
  tertiary-fixed: '#eae0de'
  tertiary-fixed-dim: '#cdc5c3'
  on-tertiary-fixed: '#1f1b1a'
  on-tertiary-fixed-variant: '#4b4644'
  background: '#FAF9F7'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
  divider: '#EAEAEA'
  text-tertiary: '#A0A0A5'
  accent-feed: '#A8DADC'
  accent-diaper: '#FFE5B4'
  accent-sleep: '#B5C7ED'
  accent-temp: '#F6BD60'
  accent-contraction: '#F28482'
  dark-background: '#121212'
  dark-surface: '#1C1C1E'
typography:
  title-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  section-header:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  body-default:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-small:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  caption:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-button:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  touch-target-min: 44px
  safe-margin: 16px
---

# Baby Tracker App — Design Specification

## 1. Overview

This document defines the UI/UX design system and screen specifications for a minimal, fast, and intuitive baby tracking mobile app built with Flutter.

Primary goal:
Enable users to log events in under 2 seconds with minimal cognitive load.

Target users:
- Expecting parents
- Parents with newborns to toddlers (0–2 years)

Usage context:
- Sleep-deprived
- Multitasking
- One-handed usage

---

## 2. Design Principles

- Minimalistic and uncluttered
- Fast interaction > feature depth
- Large touch targets (>= 44px height)
- Clear hierarchy and readability
- Calm, soft visual tone
- Avoid dense forms and multi-step flows
- Max 2 taps for primary actions

---

## 3. Layout Guidelines

### Safe Areas
- Respect iOS and Android safe areas
- Bottom-heavy interaction zones

### Spacing System (8pt grid)
- XS: 4
- SM: 8
- MD: 16
- LG: 24
- XL: 32

### Corner Radius
- Cards: 16
- Buttons: 12–16
- Bottom sheets: 20 (top corners only)

---

## 4. Color System

### Base Colors
- Background: #FAF9F7 (warm off-white)
- Surface: #FFFFFF
- Divider: #EAEAEA

### Text Colors
- Primary: #1C1C1E
- Secondary: #6E6E73
- Tertiary: #A0A0A5

### Accent Colors (by event type)
- Feed: #A8DADC (soft blue)
- Diaper: #FFE5B4 (soft peach)
- Sleep: #B5C7ED (muted blue)
- Temperature: #F6BD60 (soft orange)
- Contraction: #F28482 (soft red, but muted)

---

## 5. Typography

Font: System default (SF Pro / Roboto)

### Type Scale
- Title: 20–24 semibold
- Section header: 16–18 medium
- Body: 14–16 regular
- Caption: 12–13 regular

### Rules
- Avoid small text (<12)
- Prioritize readability over density

---

## 6. Core Components

### 6.1 Event Card

Structure:
- Left: Icon (colored background)
- Center:
  - Title (event type)
  - Subtitle (details)
- Right:
  - Time (HH:MM)

Style:
- Padding: 12–16
- Border radius: 16
- Background: white
- Shadow: subtle (low elevation)

---

### 6.2 Floating Action Button (FAB)

- Circular
- Size: 56px
- Position: bottom-right
- Expands into action menu

Actions:
- Feed
- Diaper
- Sleep
- Temperature

---

### 6.3 Bottom Sheet (Quick Add)

- Height: dynamic (content-based)
- Rounded top corners
- Drag-to-dismiss enabled

Structure:
- Title
- Input(s)
- Primary action button

---

### 6.4 Buttons

Primary:
- Filled
- Rounded (12–16 radius)
- Height: 48

Secondary:
- Outline or ghost

---

### 6.5 Toggle Buttons

Used for:
- Diaper type (wet/dirty)
- Feed type

Style:
- Pill-shaped
- Clearly selected state

---

## 7. Screens

---

### 7.1 Onboarding

Max 2 screens.

Inputs:
- Mode:
  - Expecting
  - Already have baby
- Due date OR birth date
- Optional baby name

Design:
- Centered layout
- Minimal text
- Friendly tone

---

### 7.2 Timeline Screen (Primary Screen)

Structure:

Top:
- Header:
  - Baby name
  - Optional date

Body:
- Scrollable timeline
- Group by day:
  - "Today"
  - "Yesterday"

Each item:
- Event card

Bottom:
- FAB

Behavior:
- Latest event at top
- Smooth scrolling
- Infinite list

---

### 7.3 Quick Add Flows (Bottom Sheets)

#### Feed
- Number input (ml)
- Toggle: formula / breast
- Save button

#### Diaper
- Toggle:
  - Wet
  - Dirty
- Instant save (no extra confirm)

#### Sleep
Option A:
- Start / Stop button

Option B:
- Start time / End time input

#### Temperature
- Numeric input
- Unit toggle (°C / °F)

---

### 7.4 Contraction Timer

Layout:
- Center:
  - Large timer display
  - Start/Stop button

Below:
- List of contractions:
  - Duration
  - Interval since last

Design:
- Very focused
- Minimal distractions

---

### 7.5 Due Date Tracker

Layout:
- Week indicator:
  - "Week 32"
- Progress bar
- Optional weekly note

Tone:
- Calm and reassuring

---

### 7.6 Settings Screen

Simple list:
- Baby info
- Export data
- Upgrade to premium

No clutter.

---

## 8. Interaction Design

- All key actions reachable with thumb
- Avoid deep navigation
- Use bottom sheets instead of new screens
- Provide subtle haptic feedback on:
  - Logging events
  - Button taps

---

## 9. Animation Guidelines

- Duration: 150–250ms
- Use:
  - Fade
  - Slide up (bottom sheets)
- Avoid:
  - Bouncy or playful animations
  - Overly complex transitions

---

## 10. Accessibility

- High contrast text
- Minimum touch target size: 44px
- Support dynamic text scaling

---

## 11. Dark Mode (Optional)

- Background: near black (#121212)
- Cards: dark gray
- Keep accent colors muted

---

## 12. Anti-Patterns (DO NOT DO)

- No multi-step forms
- No cluttered dashboards
- No ads in primary interaction flow
- No more than 2 taps for logging
- No tiny buttons or dense UI

---

## 13. Success Criteria

The UI is successful if:
- A user can log an event in <= 2 seconds
- The app feels calm and not overwhelming
- The user never needs instructions