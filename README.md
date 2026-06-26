# proxmox

## Install VM

- On proxmox, using latest Debian ISO

## Initial steps

Clone repo:

```
git clone git@github.com:arturcarvalho/proxmox.git
```

## Claude / Codex global config

```bash
# Shared (Codex reads AGENTS.md from ~/)
cp ai-config/AGENTS.md ~/AGENTS.md

# Claude only
cp ai-config/CLAUDE.md ~/.claude/CLAUDE.md
cp ai-config/settings.json ~/.claude/settings.json
cp ai-config/statusline.sh ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
```

## Next steps

- sudo tailscale up (auth)
- sign in: claude / codex
- from your Mac: 'ssh user@<tailscale-name>' should work, then open it in Zed
- review loop: roborev review --branch -> compact -> tui -> fix

## Copy the public key to the server (your ed25519 on the mac)
ssh-copy-id artur@your-server

## Do this to make pbcopy work from the ssh


```bash
cp pbcopy ~/.local/bin/pbcopy
chmod +x ~/.local/bin/pbcopy
```

Then do stuff like `echo "bla" | pbcopy` and it sends to the clipboard on your mac with Ghostty (at least)

## tmux

```bash
if [ -z "$TMUX" ] && [ -n "$SSH_TTY" ]; then
    tmux new-session -A -s main
fi
```
