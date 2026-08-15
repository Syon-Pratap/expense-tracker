# Research — existing trackers vs. what was needed

Companion to [REQUIREMENTS.md](REQUIREMENTS.md). Done before building, to check whether
anything off the shelf already did this.

## App-by-app

### Actual Budget (open source, MIT, local-first)
Envelope/zero-sum budgeting, runs on-device, works offline, optional encrypted sync.
**Matches:** local-first, private, month-scoped views, category totals.
**Misses:** no `available = current − min` concept, no per-day safe-to-spend, and envelope
budgeting forces assigning income to envelopes — heavier than "log a samosa in 3 taps".
IOUs would have to be faked with off-budget accounts.
**Verdict:** closest philosophy, wrong budgeting model.

### Firefly III (open source, self-hosted)
Full double-entry bookkeeping: multi-account, rules, bills, reports, REST API.
**Matches:** could model owed money as accounts; rich reporting.
**Misses:** needs a server running permanently; no daily safe-to-spend; min-balance floor
isn't a native idea.
**Verdict:** far too much machinery for one person's canteen spending.

### PocketGuard (commercial)
"In My Pocket" = income − bills − goals − budgets, shown per-day for the days left.
**Matches:** this *is* the avg-spendable-per-day feature — good validation of the dashboard.
**Misses:** cloud, US-bank-centric, subscription, no manual-first local mode, no IOUs.
**Verdict:** borrowed the idea, couldn't use the product.

### Splitwise (commercial)
Group IOU tracking with running balances and settle-up.
**Matches:** the Owed tab is essentially single-sided Splitwise.
**Misses:** cloud, social, no personal balance or expense tracking.
**Verdict:** borrowed the settle-up interaction and open/closed lifecycle.

### Money Manager EX / GnuCash / KMyMoney (open source desktop)
**Matches:** local, free, category reports.
**Misses:** accounting-style UI, slow entry, no safe-to-spend, no min-balance floor.
**Verdict:** proves local desktop finance apps work, but entry friction is fatal for daily use.

### Daily-budget apps (Spendaily and similar)
**Matches:** a daily allowance front and centre; log-in-seconds entry.
**Misses:** phone-only, cloud, no owed handling, no custom outlets.
**Verdict:** confirms that entry speed is the make-or-break feature.

## Gap analysis

| Requirement | Actual | Firefly | PocketGuard | Splitwise | MMEX |
|---|---|---|---|---|---|
| Local, offline, free | ✅ | ⚠️ server | ❌ | ❌ | ✅ |
| available = current − min (+ owed) | ❌ | ❌ | ⚠️ similar | ❌ | ❌ |
| Owed-in-available with a toggle | ❌ | ⚠️ manual | ❌ | ❌ | ❌ |
| Avg spendable/day | ❌ | ❌ | ✅ | ❌ | ❌ |
| Per-category spend/day | ⚠️ | ⚠️ | ⚠️ | ❌ | ⚠️ |
| Custom campus outlets | ✅ | ✅ | ⚠️ | ❌ | ✅ |
| 3-tap entry, editable date | ⚠️ | ❌ | ⚠️ | ✅ | ❌ |

Nothing combines the min-balance floor, owed-in-available toggle and per-day maths in one
lightweight app — a niche combination, but a small one to build. Later requirements
(essentials, reimbursed, laundry earmarks, card float, bundled IOU lists) are further from
anything off the shelf, which retrospectively justifies building rather than adopting.

## What was borrowed

1. **PocketGuard** — one hero number plus a per-day figure, with the arithmetic shown.
2. **Splitwise** — owed entries have a lifecycle; settle-up is one tap; history is kept.
3. **Actual Budget** — local-first storage with export/import as a first-class feature.
4. **Daily-budget apps** — entry speed beats features; the add form is the most important screen.

## Sources

- [GitNux: best self-hosted budget software](https://gitnux.org/best/self-hosted-budget-software/)
- [Talos: Firefly III vs Actual Budget](https://talos.tools/compare/firefly-iii-vs-actual-budget)
- [ezBookkeeping feature comparison](https://ezbookkeeping.mayswind.net/comparison/)
- [Slashdot: Actual vs Firefly III](https://slashdot.org/software/comparison/Actual-Budget-vs-Firefly-III/)
- [PocketGuard: how to budget](https://pocketguard.com/how-to-budget-with-pocketguard/) ·
  [Leftover calculation](https://pocketguard.com/help/leftover/)
- [Splitwise](https://www.splitwise.com/) · [guide](https://www.tapsmart.com/tips-and-tricks/splitwise-guide/)
- [Spendaily on daily spending trackers](https://www.spendaily.com/articles/daily-spending-tracker-apps)
- [SaaSHub: Money Manager Ex vs Firefly III](https://www.saashub.com/compare-money-manager-ex-vs-firefly-iii)
