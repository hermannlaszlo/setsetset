SET GitHub Pages - card draw / SET streak logic fix

Fixes:
- Expired multiplayer claims are now handled from raw local presence state.
  Previously currentLiveClaim() hid an expired claim before the timer could act.
- This fixes 3-second priority expiry, 3-second selection-start timeout, and
  10-second selection timeout.
- At SET streak end, ALL empty slots are refilled automatically in one atomic
  transition; remaining cards keep their positions.
- A fresh 30-second shared thinking period starts after that refill.
- Multiplayer New card never fills a SET hole. It only adds a true extra card.
- New card is disabled while holes remain. A stale-hole recovery path finalizes
  the streak without adding an extra card.
- Added a guard against duplicate concurrent streak-finalization calls.
- Help updated in HU/EN/DE.

No new Supabase SQL is required.
