SET GitHub Pages – host-authoritative multiplayer SET claims

Major multiplayer change:
- SET claim state is no longer stored in Presence.
- Player sends SET_CLAIM_REQUEST to host.
- Host grants exactly one authoritative claim.
- Card selections go to host as SET_SELECT_CARD.
- Host broadcasts SET_CLAIM_STATE to all clients.
- Host validates the 3-card SET, score, penalty, 3-second priority,
  10-second selection timeout and refill.
- Presence is now only presence/role/thinking/last activity.
- Stale Presence snapshots can no longer erase an active SET claim.
- Existing chat, diagnostics, stable P2P status, host migration and
  new-card logic are preserved.

No new Supabase SQL required.
