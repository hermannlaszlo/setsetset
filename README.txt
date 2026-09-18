SET GitHub Pages – multiplayer SET completion fix

Fixes:
- Never shows "select 0 more cards".
- After the third selection the UI shows "3 cards selected — checking…".
- Host sends explicit SET_OUTCOME to the claiming player.
- Correct SET immediately shows the 3-second priority message.
- Wrong SET and timeout messages are also delivered explicitly.
- Older SET_CLAIM_RESULT ACK can no longer roll back a newer claim state.
- Host and guest use the same user-facing progress logic.

No new Supabase SQL required.
