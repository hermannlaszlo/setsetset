SET GitHub Pages – draggable P2P chat + transient page messages

New:
- Table chat is draggable by its header.
- Uses Pointer Events, so dragging works with mouse, touch and pen.
- Window is clamped to the visible viewport and stays on-screen after rotation/resize.
- Every new chat message also appears below the cards, directly above the SET rule.
- Those inline messages stay for 30 seconds total:
    27 s fully visible + 3 s fade-out.
- Clicking an inline message opens the chat window.
- Maximum 5 inline messages are kept visible at once.
- Help text updated in Hungarian, English and German.

No new Supabase SQL is required.
