SET GitHub Pages – SET claim ACK/race fix

Fixes the 'Press SET first' bug when a player taps a card immediately after SET!.

Cause:
- SET claim is host-authoritative.
- The UI previously said 'select cards' before the host grant had returned.
- A fast card tap saw no authoritative claim yet and was rejected.

Fix:
- Every SET claim request now has an explicit host ACK/NACK.
- Client tracks a pending SET claim.
- Card taps made while the host grant is in flight are queued.
- As soon as host grant/broadcast arrives, queued taps are replayed in order.
- If another player owns the claim, host sends an explicit rejection.
- Diagnostics now include SET pending/grant state.

No new Supabase SQL required.
