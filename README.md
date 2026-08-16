# Expense Tracker

A personal expense tracker. One HTML file, no server, no account, no adverts, nothing sent
anywhere except your own private GitHub repo when you turn sync on.

Live at **https://syon-pratap.github.io/expense-tracker/**

## Open it

**On the laptop:** double-click `Expense Tracker.bat` for the offline copy in its own clean
window, or just use the link above. Run `Create Desktop Shortcut.bat` once for a Desktop
icon you can pin to the taskbar.

**On your phone:** open the link, then *Add to Home Screen*. See
[SETUP-SYNC.md](SETUP-SYNC.md) for one-time sync setup.

> **iPhone:** add it to the Home Screen **first**, then set up sync from the Home Screen
> icon. iOS keeps Safari and Home Screen apps in separate storage, so anything set up in
> Safari is invisible to the icon.

## The numbers

| Number | Meaning |
|---|---|
| **Current balance** | What you actually have right now |
| **Minimum balance** | Your floor — money you refuse to dip into |
| **Owed to me** | What people owe you; not in your pocket yet |
| **Available** | What's genuinely spendable (full formula below) |
| **Spendable / day** | `available ÷ days left after today` |
| **Spent / day so far** | `spent this month ÷ days elapsed` (today counts) |

```
available = current − minimum + owed − laundry set aside − unpaid card charges
```

The owed toggle sits on the dashboard, on by default. Turning it off drops owed money out
of available and out of the per-day figure.

## The five kinds of spending

Only ordinary expenses feed "spent this month" and "spent/day", so those stay a true
picture of daily canteen spending. Everything else keeps its own total.

| | Where it hits | In ₹/day? |
|---|---|---|
| **Expense** | current ↓, available ↓ | Yes |
| **Essential** | current ↓, available **unchanged** | No |
| **Reimbursed** | current ↓, available **unchanged** | No |
| **Laundry** | current ↓, available **unchanged** | No |
| **Card charge** | **available ↓, current unchanged** | No |

### Essentials and Reimbursed

The same machine, two buckets:

- **Essentials** — things you buy that you expect to get back (medicines, supplies)
- **Reimbursed** — money you fronted for someone else (dinner for the group)

Either way, logging ₹600 takes ₹600 out of your current balance **and** creates an owed
entry for ₹600, so **available doesn't move** — the money is coming back. When you're paid
back, hit **Received** on the Owed tab and current climbs again.

The two entries are **independent once created**: edit or delete either without disturbing
the other. Correcting an amount is therefore two edits if you want both to match.

### Laundry

An amount set aside for the month.

- **Set ₹500 aside** → available ↓ ₹500, current untouched — the money is spoken for
- **Spend ₹120 of it** → current ↓ ₹120, **available unchanged** (already held back)
- **Go over** → only the excess comes out of available

The amount **carries forward**: set ₹500 in August and September starts at ₹500 until you
change it. Spending resets each month, so the full amount is held again.

### Card

What you put on the card, and what it was for. The money is committed but hasn't left your
account:

- **New charge ₹1,200** → available ↓ ₹1,200, **current untouched**
- **Mark it paid** → current ↓ ₹1,200, **available unchanged** — already accounted for

**Paid** clears one charge; **Pay whole bill** clears everything outstanding; **Undo paid**
reverses it. Deleting an *unpaid* charge returns the available; deleting a *paid* one
returns the current.

## Owed money

- **Received** — they paid you. The amount moves into current, so **available doesn't
  change**; it was already counted.
- **Part** — they paid some. The entry stays open with the remainder.
- **Write off** — you're not getting it. Nothing is added, so available drops.

Closed entries can be **Reopened**. A fully-paid one has to be reopened by undoing its
payment instead, so the money and the debt stay consistent.

### Bundling into a list

Tick several open entries and hit **Done** for a saved list you can paste into a chat:

```
Rahul — dinner -> ₹260
Aman — books -> ₹800
Mess split -> ₹150
Total -> ₹1,210
```

**Copy text** puts it on the clipboard. **Received all** collects the lot in one go — the
total into current, every entry settled, available unmoved. **Remove list** deletes just
the grouping and leaves the entries alone.

**Amounts are frozen when the list is saved**, so what you sent is what gets collected. If
something has since been settled, edited or deleted, you get a warning naming it before it
goes through — otherwise it would be possible to collect from someone twice.

## Editing anything

Every entry has an **Edit** button opening the same dialog it was created with.

| Entry | Where |
|---|---|
| Expense | Expenses tab → Edit |
| Essential / reimbursed / laundry / card | Its own tab → Edit |
| Money added / adjustment | Dashboard → Balance history → Edit |
| Payment received | Dashboard → Balance history → Edit, or **Undo payment** |
| Owed entry | Owed tab → Edit |
| Laundry amount | Laundry tab → Change amount |
| Starting balance, minimum balance | Settings ⚙ |

Balances are recalculated from your entry history every time, so editing or deleting
anything — even months ago — can never leave a balance wrong. Editing an entry in an
archived month updates that month's archive too.

## Months look after themselves

On the 1st, the finished month is summarised into the **Archive** and the dashboard starts
fresh. Nothing is deleted. Each archived month keeps its total spent, per-day, money added,
closing balance, the side-section totals, and a ranked breakdown by outlet.

If the app sits unopened for months, all the finished months get archived next time you
open it. Months with no activity are skipped.

## Your data

Saved in **three** places at once: IndexedDB, a localStorage mirror (written first and
synchronously, so even a hard close keeps the last change), and — once sync is on — a
`data.json` in your **private** GitHub repo. Any one of them can rebuild the others; if
they disagree, the newest wins.

Sync runs on open, on refocus, on reconnect, every 25 s while open, and a second after any
change. It **works offline** and merges entry by entry, so entries made on both devices
survive, deletes stick, and the most recent edit wins on the same entry.

Settings ⚙ → **Export backup** any time. Once syncing, the private repo is also a full
version history — every change is a commit you can browse and restore.

## Daily use

Press <kbd>a</kbd> anywhere to log an expense — amount, category, Enter. <kbd>1</kbd>–<kbd>8</kbd>
switch tabs. On a phone the tab strip scrolls sideways.

## Checking it still works

Open [`index.html?test=1`](https://syon-pratap.github.io/expense-tracker/index.html?test=1)
to run the built-in suite — **249 checks** covering balance rules, date maths, month
rollover, archiving, editing, essentials, reimbursed, laundry, the card, owed lists,
multi-device merging and data migration. All should pass.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app |
| `sw.js`, `manifest.webmanifest`, `icon*` | Make it installable on a phone |
| `Expense Tracker.bat` | Opens the offline copy in its own window |
| `Create Desktop Shortcut.bat` | Run once for a Desktop icon |
| `SETUP-SYNC.md` | One-time phone-sync setup |
| `REQUIREMENTS.md` | What it does, and the exact balance rules |
| `RESEARCH.md` | Why this exists instead of Actual Budget / Firefly III / PocketGuard |
| `PLAN.md` | Design decisions and every review finding behind them |

## Small print

Don't keep the app open in two windows of the *same* device (two devices are fine — that's
what sync is for). If you ever see the warning that data isn't saving, hit *Export now*.

Conflicts on the same entry are settled by edit time. Device clocks drift, so the app keeps
its own counter above the newest timestamp it has seen — an edit made after you've seen the
other device's data wins even if that device's clock runs fast.
