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
- [x] `Glossary` JSON loader (`Bundle.module`) + `Resources/glossary.json` (54 terms)
- [x] `FuzzyMatcher` (subsequence match + ranking)
- [x] `AppState` (modes: List/Detail; independent disclosure toggles; transitions)
- [x] `AppState.resolve(clipboard:)` (exact / fuzzy / miss)
- [x] `TermFormatter` (Cmd+C clipboard text)
- [x] Unit tests for all of the above (`swift test` green — 35 tests)

### Glossary executable (AppKit + SwiftUI)
- [x] `main.swift` + `.accessory` activation policy
- [x] `AppDelegate` + `NSStatusItem` menu-bar icon
- [x] `GlobalHotkey` (Carbon `RegisterEventHotKey`; default `⌥Esc`, rebindable)
- [x] `OverlayPanelController` (floating `NSPanel`, centering, clipboard read, key routing)
- [x] `Theme.swift` (KIKA palette)
- [x] Views: `RootView`, `SearchBar`, `ResultsList`, `TermDetailView`, `DisclosureBlock`
- [x] Glassmorphism + dark appearance + keyboard-hint footer

### Packaging
- [x] `scripts/build-app.sh` → `Glossary.app` (LSUIElement, resource bundle, ad-hoc sign)
- [x] `scripts/release-dmg.sh` → Developer-ID-signed, Apple-notarized, stapled DMG
      (opens via double-click after download — no Gatekeeper prompt)
- [ ] Upload the notarized `Glossary-0.1.0.dmg` to the GitHub v0.1.0 release (replace the
      ad-hoc asset that was being blocked on download)
- [ ] Manual verification checklist (hotkey, centering, non-activation, key routing)

### Manual verification checklist (needs a live desktop session)
- [ ] `⌥Esc` summons / hides the overlay from any app
- [ ] Panel appears centered and floats above other windows
- [ ] Typing filters; `↑`/`↓` navigate; `Enter` focuses a term
- [ ] `Space` steps disclosure (Analogy → Why It Matters → Example, then closes); `Cmd+C` copies
- [ ] `Escape` dismisses and clears state
- [ ] Clipboard auto-load: copy "Docker", summon → opens Docker
- [ ] Glassmorphism + KIKA dark palette render correctly

## v1.1 — settings & modes (done)
- [x] Default hotkey → ⌥Esc; rebindable in Settings (live re-register)
- [x] Settings window (UserDefaults): hotkey, window style, size, theme,
      launch at login, clipboard toggle, reset to defaults
- [x] Mini mode — menu-bar popover showing only "What It Is"
- [x] Panel size presets (Small / Medium / Large)
- [x] Light / Dark / System theme (dynamic KIKA tokens)
- [x] Launch at login (SMAppService)
- [x] Esc two-stage Back (term → list → dismiss)

### Verify (needs a live desktop session)
- [ ] ⌥Esc summons; rebinding in Settings takes effect immediately
- [ ] Mini mode opens from the menu-bar icon, shows search + What It Is only
- [ ] Panel size + theme changes apply on next summon
- [ ] Launch at login registers/unregisters (check System Settings → Login Items)
- [ ] Esc goes back to the list from a term, then closes

## v1.2 — add-your-own terms (done)
- [x] Editable glossary file in Application Support (seeded from bundle)
- [x] Settings: Open file, Reveal in Finder, Reload, Copy template, Reset to default
- [x] `AppState.updateTerms` for runtime reload; usage survives by term id
- [x] Smart merge of new built-ins on update (keeps edits; respects deletions)

## v1.3 — branding (done)
- [x] App icon wired into the bundle (icns generated from Resources/AppIcon.png)
- [x] Matching menu-bar `{ / }` glyph (StatusItemIcon template)

## Later (deferred)
- [ ] Optional in-app "Add Term" form (vs. editing the JSON file)
- [ ] Free-form hotkey recorder (vs. preset list)
- [ ] Modules / categories grouping
- [ ] Bundle Fira Sans/Code brand fonts
