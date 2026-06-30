# Glossary — Design Spec

**Date:** 2026-06-29
**Status:** Approved
**Type:** Native macOS menu-bar utility (Swift 6.3 / SwiftUI + AppKit)

A keyboard-first, distraction-free glossary tool. Summon a centered, Raycast-style
overlay with a global hotkey, search a small tech glossary fuzzily, and reveal each
term's explanation through 4 tiers of progressive disclosure — all without the mouse.

---

## 1. Goals & non-goals

> **Update (v1.1):** the default summon hotkey is **⌥Esc** (Option+Space collides
> with Raycast) and is now **rebindable** in a Settings window; a **Mini** menu-bar
> presentation mode, **panel-size presets**, and **Light/Dark/System** theming were
> added. See the CHANGELOG for the full list.

**Goals (v1):**
- Global summon/hide overlay via a 2-key hotkey (default `⌥Esc`, configurable).
- Centered, floating, non-activating panel (does not steal focus from the user's work).
- Clipboard auto-load: on summon, if the clipboard matches a term, jump straight to it.
- Fuzzy, live search with arrow-key navigation.
- 4-tier progressive disclosure per term, driven entirely by the keyboard.
- `Cmd+C` copies a formatted text block of the active term.
- Premium, ultra-minimalist dark UI using the **KIKA** brand palette.

**Non-goals (deferred):** configurable hotkeys, multiple modules/categories,
in-app term editing, recents/persistence, light-mode toggle, iCloud sync.
The schema and hotkey layer leave room for these later.

---

## 2. Architecture

A thin **AppKit shell hosting SwiftUI**. A pure-SwiftUI menu-bar app cannot cleanly
deliver a centered, focus-preserving overlay bound to a global hotkey, so AppKit owns
the window/hotkey edges and SwiftUI renders everything visible.

### Module boundaries (isolation + testability)

- **`GlossaryCore`** (library, no AppKit) — fully unit-tested pure logic:
  - `Term` — Codable model.
  - `Glossary` — loads & decodes `glossary.json` from `Bundle.module`.
  - `FuzzyMatcher` — subsequence match + ranking.
  - `AppState` — `ObservableObject` holding query, results, selection, mode, and
    disclosure level; owns all transition logic.
  - `TermFormatter` — produces the `Cmd+C` clipboard text.
  - `Resources/glossary.json` — the 24 seed terms.
- **`Glossary`** (executable) — depends on `GlossaryCore`:
  - `main.swift` — boots `NSApplication`, `.accessory` activation policy.
  - `AppDelegate` — owns `NSStatusItem`, `OverlayPanelController`, `GlobalHotkey`.
  - `GlobalHotkey` — Carbon `RegisterEventHotKey` (no Accessibility permission).
  - `OverlayPanelController` — borderless transparent floating `NSPanel`, centering,
    clipboard read on summon, key routing.
  - `Theme.swift` — KIKA color tokens.
  - SwiftUI views — `RootView`, `SearchBar`, `ResultsList`, `TermDetailView`,
    `DisclosureBlock`.
- **`GlossaryCoreTests`** (Swift Testing) — tests `GlossaryCore`.

### Data flow

```
Option+Space ──► GlobalHotkey ──► OverlayPanelController.toggle()
                                        │ on show: read NSPasteboard
                                        ▼
                                   AppState.resolve(clipboard:) ──► mode/selection
                                        │
                           NSHostingView(RootView().environmentObject(appState))
                                        ▲
   key events ──► local NSEvent monitor ──► AppState mutations (filter / move / level / copy / dismiss)
```

---

## 3. Keyboard model — two explicit modes

`Space` must mean "type a space" while searching but "toggle Analogy" on a focused
term. Resolved with two modes rather than heuristics:

- **List mode** — search field is first responder.
  - Typing → live fuzzy filter (frecency breaks ties; see Ranking below).
  - `↑` / `↓` → move highlight through results.
  - `Enter` → focus highlighted term → **Detail mode** (text field resigns).
- **Detail mode** — text field is *not* first responder.
  - `Space` / `Enter` → **step disclosure**: open the next block (Analogy → Why It
    Matters → Example); once all are open, each press closes the last-opened block,
    then it cycles. Single-key, no `Cmd+D`.
  - `Cmd+C` → copy formatted block of the active term.
  - Any character or `↑` / `↓` → return to **List mode** and apply.
- **`Escape`** is two-stage: from Detail mode it returns to the list (Back); from
  List mode it dismisses + clears all state. The summon hotkey always toggles/hides.

### Progressive disclosure (single-key stepper)

`AppState.revealCount` (0…3) drives an ordered, `Space`-stepped accordion:
- **Always** — title block + "What It Is".
- `revealCount ≥ 1` — "Analogy"; `≥ 2` — "Why It Matters"; `≥ 3` — "Example".

`stepDisclosure()` (Space/Enter) opens the next block until all three are open, then
reverses and closes them one at a time (Example first), then cycles. Focusing a new
term or returning to the list resets it to 0. `Cmd+D` was removed in favour of the
single-key flow.

### Ranking (frecency)

Opening a term records an open (count + timestamp) in a `UsageStore`. `frecencyScore`
weights frequency by recency (recent opens count more; old ones decay). `AppState`
applies it **softly**: the empty-search browse list is ordered by frecency, and when
searching it only breaks ties between equal fuzzy scores — a better text match always
wins. Persistence (`DefaultsUsageStore`, UserDefaults) lives in the app layer; the
scoring is pure and tested in `GlossaryCore`.

---

## 4. Clipboard auto-load

On every summon, `OverlayPanelController` reads `NSPasteboard.general` string and calls
`AppState.resolve(clipboard:)`:
1. Case-insensitive exact match on `term` → focus it (Detail mode, Level 1).
2. Else strong fuzzy match above a score threshold → focus best.
3. Else → List mode, empty query, first result highlighted.

---

## 5. Data model

```swift
struct Term: Codable, Identifiable, Hashable {
    let id: String
    let term: String
    let whatItIs: String
    let analogy: String
    let whyItMatters: String
    let example: String
}
```

Seeded from the user's original 24 tech terms (Framework, Proxy, HTTP, HTTPS,
Interface, VPS, MCP Server, MCP Tunnel, SDK, ACP, CI, MongoDB, API, JSON, Webhook,
Environment Variables, Middleware, Docker, Git, Deployment, Encryption, DNS, Endpoint,
Frontend vs. Backend), since expanded to **54** with common web/dev/networking terms
(cache, cookie, CDN, load balancer, Kubernetes, cloud, OAuth, REST, GraphQL,
microservices, SSH, regex, async, and more). Flat list — no module grouping in v1.

---

## 6. Visual design — KIKA brand

Forced dark appearance. Glassmorphism via `NSVisualEffectView` panel background +
SwiftUI `.ultraThinMaterial` cards. SF system font (brand font Fira Sans/Code is an
optional later bundle).

**Palette (KIKA dark theme):**

| Token | Hex | Use |
| --- | --- | --- |
| `bg` | `#2C2D2F` | window base |
| `surface` | `#202024` | deeper layer |
| `card` | `rgba(0,0,0,.16)` | card fill over glass |
| `fg` | `#E7E5E0` | primary text |
| `fg2` | `#B9B8B3` | secondary text |
| `fg3` | `#8C8D8F` | dim text / hints |
| `accent` | `#6D80A6` | slate-blue accent, selection |
| `line` | `rgba(231,229,224,.10)` | hairlines |
| `line2` | `rgba(231,229,224,.05)` | faint dividers |

**Disclosure-block header accents** (low-saturation, brand-derived — used as a tint
behind the header label, not full fills):

| Block | Name | Hex |
| --- | --- | --- |
| What It Is | Slate Blue | `#6D80A6` |
| Analogy | Sand | `#B9B8B3` |
| Why It Matters | Coral | `#FF8A80` |
| Example | Dusty Lilac | `#9B8FA6` |

Layout: ~640pt-wide panel, search bar on top, results list (List mode) or focused
term detail (Detail mode) below. Subtle keyboard-hint footer (`␣ analogy   ⌘D deep
dive   ⌘C copy   esc close`).

---

## 7. Build, run, test

- **Build app:** `scripts/build-app.sh` → `swift build -c release`, assemble
  `Glossary.app` (Info.plist `LSUIElement=YES`, bundle id, version), copy the binary +
  SPM resource bundle into `Contents/`, ad-hoc codesign. Double-click or add to Login
  Items; `Option+Space` summons it.
- **Dev run:** `swift run Glossary`.
- **Test:** `swift test` (Swift Testing target against `GlossaryCore`).

---

## 8. Testing strategy

Unit-tested (pure logic, no UI):
- `FuzzyMatcher` — ordering, subsequence matching, empty query, no-match.
- `Glossary` — decodes all 54 terms; required keys present.
- `AppState.resolve(clipboard:)` — exact / fuzzy / miss / case-insensitive.
- `AppState` transitions — list↔detail mode, independent disclosure toggles, dismiss reset.
- `TermFormatter` — clipboard text shape for a known term.

Manual checklist (needs a live window-server session): Carbon hotkey summon/hide,
panel centering, non-activation, key routing, glass appearance.

---

## 9. Project layout

```
teacher/
  Package.swift
  CLAUDE.md  README.md  CHANGELOG.md  TODO.md
  docs/superpowers/specs/2026-06-29-glossary-menu-bar-design.md
  Sources/
    GlossaryCore/{Term,Glossary,FuzzyMatcher,AppState,TermFormatter}.swift
    GlossaryCore/Resources/glossary.json
    Glossary/{main,AppDelegate,GlobalHotkey,OverlayPanelController,Theme}.swift
    Glossary/Views/{RootView,SearchBar,ResultsList,TermDetailView,DisclosureBlock}.swift
  Tests/GlossaryCoreTests/*.swift
  scripts/build-app.sh
```
