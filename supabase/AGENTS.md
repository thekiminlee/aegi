# Supabase Agent Memory

Scope: everything under `supabase/` only.

If work requires Flutter client context from `../app`, read `../app/AGENTS.md` for that project. Do not copy app-only decisions into this file unless they directly change `supabase/`.

Update rule:
- Update this file whenever `supabase/` structure, contracts, auth boundaries, or implementation direction change.
- Keep it short, current, and decision-oriented.

## Project Direction

- Supabase backend is in early skeleton phase.
- Current scope is auth foundation only.
- No database schema, migrations, or sync tables yet.
- Backend is being shaped around current Flutter app, but Flutter is not integrated yet.

## Current Backend Structure

- Config: `config.toml`
- Local env template: `.env.example`
- Docs: `README.md`
- Edge functions:
  - `functions/user`
- Shared helpers:
  - `functions/_shared/auth.ts`
  - `functions/_shared/cors.ts`
  - `functions/_shared/log.ts`
  - `functions/_shared/responses.ts`
  - `functions/_shared/types.ts`
  - `functions/_shared/user_payload.ts`

## Current Auth Contract

Single function:
- `POST /functions/v1/user`

Current behavior:
- requires bearer token
- resolves authenticated Supabase user
- normalizes providers
- accepts only:
  - `google`
  - `apple`
- rejects unsupported providers
- read-only only; no persistence

Current success response shape:
- `user.id`
- `user.email`
- `user.providers`
- `user.display_name`
- `user.avatar_url`
- `user.provider_user_ids`
- `session.provider`
- `app_context: null`

Current error codes:
- `missing_auth_header`
- `invalid_token`
- `unsupported_provider`
- `internal_error`

## Current Non-Goals

- profile table
- onboarding persistence
- child or log sync
- backup upload
- provider linking
- sign-out hooks
- email/password auth
- magic link auth
- phone auth
- anonymous auth

## Assumptions

- Supabase Auth is source of truth for identity/session.
- Mobile app will sign in natively with Google / Apple, then exchange credentials with Supabase Auth on device.
- Flutter app will later call `user` after sign-in to fetch normalized auth context.
- Future writes should likely live in separate functions instead of overloading `user`.

## Local Dev Notes

- Supabase CLI was not installed in this environment when this skeleton was created.
- Files were scaffolded without runtime verification.
- Before further function work, install Supabase CLI and verify local serve/invoke flow from `README.md`.

## Working Rules For Future Agents

- Keep this project schema-free until task explicitly adds backend schema.
- Keep `user` read-only unless requirements intentionally change.
- If adding backend behavior tied to client flow, re-check `../app/AGENTS.md` first.
- Keep `AGENTS.md` updated when function contracts, file structure, or auth direction change.

