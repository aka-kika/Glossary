# TODO

Living task list. Check items off as they land; add follow-ups as you find them.
(See [CLAUDE.md](CLAUDE.md) — docs get updated on every change.)

## v1 — build the app

### Project setup
- [x] Approve design spec
- [x] Write project docs (CLAUDE.md, README, CHANGELOG, TODO)
- [x] `Package.swift` — `GlossaryCore` (library) + `Glossary` (executable) + tests
- [x] `.gitignore`

### GlossaryCore (pure logic, tested)
- [x] `Term` model (Codable, Identifiable, Hashable)
- [x] `Glossary` JSON loader (`Bundle.module`) + `Resources/glossary.json` (24 terms)
- [x] `FuzzyMatcher` (subsequence match + ranking)
- [x] `AppState` (modes: List/Detail; independent disclosure toggles; transitions)
- [x] `AppState.resolve(clipboard:)` (exact / fuzzy / miss)
- [x] `TermFormatter` (Cmd+C clipboard text)
- [x] Unit tests for all of the above (`swift test` green — 26 tests)

### Glossary executable (AppKit + SwiftUI)
- [x] `main.swift` + `.accessory` activation policy
- [x] `AppDelegate` + `NSStatusItem` menu-bar icon
- [x] `GlobalHotkey` (Carbon `RegisterEventHotKey`, `Option+Space`)
- [x] `OverlayPanelController` (floating `NSPanel`, centering, clipboard read, key routing)
- [x] `Theme.swift` (KIKA palette)
- [x] Views: `RootView`, `SearchBar`, `ResultsList`, `TermDetailView`, `DisclosureBlock`
- [x] Glassmorphism + dark appearance + keyboard-hint footer

### Packaging
- [x] `scripts/build-app.sh` → `Glossary.app` (LSUIElement, resource bundle, ad-hoc sign)
- [ ] Manual verification checklist (hotkey, centering, non-activation, key routing)

### Manual verification checklist (needs a live desktop session)
- [ ] `Option+Space` summons / hides the overlay from any app
- [ ] Panel appears centered and floats above other windows
- [ ] Typing filters; `↑`/`↓` navigate; `Enter` focuses a term
- [ ] `Space` toggles Analogy; `Cmd+D` toggles deep dive; `Cmd+C` copies
- [ ] `Escape` dismisses and clears state
- [ ] Clipboard auto-load: copy "Docker", summon → opens Docker
- [ ] Glassmorphism + KIKA dark palette render correctly

## Later (deferred from v1)
- [ ] Configurable global hotkey
- [ ] Modules / categories grouping
- [ ] In-app term editing
- [ ] Recents / persistence
- [ ] Bundle Fira Sans/Code brand fonts
- [ ] App icon + light-mode option
