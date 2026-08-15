# Design notes and review log

Companion to [REQUIREMENTS.md](REQUIREMENTS.md) and [RESEARCH.md](RESEARCH.md).
Records why things are built the way they are, and every defect found along the way.

> Rebuilt 2026-08-15 after the project folder was emptied by another process. The app
> itself was recovered intact from GitHub; these notes were reconstructed from the work.
> **The docs now live in the repo too**, so a lost folder can never take them again.

## 1. Technology

**One self-contained `index.html`** — vanilla HTML/CSS/JS, no framework, no build step.

| Option | Verdict |
|---|---|
| **Single HTML file** ✅ | Double-click to open, instant load, zero maintenance, works offline forever. |
| React/Vite | Needs Node and a build step; adds nothing at this scope. |
| Flask/FastAPI + SQLite | A server you must remember to start = an app that silently stops working. |
| Electron | 200 MB for a calculator-sized problem. |

Neither Node nor Python is installed on the target laptop, which also ruled out anything
needing a local runtime when sync was added later.

## 2. The one idea the whole app rests on

**Money moving between two states you have already counted must never move the number you
spend by.** Everything derives from it:

| Action | current | available |
|---|---|---|
| Owed → Received | ↑ | unchanged |
| Essential / Reimbursed logged | ↓ | unchanged (owed entry offsets it) |
| Laundry set aside | unchanged | ↓ |
| Laundry spent | ↓ | unchanged (already held) |
| Card charged | unchanged | ↓ |
| Card paid | ↓ | unchanged (already deducted) |

Six features, one invariant. Each new section was implemented by finding the term to add to
`available` rather than by special-casing the UI.

## 3. Derived, never stored

Balances, owed outstanding amounts and archive figures are **computed from the entry log**
every time. This is why editing or deleting a months-old entry can never desync anything.

Storing `remaining` on owed entries was the original design and had to be undone (§6, v3);
the same mistake would have recurred with laundry and card had they stored totals.

## 4. Storage

| Layer | Role |
|---|---|
| **IndexedDB** | Primary store. |
| **localStorage** | Mirror, **written first** and synchronously, so a hard close mid-save still keeps the newest data. |
| **Private repo `data.json`** | Once sync is on. Survives clearing browser data or changing device. |

Boot reads all three and takes the newest by `savedAt`. Writes are queued through a promise
chain. `navigator.storage.persist()` is requested but never relied on.

## 5. Sync

Data lives in a **private GitHub repo** via the Contents API, with a fine-grained token
scoped to that one repo, stored per device. A *secret gist* was rejected on a factual check:
unlisted is not private.

Merging is a union by row id, newest edit wins, deletions are tombstones. Row-shaped
storage (`id` + `updatedAt`) means laundry amounts and saved lists merge through the same
`mergeRows()` with no special handling.

Clock drift is handled by a Lamport-style `clockFloor`: local stamps always exceed the
newest timestamp ever seen, so an edit made *after* seeing another device's data wins even
if that device's clock runs fast.

## 6. Review log — every defect found

### v1 (initial build)
- ❌ Stored `currentBalance` as a mutable number → edits could desync it. Switched to
  deriving from an event log.
- ❌ "Received" only deleted the owed entry, breaking the available invariant. Added a
  `received` transaction type.
- ❌ `toISOString()` would log evening expenses on the wrong day in IST. Local `YYYY-MM-DD`
  strings only.
- ❌ Rupee floats risked `0.1+0.2` errors. Integer paise throughout.
- ❌ Deleting a category orphaned its expenses. Archive instead of delete.
- ❌ Past months divided spend/day by *days elapsed now*. Use that month's full length.

### v2 (durable storage, launcher, archive)
- ❌ **Unawaited concurrent saves** could leave the localStorage mirror older than
  IndexedDB. Added a write queue; verified under 25 concurrent saves.
- ❌ IndexedDB received the live object, cloned asynchronously at a divergent moment.
  Hand it a snapshot instead.
- ❌ Auto-download on boot is blocked by browsers. Deferred to a user-clicked banner.
- ❌ Archiving by *moving* entries would break balance derivation. Summary-only archive.
- ⚠️ `persist()` was denied in testing — treated as a bonus, never relied on.

### v3 (editable entries)
- ❌ **Archive records went stale** when a past-month entry was edited. Rebuilt from live
  entries on every change.
- ❌ `reopenOwed` mutated before validating, so a refused reopen had already cleared the
  close date.
- ❌ The zero check for minimum balance was a string hack rejecting `"0.00"`.
- ⚠️ Editing a payment had to compare against *other* payments, or raising a part-payment
  would fail its own guard.

### v4 (phone sync)
Three of these were invisible to unit tests and only surfaced in a two-device simulation
against a mock GitHub API:
- ❌ **Infinite push loop (1):** `meta` key *order* differed between pulled and merged
  copies — identical data, different JSON string. Would have committed every 25 seconds
  forever. Fixed by comparing a canonical form.
- ❌ **Infinite push loop (2):** a state that never went through a merge wasn't sorted, so
  row order flipped each round.
- ❌ **Merge wasn't commutative** — `merge(A,B)` and `merge(B,A)` differed.
- ❌ **Clock skew could undo a delete.** Fixed with `clockFloor`.
- ❌ **Encoding corruption:** two bulk edits made with PowerShell 5.1 read the UTF-8 file as
  Windows-1252, double-encoding all 43 `₹`, `—` and `→` characters. The test suite could not
  catch it — both sides of each assertion were equally corrupted — and it only surfaced in a
  screenshot. **Never bulk-edit this file with PowerShell's `Get-Content`/`Set-Content`.**

### v4a (restore path)
- ❌ **Sync bailed out when a device had no local data**, stranding a new phone on the setup
  screen despite a valid token. It now adopts the remote copy. Compounded by iOS keeping
  Home Screen apps and Safari tabs in separate storage.

### v5 (essentials, laundry)
- ❌ `monthAdded()` counted anything that wasn't an expense, so the new types would have
  been reported as *money added*.
- ❌ The dashboard's balance history filtered the same way and would have listed them as income.
- ❌ `curBalance()` only subtracted `expense`, so new types would have *increased* the balance.

### v6 (saved owed lists)
- ⚠️ Clipboard writes are refused outside a real tap in some browsers; falls back to a
  selected textarea, then to on-screen text.
- ⚠️ Collecting against a since-deleted entry still records the payment (frozen amounts mean
  the money did arrive); it appears in balance history with an Undo.
- ⚠️ Test artifact: `innerText` returns CSS-uppercased headings, so a case-sensitive
  assertion read false while rendering correctly.

### v7 (credit card)
- ❌ Balance code was `isSpend ? −amount : +amount` — i.e. **anything that isn't spending is
  income**. An unpaid card charge is neither, so it would have *added* to the balance.
  Replaced with an explicit three-way `txnDelta()`.
  **This was the third bug of that shape** (twice in v5). The lesson: enumerate the positive
  cases, never the complement.

### v8 (reimbursed)
- Refactored Essentials and Reimbursed onto one view and one dialog driven by a `SIDE_META`
  table, rather than adding a fourth branch to a chain of per-type conditionals. No new
  defects — the table made the addition mechanical.

## 7. Testing

`index.html?test=1` runs **249 assertions** in the browser, covering balance rules, date
maths, month rollover, archiving, editing, all four side sections, owed lists, merge
semantics and data migration.

Beyond that, every feature was driven through the **real UI** with scripted clicks, and each
balance claim measured rather than assumed. Since the preview harness stopped serving local
files from a storage-enabled origin, that walkthrough now runs against the deployed GitHub
Pages build — a better test of the real target anyway.

Two classes of bug the unit tests provably cannot catch, both of which bit:
- **Encoding corruption** — assertions compare equally-corrupted strings and pass.
- **Sync convergence** — needs two devices and a real request/response loop to observe.

Screenshots and the two-device simulation exist because of those.
