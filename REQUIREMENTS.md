# Expense Tracker — Requirements

**Owner:** Syon Pratap · Started 2026-08-10 · Companion to [PLAN.md](PLAN.md) and
[RESEARCH.md](RESEARCH.md)

## 1. Purpose

A personal tracker for daily campus spending. It answers two questions at a glance:

1. **How much can I safely spend, and how much per day for the rest of the month?**
2. **Where is my money going, outlet by outlet?**

## 2. Core concepts

| Term | Definition |
|---|---|
| **Current balance** | Money you actually have right now. |
| **Min balance** | A floor you never want to dip below. |
| **Owed balance** | What others owe you. Not in current — you don't have it yet. |
| **Available** | What's genuinely spendable (§2.1). |
| **Avg/day (spendable)** | `available ÷ days remaining` (counted from tomorrow; today is already under way). |
| **Spend/day so far** | `month spent ÷ days elapsed` (today counts as elapsed). |

### 2.1 The balance equation

```
laundryHeld = max(0, laundryAmount(thisMonth) − laundrySpent(thisMonth))
cardPending = Σ unpaid card charges
available   = current − min + (includeOwed ? owedTotal : 0) − laundryHeld − cardPending
```

Current balance is **derived** from entry history, never stored:

```
current = initialBalance + Σ(add, received, adjust) − Σ(expense, essential, reimbursed,
                                                       laundry, paid card charges)
```

An **unpaid** card charge counts as neither spending nor income — it affects available only.

### 2.2 Owed lifecycle

- **Add** → owed ↑ → available ↑. Current unchanged.
- **Received** → owed closes, **current ↑ by the same amount** → available **unchanged**.
- **Write off** → owed ↓, current unchanged → available ↓.

This is the invariant the whole app is built on: money moving between two states you have
already counted must never move the number you spend by.

## 3. Functional requirements

### 3.1 Dashboard
- **FR-1** Show current, min, available, owed, avg spendable/day, and every side-section total.
- **FR-2** Toggle "include owed in available" — default ON, persisted.
- **FR-3** Show days remaining beside avg/day so the maths is transparent.
- **FR-4** Edit current (via an adjustment entry) and min balance.
- **FR-5** Show this month's spent and spend/day.
- **FR-6** Warn visually when available ≤ 0 or current < min.

### 3.2 Expenses
- **FR-7** Default outlets: Vending Machine, Mess, Night Canteen, RC, JV Shetty, IC,
  Nescafe, INS, Subspot, Other Canteens.
- **FR-8** Add/rename/**archive** custom categories (archive, not delete, so history survives).
- **FR-9** Add expense: amount > 0, date (defaults today, editable), optional note.
- **FR-10** Per category: entry list, month total, spend/day.
- **FR-11** An "All" view across categories with the same stats.
- **FR-12** Edit and delete any expense; balances recalculate.
- **FR-13** Month navigation. Stats are month-scoped; balances are global.

### 3.3 Owed
- **FR-14** Add owed: label, amount, date, optional note.
- **FR-15** Close via **Received** (adds to current) or **Write off** (doesn't). History kept.
- **FR-15a** Partial receipt leaves the entry open with the remainder.

### 3.4 Balance management
- **FR-16** "Add money" and signed "Adjust" entries so current is always derivable.
- **FR-17** First-run setup asks for starting balance and min balance.

### 3.5 Data & platform
- **FR-18** Free, no login, works offline.
- **FR-19** Closing the window, browser or laptop changes nothing.
- **FR-20** One-click JSON export and import/restore.
- **FR-21** Amounts in ₹ as integer paise; no floating-point drift.
- **FR-22** Written to two independent browser stores; either can rebuild, newest wins.
  The synchronous store is written first so an abrupt close can't lose the last change.
- **FR-23** Writes are queued, never concurrent.
- **FR-24** Optional linked file on disk (File System Access API).
- **FR-25** Save state visible; a failed save raises a banner offering an export.
- **FR-26** One-click launcher plus a desktop-shortcut creator.

### 3.6 Monthly rollover & archive
- **FR-27** Each finished month is summarised: spent, spend/day, money added, closing
  balance, per-category breakdown, entry count, and every side-section total.
- **FR-28** Month stats reset; balances carry over.
- **FR-29** Raw entries are **never deleted** by archiving.
- **FR-30** Idempotent, handles multi-month gaps and year boundaries; empty months skipped.
- **FR-31** Archive tab: month cards, per-month export, jump to that month's entries.

### 3.7 Editing
- **FR-32** Every entry is editable and deletable from where it's listed.
- **FR-33** **Undo payment** removes a received payment, takes the money back out of
  current and restores the owed entry.
- **FR-34** An owed entry's outstanding amount is **derived** from its payments; loading
  re-derives it, self-healing inconsistency.
- **FR-35** Closed owed entries can be reopened (fully-paid ones only via undoing payment).
- **FR-36** Guards: an owed total can't drop below what's been received; a payment can't
  exceed the outstanding amount.
- **FR-37** Editing an entry in an archived month updates that archive record.
- **FR-38** Starting and minimum balance editable in Settings; both accept zero.

### 3.8 Multi-device sync
- **FR-39** Reachable from a phone, installable, usable offline.
- **FR-40** Data stored somewhere **genuinely private** (a private repo, not a gist).
- **FR-41** One-time setup per device; token is device-local, never synced.
- **FR-42** Automatic: on open, refocus, reconnect, a 25 s poll, and after any change.
- **FR-43** Changes merge **per entry**: both devices' entries survive, deletions propagate
  as tombstones, most recent edit wins.
- **FR-44** Merging is commutative, idempotent and canonical, so devices converge.
- **FR-45** Edit timestamps are protected against device clock drift.
- **FR-46** Sync state visible; failures explained; no failure can lose local data.
- **FR-46a** A device with **no local data** restores itself from the remote copy, and the
  setup screen offers that as a first-class option.

### 3.9 Essentials and Reimbursed
- **FR-47** Two separate sections, each with its own monthly and all-time totals:
  **Essentials** (things you'll get back) and **Reimbursed** (money fronted for someone else).
- **FR-48** Both reduce current balance but are **excluded** from "spent this month" and
  "spent/day".
- **FR-49** Adding either **automatically creates an owed entry** of the same amount, so
  available is unchanged.
- **FR-50** The entry and its owed entry are **independent once created**.
- **FR-50a** Neither is tied to an outlet — a free-text description only.

### 3.9a Saved lists of owed entries
- **FR-56a** Open owed entries can be selected and bundled into a named saved list.
- **FR-56b** Rendered as `label -> amount` per line with `Total -> X` last, one-tap copy.
- **FR-56c** Amounts are **frozen** when saved.
- **FR-56d** **Received all** collects every item at once; available unchanged.
- **FR-56e** Before collecting, warn about any item settled, edited or deleted since.
- **FR-56f** **Remove list** deletes only the grouping.
- **FR-56g** Collected lists kept as history; entries tagged with their list name.
- **FR-56h** Lists merge across devices.

### 3.10 Laundry
- **FR-51** An amount can be **set aside per month**; setting it reduces available, not current.
- **FR-52** Spending against it reduces current, leaving available **unchanged**.
- **FR-53** Overspending reduces available by **the excess only**.
- **FR-54** Excluded from spending figures, with its own total.
- **FR-55** The amount **carries forward** until changed; spending resets each month.
- **FR-56** Archived separately; merges across devices.

### 3.11 Credit card
- **FR-57** Charges record amount, date and **what it was for**.
- **FR-58** An unpaid charge reduces available and leaves current **unchanged**.
- **FR-59** Marking paid reduces current and leaves available **unchanged**. Per charge or
  whole bill, and undoable.
- **FR-60** Excluded from spending figures; own total; archived separately.
- **FR-61** A pending charge is **neither spending nor income** anywhere in the app.
- **FR-62** Deleting an unpaid charge restores available; deleting a paid one restores current.

## 4. Non-functional

- **NFR-1** Logging an expense takes ≤ 3 interactions.
- **NFR-2** Instant load, no build step, no server to keep running.
- **NFR-3** Data cannot be lost silently.
- **NFR-4** Usable on a phone screen.

## 5. Out of scope

Bank/UPI sync, receipt scanning, multi-user, currencies other than ₹, per-category budgets.

## 6. Decisions taken along the way

| Question | Decision |
|---|---|
| Does avg/day count today as remaining? | No — it counts from tomorrow. On the last day it shows the whole available rather than dividing by zero. |
| Do past-month expenses affect current balance? | Yes; they only appear in that month's stats. |
| Min balance changed mid-month? | Recalculates from now on; no history rewrite. |
| Essentials ↔ its owed entry | **Independent** once created. |
| Laundry in ₹/day? | No — own total. |
| Laundry on the 1st | Carries the amount forward. |
| Saved list amounts | **Frozen** at save time, with a drift warning at collect time. |
| Collected lists | Kept as history. |
| Card spending in ₹/day? | No — own total. |
| Paying the card | Per charge **and** whole bill. |
| Reimbursed | Same mechanics as Essentials, own bucket, description only. |
