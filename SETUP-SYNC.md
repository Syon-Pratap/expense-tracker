# Setting up phone sync

One-time setup, about 10 minutes, all in a browser. After this: open a link on any device,
paste the token once on that device, and it stays synced forever.

Nothing here needs the command line, Node, or Python.

> **Already done?** Then you only need Step 4 on any new device.

---

## What you're building

- **The app** — hosted free on GitHub Pages at
  `https://syon-pratap.github.io/expense-tracker/`. Public, but it's only code: no data,
  no password.
- **Your data** — a `data.json` file in a **private** repo. Genuinely private: only you
  can read it.
- **A token** — a GitHub key letting the app read and write that one file. Lives on each
  device, never part of the synced data.

> **Why not a Gist?** A "secret" gist is only unlisted — anyone with the link can read it.
> A private repo is actually private, which is why sync uses one.

---

## Step 1 — Private repo for your data

1. Go to <https://github.com/new>
2. Repository name: **`expense-tracker-data`**
3. Select **Private**
4. Tick **Add a README file** (it must not be empty)
5. **Create repository**

## Step 2 — Public repo for the app

1. <https://github.com/new> again
2. Repository name: **`expense-tracker`**
3. Leave it **Public** (Pages needs this on a free account)
4. Tick **Add a README file** → **Create repository**
5. **Add file → Upload files**, drag in these seven files from this folder:

   ```
   index.html   sw.js   manifest.webmanifest
   icon.svg   icon-192.png   icon-512.png   icon-180.png
   ```

6. **Commit changes**
7. **Settings → Pages** → Source: **Deploy from a branch**, branch **main**, folder
   **/ (root)** → **Save**
8. Wait a minute or two; the app is then live at the URL above.

## Step 3 — The token

1. <https://github.com/settings/personal-access-tokens/new>
2. **Token name:** `expense tracker`
3. **Expiration:** **No expiration**, so you never redo this
4. **Repository access:** *Only select repositories* → **`expense-tracker-data`** only
5. **Permissions → Repository permissions → Contents → Read and write**
   (nothing else — this token can touch that one repo and nothing more)
6. **Generate token** and copy it. It's shown **once**.

## Step 4 — Connect a device

### iPhone — order matters

iOS keeps a Home Screen app and a Safari tab in **completely separate storage**. Set it up
in Safari and the Home Screen icon will still show the setup screen.

1. Open the URL in **Safari**
2. Share button → **Add to Home Screen**
3. Close Safari, open the app from the **Home Screen icon** — only ever use this icon
4. Tap **Connect to my sync**, paste the token, repo `expense-tracker-data`, file
   `data.json` → **Connect**

Using the Home Screen icon also makes iOS treat the storage as an installed app's, so it
isn't cleared the way ordinary Safari data can be.

### Android / laptop

Open the URL → ⚙ → **Set up phone sync** → same three values → **Connect**. On Android,
⋮ → *Install app* for an icon.

### First device only

If the laptop already has data you want to keep, connect **it** first so it pushes
everything up; every other device then pulls it down. Nothing to type twice.

Moving data from the offline copy? Open `Expense Tracker.bat`, ⚙ → **Export backup**, then
on the web version ⚙ → **Import / restore**, **then** connect sync — in that order, or the
fresh setup numbers can override your imported ones.

---

## How syncing behaves

- Runs on open, on refocus, on reconnect, every 25 seconds while open, and a second after
  any change.
- **Works offline** — log with no signal; it uploads when you're back.
- **Both devices' entries survive.** It merges entry by entry rather than overwriting the
  file, so a laptop entry and a phone entry made at the same time both stick.
- **Deletes stick** and don't come back from the other device.
- Editing the *same* entry on both: the most recent edit wins.
- The header shows `synced just now` / `syncing…` / `offline` / `sync failed`.

## If something goes wrong

| Message | What to do |
|---|---|
| *Token rejected* | Revoked or mistyped. Make a new one (Step 3) and reconnect. |
| *Repo or file not found* | Check the repo name, and that the token lists **that repo** under repository access. |
| *GitHub refused the request* | Token is missing **Contents: Read and write**. |
| *sync failed* in the header | Hover for the reason. Your data is safe locally regardless. |
| **Setup screen appeared again** | Storage was cleared, or it's a different browser/container. Tap **Connect to my sync**, paste the token — everything comes back. |

**Lost your phone?** Delete the token at <https://github.com/settings/tokens> — every
device using it is cut off instantly. Make a new one for the devices you still have.

**Never paste the token anywhere except the app's sync dialog.**

## What it costs

Nothing. Public repos, Pages, private repos and the API are all free, and the traffic is
tiny against a limit of 5,000 requests/hour.
