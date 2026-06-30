# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-06-29

### Added
- **MIT `LICENSE`.**
- **Polished README** — app-icon header, badges, and screenshots (Overlay search,
  expanded term in light theme, and Mini mode) under `docs/screenshots/`.

### Fixed
- **Rebinding the summon hotkey now works.** Three compounding bugs: (1) the change
  handler read `settings.hotkeyID` while `@Published` notifies in `willSet`, so it
  re-registered the *old* id every time — now the new id is taken from the publisher;
  (2) a static table retained every hotkey forever, so the old one was never
  unregistered; (3) a duplicate Carbon event handler was installed on each rebind,
  making the new key toggle twice. The handler is now installed once and old keys are
  released, so the new hotkey takes effect, the old one stops, and the menu's "Show
  Glossary" shortcut updates with it.
- **Light-mode disclosure-block colors are legible.** The accents (especially the
  Analogy "sand" tone) were invisible on the light surface; they now adapt to
  darker, more-saturated variants in light mode.

### Added
- **App icon** (dark open book with `{ / }` code braces). `scripts/build-app.sh`
  generates `AppIcon.icns` (16–1024px) from `Resources/AppIcon.png` and sets
  `CFBundleIconFile`.
- **Matching menu-bar glyph** — a monochrome `{ / }` (`StatusItemIcon`, drawn in
  code as a resolution-independent template) echoing the icon, replacing the
  previous `character.book.closed` SF Symbol.
- **Editable glossary file** — on first run the app seeds
  `~/Library/Application Support/Glossary/glossary.json` from the built-in terms,
  then loads from it, so you can add terms without rebuilding. Settings gains a
  **Glossary** section: Open File, Reveal in Finder, Reload, Copy New-Term
  Template, Add New Built-in Terms, and Reset to Default. Invalid JSON falls back
  to the built-in set with a message. (`GlossaryLibrary` + `AppState.updateTerms`.)
- **Smart built-in merge** — when an app update ships new built-in terms, they are
  merged into your file automatically on launch (and via the button), preserving
  your custom terms and edits. Built-ins you deliberately deleted are not
  resurrected, tracked via an "already-merged" id record. Pure diff logic
  (`Glossary.newBuiltins`) is unit-tested.
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

### Added
- Two more summon-hotkey presets: **⌃ Esc** and **⇧ Esc** (the Esc-based options
  are now grouped together in the picker).
- **Polished Settings window** — an app header (icon + name + version), sections
  with SF Symbol labels, the glossary actions in a compact **2-column grid** of
  labelled buttons showing the file path, and a "Reset All Settings to Defaults"
  action. Window tightened to 480×580.
- Menu-bar menu polish: **Show Glossary** now displays the current summon hotkey
  and the app's `{ / }` glyph; Settings and Quit got icons too.

### Changed
- **Overlay hugs its content, instantly** — a focused term sizes to its visible
  blocks so there's no dead space, the window resizes with **no animation**, and the
  block reveal is now **instant** (the slide-in was the distracting part). The list
  keeps a stable height so typing doesn't resize the window.
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
