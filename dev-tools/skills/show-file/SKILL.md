---
name: show-file
description: "Display a file in a dedicated tmux pane to the right. Markdown files are rendered with glow; all
  others open in nvim read-only. Use whenever surfacing a file reference in your response to the user — not on
  silent exploration reads."
---

# Show File — tmux right-pane viewer

Open a file in a dedicated tmux pane to the right of the current session. The pane is reused across calls
(tracked via `/tmp/.claude-show-pane`), so the user sees one stable viewer, not a pane per file.

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

- First call splits a right pane at 45% width.
- Subsequent calls reuse the same pane — previous content is cleared first.
- If the user closes the pane manually, the next call creates a fresh one.
- Commands are prefixed with a space to stay out of shell history.
