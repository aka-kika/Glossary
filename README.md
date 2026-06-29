# Glossary

A keyboard-first, distraction-free macOS menu-bar glossary. Summon a centered,
Raycast-style overlay with a global hotkey, fuzzy-search a small tech glossary, and
reveal each term through four tiers of progressive disclosure — without touching the
mouse.

> Native Swift 6 / SwiftUI + AppKit · Apple Silicon · macOS 14+ · **KIKA** brand.

## Features

- **Global summon** — `Option+Space` shows/hides a floating overlay from anywhere.
- **Clipboard auto-load** — on summon, if your clipboard matches a term, it loads instantly.
- **Fuzzy search** — type to filter; `↑`/`↓` to navigate results.
- **Progressive disclosure** — reveal more only when you want it (4 tiers).
- **Copy** — `Cmd+C` copies a clean, formatted block of the active term.
- **Keyboard-only** — no mouse interaction required for anything.

## Keyboard

| Key | Action |
| --- | --- |
| `Option+Space` | Summon / hide the overlay (global) |
| Type | Fuzzy-filter terms (List mode) |
| `↑` / `↓` | Move through results |
| `Enter` | Focus the highlighted term |
| `Space` / `Enter` | Toggle **Analogy** (Level 2) |
| `Cmd+D` | Toggle **Why It Matters + Example** (Level 3) |
| `Cmd+C` | Copy the active term |
| `Escape` | Dismiss and clear |

## Build & run

Requires Xcode 26 / Swift 6.3 toolchain.

```bash
swift run Glossary        # run in dev
swift test                # run unit tests
scripts/build-app.sh      # build a distributable Glossary.app
```

`scripts/build-app.sh` produces `Glossary.app`, a true menu-bar agent (no Dock icon,
`LSUIElement`). Double-click it, or add it to **System Settings → General → Login
Items** to have it ready at all times. Press `Option+Space` to summon.

## Data

Terms live in [`Sources/GlossaryCore/Resources/glossary.json`](Sources/GlossaryCore/Resources/glossary.json)
as a flat array. Each entry has: `id`, `term`, `whatItIs`, `analogy`, `whyItMatters`,
`example`. Edit the JSON and rebuild to change the glossary.

## Project layout

See [CLAUDE.md](CLAUDE.md) and the [design spec](docs/superpowers/specs/2026-06-29-glossary-menu-bar-design.md).
