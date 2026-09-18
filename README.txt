SET GitHub Pages – atomic third-card SET resolution

Fixes the state where multiplayer stopped at:
  "3 cards selected — checking…"

Changes:
- The host no longer broadcasts a transient selecting=3 state before validation.
- On the third card, the host resolves the SET atomically first.
- Correct SET immediately becomes priority state and sends SET_OUTCOME.
- Wrong SET immediately applies the penalty and clears the claim.
- hostResolveSelectedSet is wrapped with diagnostics and exception handling.
- A 1.5 second client watchdog asks the host to resolve/re-send state if completion
  somehow does not arrive.
- Diagnostic log adds SET_THIRD_CARD, SET_RESOLVE_START,
  SET_RESOLVE_EXCEPTION, and SET_RESOLUTION_REQUEST.

No new Supabase SQL required.
