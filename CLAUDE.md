# CLAUDE.md — Glossary

Project memory for Claude Code. Read this first.

## What this is

**Glossary** — a native macOS menu-bar utility (Swift 6.3, SwiftUI + AppKit). A
keyboard-first, distraction-free glossary: summon a centered Raycast-style overlay
with `⌥Esc`, fuzzy-search a small tech glossary, and reveal each term through
4 tiers of progressive disclosure — no mouse required.

Design spec: [docs/design-spec.md](docs/design-spec.md)

## ⚠️ Docs discipline — update docs on EVERY change

This is a hard rule for this repo. Before finishing any change, update the three
living docs so they always reflect reality:

- **CHANGELOG.md** — add an entry under `## [Unreleased]` (Keep a Changelog format:
  Added / Changed / Fixed / Removed). Every user-visible or structural change gets a line.
- **TODO.md** — check off what you finished; add any new follow-ups you discovered.
- **README.md** — update if behavior, commands, hotkeys, or setup changed.

If a change touches architecture or scope, also update the design spec. Treat a change
as **not done** until its docs are updated.

## Tech & architecture

- Swift 6.3 / Xcode 26, Apple Silicon, macOS 14+.
- **`GlossaryCore`** (library) — pure, fully unit-tested logic: `Term`, `Glossary`
  (JSON loader), `FuzzyMatcher`, `AppState` (modes + single-key disclosure stepper +
  frecency ordering), `TermFormatter`, `UsageStore`/`frecencyScore`. The app injects a
  `DefaultsUsageStore` (UserDefaults) for persistence.
- **`Glossary`** (executable) — AppKit shell: `NSStatusItem`, `OverlayPanelController`
  (floating `NSPanel`) and `MiniPopoverController` (menu-bar `NSPopover`),
  `GlobalHotkey` (Carbon `RegisterEventHotKey`), `Settings` (UserDefaults store) +
  `SettingsView`/`SettingsWindowController`, SwiftUI views. `AppDelegate` routes
  summon to the configured presentation mode and re-registers the hotkey on change.
- Two keyboard modes — **List** (typing/arrows) and **Detail** (`Space` steps the
  disclosure loop, `⌘C` copies). `Esc` is two-stage (Back from a term, then close).
  See spec §3.
- Default hotkey **⌥Esc** (rebindable in Settings). Presentation: Overlay or Mini.
- Terms load from an editable file (`~/Library/Application Support/Glossary/glossary.json`)
  seeded from the bundled `glossary.json`; `GlossaryLibrary` handles seed/load/reload/reset
  and Settings exposes it. Bundled JSON is just the seed.
- Brand: **KIKA** palette, dynamic light/dark tokens in `Theme.swift`. Accent
  `#6D80A6`; dark bg `#2C2D2F` / fg `#E7E5E0`. See spec §6.
- App icon: `Resources/AppIcon.png` (book + `{ / }`); `build-app.sh` generates the
  `.icns`. Menu-bar glyph is a code-drawn `{ / }` template (`StatusItemIcon`).

## Commands

```bash
swift build                 # compile
swift test                  # run GlossaryCore unit tests
swift run Glossary          # dev run (overlay agent)
scripts/build-app.sh        # build distributable Glossary.app
```

## Conventions

- Keep AppKit/Carbon edges thin; put testable logic in `GlossaryCore`.
- New logic in `GlossaryCore` ships with tests (`swift test` must stay green).
- No new third-party dependencies without a note in the spec + CHANGELOG.
- Match existing file/naming patterns; keep views small and single-purpose.
