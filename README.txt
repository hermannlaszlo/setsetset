SET – GitHub Pages P2P version

Recommended repository name
---------------------------
setsetset

Then your URLs will be:
  Main page:
    https://YOUR-USERNAME.github.io/setsetset/

  Example table:
    https://YOUR-USERNAME.github.io/setsetset/golden-river-bridge

Files
-----
index.html
404.html
github-pages-config.js
.nojekyll
supabase_p2p_signaling.sql

Why 404.html?
-------------
GitHub Pages has no Netlify-style rewrite rule. GitHub serves 404.html for an
unknown route such as /setsetset/golden-river-bridge. This package intentionally
uses a copy of the app as 404.html, so the browser keeps the Jitsi-style table URL
and the JavaScript opens the requested table.

Setup
-----
1. Create a PUBLIC GitHub repository. Recommended name: setsetset.
2. Upload the files from this ZIP to the repository root.
3. If the repository is not called setsetset, edit github-pages-config.js:
     window.SET_GITHUB_BASE_PATH = '/YOUR-REPOSITORY';
4. GitHub repository -> Settings -> Pages.
5. Under Build and deployment choose:
     Source: Deploy from a branch
     Branch: main
     Folder: /(root)
6. Save and wait for Pages deployment.
7. If you have not already done so, run supabase_p2p_signaling.sql once in
   Supabase SQL Editor.

Important
---------
This version is STUN-only WebRTC, with no TURN service. On restrictive corporate,
school or unusual NAT/firewall networks multiplayer may fail to connect. In that
case use another network or mobile internet.

Live gameplay uses WebRTC DataChannel. Supabase is only used for room discovery,
minimal WebRTC signaling, occasional host checkpoints and existing result/retention
functions.
