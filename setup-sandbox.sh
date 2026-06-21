#!/usr/bin/env bash
# setup-sandbox.sh — provision a Debian dev sandbox for:
#   web (Vite/React) · Go CLIs/TUIs · Tailscale · git · Claude Code + Codex + roborev
#   ...reachable from Zed on your Mac over the tailnet (SSH remote development).
#
# Target: a fresh Debian 13 (trixie) VM.   Usage:  bash setup-sandbox.sh
# Idempotent: each step is guarded, so a second run skips what's already installed and
# is near-instant. Go is the one exception — it re-checks and upgrades only when go.dev
# has a newer release; everything else is skip-if-present.
set -euo pipefail

NODE_MAJOR="22"   # NodeSource LTS line; bump if a newer LTS is out
have() { command -v "$1" >/dev/null 2>&1; }   # "is this on PATH?"

# Create our install dir and make all guard checks below resolvable this session:
mkdir -p "$HOME/.local/bin"
export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

echo ">> base packages + CLI niceties + SSH server (for Zed/your Mac)"
pkgs=(build-essential git curl wget ca-certificates gnupg unzip
      openssh-server ripgrep fd-find fzf jq tmux direnv)
missing=()
for p in "${pkgs[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
if ((${#missing[@]})); then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends "${missing[@]}"
else
  echo "   ✓ apt packages present"
fi
sudo systemctl enable --now ssh 2>/dev/null || true   # idempotent; lets your Mac SSH in
# Debian packages fd as 'fdfind' — expose it as 'fd':
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true

echo ">> Node $NODE_MAJOR + pnpm (Vite/React; also needed by Codex & Claude MCP)"
if have node && node -v | grep -q "^v${NODE_MAJOR}\."; then
  echo "   ✓ Node $(node -v) present"
else
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash -
  sudo apt-get install -y nodejs
fi
have pnpm || sudo npm install -g pnpm

echo ">> Go (latest) + dev tooling (CLIs/TUIs, Neovim LSP)"
GO_WANT="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1 | sed 's/^go//')"
if [ -x /usr/local/go/bin/go ]; then
  GO_HAVE="$(/usr/local/go/bin/go version | awk '{print $3}' | sed 's/^go//')"
else
  GO_HAVE=""
fi
if [ "$GO_HAVE" = "$GO_WANT" ]; then
  echo "   ✓ Go $GO_HAVE present (latest)"
else
  echo "   installing Go $GO_WANT (had: ${GO_HAVE:-none})"
  curl -fsSL "https://go.dev/dl/go${GO_WANT}.linux-amd64.tar.gz" -o /tmp/go.tgz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz
fi
# Dev tools are installed once; to update later, re-run the matching 'go install ...@latest'.
have gopls         || go install golang.org/x/tools/gopls@latest                 # LSP / go-to-def
have dlv           || go install github.com/go-delve/delve/cmd/dlv@latest         # debugger
have golangci-lint || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

echo ">> Neovim (latest stable)"
if have nvim; then
  echo "   ✓ Neovim present"
else
  curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tgz
  sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf /tmp/nvim.tgz && rm /tmp/nvim.tgz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
fi

echo ">> GitHub CLI (gh)"
if have gh; then
  echo "   ✓ gh present"
else
  sudo apt-get install -y gh 2>/dev/null || {
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update && sudo apt-get install -y gh
  }
fi

echo ">> Tailscale"
have tailscale || curl -fsSL https://tailscale.com/install.sh | sh
# Authenticate — interactive:  sudo tailscale up
#               headless VM:    sudo tailscale up --authkey tskey-...
# Optional: let Tailscale BE the SSH server (no SSH keys; tailnet identity instead):
#               sudo tailscale up --ssh     (needs a matching 'ssh' rule in your ACL)

echo ">> AI agents (install BEFORE roborev so it can auto-detect them)"
# Guards skip if already installed; to update later use 'claude update' / 'npm i -g'.
have claude || curl -fsSL https://claude.ai/install.sh | bash
# Codex CLI — use the SCOPED package; the unscoped 'codex' on npm is unrelated
have codex  || sudo npm install -g @openai/codex
# alt official installer:  curl -fsSL https://chatgpt.com/codex/install.sh | sh

echo ">> roborev — on-demand review / compact / fix  (NO post-commit hook)"
have roborev || curl -fsSL https://roborev.io/install.sh | bash   # prebuilt, checksum-verified
# alt:  go install github.com/roborev-dev/roborev/cmd/roborev@latest
#
# roborev orchestrates reviews with whichever agent you point it at (it auto-detects
# installed CLIs, then runs ONE agent per review). Pick the agent per run with --agent,
# or set a persistent default. The daemon auto-starts on first use.
#
# Run a review with a specific agent (commits since the branch diverged from upstream):
#   roborev review --branch --agent claude-code    # review with Claude Code
#   roborev review --branch --agent codex          # review with Codex
# One review = one agent, so to get BOTH, run it once per agent — each agent's findings
# land separately in the queue/TUI. Swap --branch for --dirty to review uncommitted work.
#
# ...or set a default agent instead of passing --agent every time
# (precedence: --agent flag > per-repo .roborev.toml > global ~/.roborev/config.toml):
#   roborev config set review_agent claude-code        # default review agent for THIS repo
#   roborev config set default_agent codex --global    # global fallback agent
#   roborev config set default_model <model> --global  # optional: override the LLM
#
# Then work the findings:
#   roborev compact     # re-checks findings vs current code, drops false positives, consolidates
#   roborev tui         # browse findings; press 'y' on one to copy it into an agent session
#   roborev fix <ids>   # apply fixes for the ones you pick  (roborev refine = auto loop)
#
# DO NOT run `roborev init` — that installs the post-commit hook (auto-review every
# commit), the automatic behavior you're skipping.
#
# Optional — keep the daemon alive across reboots with a systemd --user service:
#   ROBOREV_BIN="$(command -v roborev)"
#   mkdir -p ~/.config/systemd/user
#   cat > ~/.config/systemd/user/roborev.service <<UNIT
#   [Unit]
#   Description=roborev daemon
#   After=network.target
#   [Service]
#   ExecStart=${ROBOREV_BIN} daemon run
#   Restart=on-failure
#   [Install]
#   WantedBy=default.target
#   UNIT
#   systemctl --user enable --now roborev

echo ">> persist PATH for new login shells"
# Keep this file SILENT (no echo / banners): Zed's remote server talks over the SSH
# channel itself, and any startup output corrupts the protocol — it hangs at
# 'Starting proxy…'. Same goes for ~/.bashrc if you add prompt frameworks later.
grep -q '/usr/local/go/bin' "$HOME/.profile" 2>/dev/null || cat >> "$HOME/.profile" <<'PROFILE_EOF'
export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"
PROFILE_EOF

echo
echo ">> done. Next steps:"
echo "   - tailscale up (auth)            - sign in: claude  /  codex"
echo "   - export ANTHROPIC_API_KEY / OPENAI_API_KEY  (or use the subscription sign-ins)"
echo "   - from your Mac: 'ssh user@<tailscale-name>' should work, then open it in Zed"
echo "   - review loop:  roborev review --branch  ->  compact  ->  tui  ->  fix"
