SET GitHub Pages – P2P chat, PING/PONG, checkpoints and host migration

New:
- Visible P2P table chat (not persisted).
- PING/PONG every 5 seconds and RTT connection-quality display.
- Host detects stale peers; guests detect a missing host after ~16 seconds.
- Automatic host migration. The winner becomes host in Supabase; all other clients
  perform fresh signaling to the new host.
- Full host checkpoint every 60 seconds, plus existing debounced state checkpoints.

No new Supabase SQL is required if supabase_p2p_signaling.sql was already run.

GitHub Pages repository:
  hermannlaszlo/setsetset
Base path is already /setsetset.
