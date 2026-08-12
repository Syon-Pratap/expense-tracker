/* Service worker: makes the app open instantly and work with no signal.
   Network-first for the app shell, so a new version is picked up as soon as
   you're online — a cache-first worker would pin you to an old build forever.
   API calls to GitHub are never cached; sync must always see the real file. */
const CACHE = "expense-tracker-v3";
const SHELL = ["./", "./index.html", "./manifest.webmanifest", "./icon.svg",
               "./icon-192.png", "./icon-512.png", "./icon-180.png"];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => Promise.allSettled(SHELL.map(u => c.add(u))))   // a missing icon must not abort install
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;                       // never cache writes
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;        // let GitHub API through untouched

  e.respondWith(
    fetch(req)
      .then(res => {
        if (res && res.ok){
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(()=>{});
        }
        return res;
      })
      .catch(() => caches.match(req).then(hit => hit || caches.match("./index.html")))
  );
});
