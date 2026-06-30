# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Frecency ranking** — terms you open often and recently float toward the top.
  Applied softly: it orders the empty-search browse list and breaks ties between
  equally-good fuzzy matches, but never overrides a clearly better text match.
  Usage (open count + last-opened) persists in UserDefaults; the scoring lives in
  `GlossaryCore` (`frecencyScore`, `UsageStore`) and is unit-tested.
- Expanded the seed glossary from **24 to 54 terms** (added cache, cookie, CDN,
  load balancer, Kubernetes, cloud, OAuth, REST, GraphQL, microservices, SSH,
  regex, async, and more) so there's more to search and scroll while testing.
- **Settings window** (menu bar → Settings…, or ⌘,) backed by UserDefaults:
  rebindable summon hotkey, window style, panel size, theme, launch at login,
  clipboard auto-load, and Reset to Defaults.
- **Rebindable global hotkey** — pick from preset 2-key chords; the Carbon
  hotkey re-registers live on change.
- **Mini mode** — a menu-bar `NSPopover` showing search + only the "What It Is"
  summary, as an alternative to the centered overlay.
- **Panel size presets** — Small / Medium / Large for Overlay mode.
- **Light / Dark / System theme** — colors now resolve dynamically from the
  KIKA light and dark token sets based on window appearance.
- **Launch at login** via `SMAppService`.
- **Back navigation** — `Esc` is now two-stage: from a focused term it returns
  to the result list; from the list it dismisses (footer hint shows Back/Close).

### Changed
- **Disclosure is now a single-key Space stepper** instead of Space (Analogy) +
  `Cmd+D` (deep dive). Each Space opens the next block (Analogy → Why It Matters →
  Example); once all are open, each press closes the last one, then it cycles.
  `Cmd+D` was removed.
- Typography now uses **system text styles** (`.title3`, `.body`, `.callout`,
  `.caption2`, …) instead of fixed large point sizes, so it follows the OS and
  feels less oversized; paddings tightened throughout.
- **Mini mode is now genuinely compact** — 300pt wide, single-line rows, and it
  **sizes to its content** via `preferredContentSize` (no fixed box / empty
  space); the list caps at ~6 rows.
- **Light mode feels native** — the heavy warm fill is gone; light mode now lets
  the macOS window vibrancy carry the surface with only a faint KIKA tint. Mini
  mode uses the popover's own material instead of a solid fill.
- Default summon hotkey is now **⌥Esc (Option+Escape)** instead of Option+Space
  (which collides with Raycast). Configurable in Settings.
- Overlay background now uses a real `NSVisualEffectView` (`.hudWindow` in dark,
  `.menu` in light, behind-window vibrancy) plus a KIKA tint and faint top sheen,
  replacing the see-through `.ultraThinMaterial`. Fixes the uneven desktop
  bleed-through and restores legible, on-brand contrast.

### Added
- Approved design spec for the Glossary menu-bar utility
  (`docs/superpowers/specs/2026-06-29-glossary-menu-bar-design.md`).
- Project docs: `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `TODO.md`.
- KIKA brand palette adopted as the app's visual system (accent `#6D80A6`,
  bg `#2C2D2F`, fg `#E7E5E0`; brand-derived disclosure-block header accents).
- SwiftPM package: `GlossaryCore` (library) + `Glossary` (executable) + tests.
- `GlossaryCore`: `Term` model, `Glossary` JSON loader, `FuzzyMatcher`
  (subsequence ranking), `AppState` (List/Detail modes, independent disclosure
  toggles, clipboard resolver), `TermFormatter` (Cmd+C text). 24 seed terms.
- `Glossary` app: menu-bar status item, `Option+Space` global hotkey (Carbon),
  centered floating `NSPanel` overlay, two-mode keyboard routing, glassmorphism
  SwiftUI views (`RootView`, `SearchBar`, `ResultsList`, `TermDetailView`,
  `DisclosureBlock`) with the 4-tier progressive disclosure.
- `scripts/build-app.sh` — assembles a distributable `Glossary.app`
  (`LSUIElement` agent, bundled resources, ad-hoc signed).
- 26 unit tests (Swift Testing) across loading, fuzzy matching, app-state
  transitions, and clipboard resolution — all passing.
