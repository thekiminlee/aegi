# App Agent Memory

Scope: everything under `app/` only.

If work requires backend context from `../supabase`, read `../supabase/AGENTS.md` for that project. Do not copy backend decisions into this file unless they directly change `app/`.

Update rule:
- Update this file whenever `app/` structure, flow, architecture, or important constraints change.
- Keep it short, current, and decision-oriented.

## Project Direction

- Flutter mobile app for pregnancy / baby tracking.
- Current product is local-first.
- Persistent app data lives in local Drift database.
- Firebase currently used for analytics and remote config.
- Supabase integration is planned, but not yet wired into Flutter app.
- Current onboarding/auth state in app is local only.

## Current Runtime Flow

- Entry point: `lib/main.dart`
- App boot:
  - locks portrait orientation
  - initializes Firebase
  - starts `ProviderScope`
- Root widget: `lib/app/app.dart`
- Navigation: `lib/app/router.dart` with `go_router`

Current route flow:
1. `/splash`
2. `/welcome` if onboarding incomplete
3. `/onboarding`
4. `/home` after onboarding complete

Notes:
- No auth route exists yet in Flutter.
- Router gate currently depends on `onboardingGateProvider`, not remote auth/session state.
- Splash waits for onboarding gate and force-update gate.

## State / Architecture

- State management: Riverpod
- Routing: GoRouter
- Local storage: Drift SQLite
- Feature areas:
  - `features/welcome`
  - `features/onboarding`
  - `features/home`
  - `features/expecting`
  - `features/arrived`
  - `features/backup`
  - `features/setting`

Core app providers live in `lib/app/providers.dart`.

Current important providers:
- `databaseProvider`
- repository providers for Drift-backed data
- `analyticsServiceProvider`
- `onboardingGateProvider`

## Local Data Model Shape

Important local entities:
- child profiles
- app settings
- app meta key/value state
- pregnancy logs
- contraction sessions / entries
- baby logs
- journal entries

Current app mode concepts:
- `expecting`
- `arrived`

Onboarding currently creates:
- initial child
- initial app settings
- local onboarding-complete flag

## UX / Product Notes

- Welcome screen currently supports:
  - `Get Started`
  - local `Import`
- Import flow is local app behavior today.
- No account creation or login UI exists yet.

## Auth Status

Current truth:
- Flutter app does not yet implement Supabase auth.
- Planned auth direction is Google + Apple only.
- No email/password support planned.
- When auth work begins, agent should re-check `../supabase/AGENTS.md` before changing client flow.

## Working Rules For Future Agents

- Preserve local-first behavior unless task explicitly changes it.
- Do not assume backend schema exists yet.
- If adding auth to app later, account for current onboarding gate and import flow.
- Keep `AGENTS.md` updated when app navigation, storage, provider structure, or auth assumptions change.

