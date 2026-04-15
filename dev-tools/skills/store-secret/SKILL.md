---
name: store-secret
description: "Store a secret (API key, token, password) in the macOS Keychain and wire it up as an environment variable in .zshrc. Use this skill whenever the user wants to store a secret, API key, or token securely, add a keychain secret, store credentials for a project, or asks how to keep a key out of dotfiles/code. Trigger phrases: 'store this key', 'add to keychain', 'save this secret', 'store API key', 'add secret'."
---

# Store Secret — macOS Keychain

Store secrets in the macOS Keychain so they never appear in dotfiles, shell history, or chat logs. The secret itself must always be entered by the user directly in their terminal — never typed in chat, never passed through a Claude tool call.

## Security Rules (Non-Negotiable)

- **Never ask the user to type the secret in chat.** It would be sent to Anthropic's servers and stored in local conversation logs.
- **Never run a Bash tool call that contains the secret.** Tool calls are logged.
- **Always emit a command for the user to run themselves in their terminal.**
- The `read -s` pattern is preferred — it suppresses echo and clears the variable after use.

## What to Ask the User

Use AskUserQuestion to gather:

1. **Service name** — the Keychain entry name (e.g. `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`). Convention: uppercase, matches the env var name.
2. **Account** — almost always `$USER` (their macOS username). Confirm if there's a reason to use something else.
3. **Wire to shell?** — do they want it auto-exported in `.zshrc` on every new shell? (Usually yes.)

## Step 1 — Store the Secret

Output this block for the user to run in their terminal. Replace `SERVICE_NAME` with the actual name:

```zsh
read -s -p "Paste key (input hidden): " K \
  && security add-generic-password -s "SERVICE_NAME" -a "$USER" -w "$K" -U \
  && unset K \
  && echo "Stored."
```

Explain the flags:
- `read -s` — suppresses echo, key never appears on screen
- `-U` — updates the entry if it already exists (safe to re-run)
- `unset K` — clears the variable from shell memory immediately after storing

## Step 2 — Verify It Was Stored

```zsh
security find-generic-password -s "SERVICE_NAME" -a "$USER" -w
```

This should print the key. If it returns nothing or errors, the store failed.

## Step 3 — Wire to secrets.zsh (if requested)

Secrets are loaded from `~/.config/dotfiles/zsh/secrets.zsh`, which is sourced by `.zshrc`. This file has two parts
to update:

1. **Registry comment** — add a row to the table at the top so other machines/sessions know the secret exists:

```
#   ENV_VAR_NAME         ENV_VAR_NAME           Short description of purpose
```

2. **Export call** — add a `_keychain_export` line inside the `if [[ "$OSTYPE" == darwin* ]]` block, before
   `unfunction _keychain_export`:

```zsh
    _keychain_export SERVICE_NAME
```

The `_keychain_export` helper only sets the env var if the Keychain entry exists — no empty-string exports on
machines where the secret hasn't been created yet.

Then tell the user to reload their shell:
```zsh
source ~/.zshrc
```

## Step 4 — Verify the Env Var

```zsh
echo ${SERVICE_NAME:0:10}...
```

Prints only the first 10 characters — enough to confirm it loaded, not enough to expose it.

## Docker / Devcontainer Note

If the project uses a devcontainer, the env var will be available in the container automatically as long as `docker-compose.yml` passes it through:

```yaml
environment:
  - SERVICE_NAME
```

The var is set on the host shell before `dev up`, so it flows in without ever being hardcoded.
