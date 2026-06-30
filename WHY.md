# Why Glossary exists

> A keyboard-first, distraction-free macOS menu-bar glossary.
> The short version is in the [README](README.md#why); this is the long one.

## The problem

Learning a technical field means meeting unfamiliar terms constantly — *idempotent*,
*frecency*, *hardened runtime*, *backpressure*. Looking one up sounds free, but it
isn't. You leave what you're doing, switch to a browser, wade past SEO filler and
cookie banners, skim a definition written for someone who already knows it, and then
try to rebuild the context you just dropped. The lookup costs more than the answer.

Most "glossary" tools make this worse, not better. They're either a wall of text you
scroll, or a search box bolted onto a website you have to *go to*. Neither respects the
moment you're actually in: mid-thought, mid-task, wanting one clear sentence and then
to get back to work.

## The bet

Glossary is built on one bet: **the cost of looking something up should be near zero —
in time, in mouse travel, and in cognitive load.** Three choices follow from that.

1. **It comes to you.** It lives in the menu bar and opens anywhere on a global hotkey
   (`⌥Esc`). No app to switch to, no tab to find. Copy a term, summon, and it's already
   open. The overlay floats without stealing focus, so your work stays put behind it.

2. **It reveals just enough, then a little more.** Each term unfolds in four tiers —
   a one-line plain summary, an everyday **analogy**, **why it matters**, then a concrete
   **example** — advanced one block at a time with a single key (`Space`). You read only
   as deep as you need and stop. Progressive disclosure is the whole point: the first
   line answers most questions; the rest is there when it isn't.

3. **It never asks for the mouse.** Type to fuzzy-search, arrow to choose, `Enter` to
   open, `Space` to go deeper, `⌘C` to copy, `Esc` to back out. Frecency quietly floats
   the terms you reach for most — without ever beating a better text match. The whole
   loop is muscle memory, so the tool disappears and the learning stays.

## Design principles

- **Distraction-free by construction.** One panel, no chrome, no notifications, no feed.
  It opens, answers, and gets out of the way.
- **Local and private.** Terms live in a plain JSON file on your Mac. No account, no
  network, no telemetry. Nothing about what you look up leaves the machine.
- **Yours to edit.** The glossary is *your* glossary. Add terms by editing one file —
  no rebuild. New built-ins merge in on update without touching your edits.
- **Native and light.** A thin AppKit shell hosting SwiftUI; a menu-bar agent with no
  Dock icon. It should feel like part of the OS, not a browser in a costume.
- **Testable core.** All the real logic (matching, ranking, disclosure, formatting) is
  pure and unit-tested in `GlossaryCore`; the AppKit/Carbon edges stay thin.

## What it is *not*

- **Not a dictionary or encyclopedia.** It's a small, curated set of terms *you* care
  about, explained for a learner — not an exhaustive reference.
- **Not a note-taking app.** It explains terms; it doesn't store your thoughts.
- **Not cloud software.** No sync, no accounts, no server. Deliberately.
- **Not an AI generator.** Definitions are written and owned by you, so they're
  consistent, correct, and in your voice — not regenerated on every open.

## Who it's for

Anyone learning a technical vocabulary who wants the lookup to cost a keystroke instead
of a context switch — and who'd rather build their own crisp, reusable explanations than
re-read a stranger's every time.

---

For the engineering design, see [docs/design-spec.md](docs/design-spec.md).
For the build map and conventions, see [CLAUDE.md](CLAUDE.md).
