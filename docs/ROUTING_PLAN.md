# Routing Plan (2026-ready)

## Goals
- One clear route per destination; avoid duplicate navboxes to same page.
- Consistent route naming (kebab-case) and shallow paths where possible.
- Animate transitions for clarity; use root vs shell navigator intentionally.
- Keep public vs authenticated flows separate and lightweight.

## Recommended Routes
- **Public / Onboarding**
  - `/splash` — splash/startup
  - `/landing` — marketing/entry
  - `/welcome` — intro/choose auth
  - `/login`
  - `/register`
  - `/password-reset`
  - `/email-verification`

- **Authenticated Shell (bottom nav scaffold)**
  - `/` — Mobile landing/home (map/cards hub)
  - `/map` — Map view (with nested `business/:id` on root navigator)
  - `/businesses` — List view
  - `/profile` — User profile (badge, images)
  - `/upload` — Image upload
  - `/leaderboard`
  - `/rewards-nearby`
  - `/monopoly-board`
  - `/casual-games` — Casual games lobby (rename from `/CasualGamesLobbyScreen`)
  - `/checkin-history`
  - `/instructions`
  - `/prizes` — Standalone prizes catalog
  - `/rules-and-prizes` — Full rules/prizes/faq (accepts `GameRules` extra; default to `monopolyGameRules`)
  - `/admin` — Admin console (admin-only)
  - `/admin-test` — Admin diagnostics (dev-only; consider hiding in prod)

- **Nested / Modal Routes**
  - `/business/:id` — Detail (opened via root navigator for modal transition over tabs)
  - Future: `/play-session/:id` — Active game session (optional isolation)

## Navigation Sources (avoid duplicates)
- Bottom nav tabs: `/`, `/map`, `/businesses`, `/rewards-nearby`, `/profile`
- Drawer/Overflow: `/leaderboard`, `/prizes`, `/rules-and-prizes`, `/instructions`, `/checkin-history`, `/upload`
- Admin-only shortcuts: `/admin`; dev-only `/admin-test`
- In-game help: use `context.push('/rules-and-prizes', extra: gameRules)` from board/lobby; don’t duplicate with a separate navbox pointing elsewhere.

## Transition & Animation Recommendations (2026 UX)
- Standard page pushes: **M3 shared axis** (horizontal) for lateral nav between sections.
- Modal overlays (e.g., business detail over map): fade + scale (200–250ms) using root navigator.
- Bottom sheet previews (rules preview): keep as is; add springy drag handle.
- Image upload success: use unobtrusive toast/snackbar with progress indicator.
- Reduce motion setting: respect platform accessibility; fall back to fade.

## Route Guards
- Public-only: redirect authenticated users away from `/login`, `/register`, `/welcome`, `/landing` back to `/`.
- Auth-only: all shell routes require auth; redirect unauthenticated to `/landing`.
- Admin guard: `/admin`, business image write paths.
- Dev-only: consider feature flag for `/admin-test`.

## Tech Notes
- Keep one GoRouter instance with root + shell navigators (already present).
- Use typed extras for rules (`GameRules`), business IDs, session IDs.
- Prefer kebab-case constants (e.g., `/casual-games` vs `/CasualGamesLobbyScreen`).
- Ensure `storageBucket` and auth initialization happen before router build.

## Clean-up Checklist
- Rename `/CasualGamesLobbyScreen` -> `/casual-games` route constant and usage.
- Remove duplicate navboxes pointing to the same destination; choose one entry point per feature.
- Centralize route usage via `AppRoutes` constants in widgets.
- Verify business detail uses root navigator for modal feel over map tab.
