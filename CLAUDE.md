# CLAUDE.md — Glossary

Project memory for Claude Code. Read this first.

## What this is

**Glossary** — a native macOS menu-bar utility (Swift 6.3, SwiftUI + AppKit). A
keyboard-first, distraction-free glossary: summon a centered Raycast-style overlay
with `Option+Space`, fuzzy-search a small tech glossary, and reveal each term through
4 tiers of progressive disclosure — no mouse required.

Design spec: [docs/superpowers/specs/2026-06-29-glossary-menu-bar-design.md](docs/superpowers/specs/2026-06-29-glossary-menu-bar-design.md)

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
- Two keyboard modes — **List** (typing/arrows) and **Detail** (Space/⌘D/⌘C). `Esc`
  is two-stage (Back from a term, then close). See spec §3.
- Default hotkey **⌥Esc** (rebindable in Settings). Presentation: Overlay or Mini.
- Brand: **KIKA** palette, dynamic light/dark tokens in `Theme.swift`. Accent
  `#6D80A6`; dark bg `#2C2D2F` / fg `#E7E5E0`. See spec §6.

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
