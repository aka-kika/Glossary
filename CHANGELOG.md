# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
