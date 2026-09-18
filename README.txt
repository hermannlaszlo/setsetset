SET GitHub Pages – robust WebRTC signaling fix

Fixes:
- Waits until the Supabase Realtime signaling channel is actually SUBSCRIBED.
- Replays recent rtc_signals rows so an offer/answer is not lost during a race.
- De-duplicates signaling rows that arrive both by replay and Realtime.
- Keeps guest signaling alive until ICE + DataChannel are stable.
- Releases signaling only after a 7-second stable grace period.
- Shows P2P phase: signaling / offer / answer / ICE / active / retry / failed.
- Automatic WebRTC handshake retry if DataChannel does not open within 12 seconds.
- Automatic retry on ICE / PeerConnection failure or disconnect.
- Fresh signaling after host migration.
- Existing P2P chat, draggable chat window, 30-second inline messages,
  PING/PONG and checkpoints are preserved.

No new Supabase SQL is required if supabase_p2p_signaling.sql was already run.
