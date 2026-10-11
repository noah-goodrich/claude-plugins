---
name: show-file
description: "Display a file in a dedicated tmux pane to the right. Markdown files are rendered with glow; all
  others open in nvim read-only. Use whenever surfacing a file reference in your response to the user — not on
  silent exploration reads."
---

# Show File — tmux right-pane viewer

Open a file in a dedicated tmux pane to the right of the current session. The pane is reused across calls
(tracked per calling window, see "Pane behavior"), so the user sees one stable viewer, not a pane per file.

## When to use

Call this **only** when you are surfacing a file in your response — meaning you are showing the user a specific
file they asked about, or a file that is central to your answer. Do NOT call it on:

- Silent reads during exploration or context-gathering
- Files you mention only in passing (e.g. "I also checked `foo.ts` but it wasn't relevant")
- Files the user already has open (they'll tell you)

## How to call

```bash
bash /Users/noah/dev/claude-plugins/dev-tools/skills/show-file/show-file.sh <absolute-path>
```

The script handles pane lifecycle, cleanup of previous content, and format selection:

- `.md` / `.mdx` files are rendered with `glow -p` (paged, scrollable)
- All other files open in `nvim -R` (read-only)

## Pane behavior

- Requires `$TMUX_PANE`. The script resolves the calling session's own window from it and exits 1 with an error if
  it is unset or empty. It never falls back to an implicit tmux target: Claude's Bash tool has no controlling tty,
  so an untargeted tmux command acts on whichever window the user is currently viewing, not the caller's.
- The viewer pane is tracked per calling window, in `${SHOW_FILE_STATE_DIR:-/tmp}/.claude-show-pane.<window id>`.
  Two sessions in two windows each get their own viewer.
- First call from a window splits a right pane at 45% width, in that window.
- Subsequent calls from the same window reuse the pane if it is still alive AND still in that window — previous
  content is cleared first.
- If the user closes the pane manually, or the cached pane is gone or elsewhere, the next call creates a fresh one.
- Commands are prefixed with a space to stay out of shell history.
