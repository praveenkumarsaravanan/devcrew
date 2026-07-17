#!/usr/bin/env bash
# Configure SSH for GitHub: key generation, known_hosts, and agent loading.
set -euo pipefail

GHE_HOST="${GHE_HOST:-github.com}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519_github}"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ ! -f "$SSH_KEY" ]]; then
  info "Generating SSH key at $SSH_KEY..."
  ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$(whoami)@$GHE_HOST" -N "" -q
  ok "SSH key generated"
else
  ok "SSH key found at $SSH_KEY"
fi

if ! grep -q "^Host $GHE_HOST" "$HOME/.ssh/config" 2>/dev/null; then
  info "Adding $GHE_HOST to ~/.ssh/config..."
  cat >> "$HOME/.ssh/config" <<EOF

Host $GHE_HOST
	HostName $GHE_HOST
	User git
	IdentityFile $SSH_KEY
	AddKeysToAgent yes
	UseKeychain yes
EOF
  ok "SSH config updated"
else
  ok "SSH config already has $GHE_HOST entry"
fi

if ! grep -q "$GHE_HOST" "$HOME/.ssh/known_hosts" 2>/dev/null; then
  info "Adding $GHE_HOST to known_hosts..."
  ssh-keyscan -t ed25519,rsa "$GHE_HOST" >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
  ok "known_hosts updated"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY" 2>/dev/null || true
else
  ssh-add "$SSH_KEY" 2>/dev/null || true
fi

if ssh -T "git@$GHE_HOST" 2>&1 | grep -qi "successfully authenticated"; then
  ok "SSH authentication to $GHE_HOST works"
else
  warn "SSH key not yet registered with $GHE_HOST"
  echo ""
  echo "  Add your public key to GitHub:"
  echo "    1. Copy:  pbcopy < ${SSH_KEY}.pub"
  echo "    2. Open:  https://${GHE_HOST}/settings/ssh/new"
  echo "    3. Paste and save"
  echo ""
  echo "  Or after 'gh auth login', run:"
  echo "    gh ssh-key add ${SSH_KEY}.pub --title \"\$(hostname) Dev Machine\""
  echo ""
fi
