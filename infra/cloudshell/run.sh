#!/usr/bin/env bash
# Runs Rakazo in Google Cloud Shell (free, no card). Needs DATABASE_URL, DATABASE_MIGRATION_URL, RAKAZO_SECRET in the environment.
# After the first run just use: bash ~/rakazo/infra/cloudshell/run.sh
# Open the result with Web Preview -> Preview on port 8080.
set -euo pipefail
# Cloud Shell keeps only $HOME between sessions, so the three values are saved there on first use.
envfile="$HOME/.rakazo.env"
if [ -n "${DATABASE_URL:-}" ] && [ -n "${RAKAZO_SECRET:-}" ]; then
  umask 077
  printf 'export DATABASE_URL=%q DATABASE_MIGRATION_URL=%q RAKAZO_SECRET=%q\n' \
    "$DATABASE_URL" "${DATABASE_MIGRATION_URL:-$DATABASE_URL}" "$RAKAZO_SECRET" > "$envfile"
fi
[ -f "$envfile" ] && . "$envfile"
branch="${RAKAZO_BRANCH:-claude/huggingface-space}"
dir="$HOME/rakazo"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if ! node -v 2>/dev/null | grep -q '^v24'; then
  [ -s "$NVM_DIR/nvm.sh" ] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  . "$NVM_DIR/nvm.sh"
  nvm install 24
fi
command -v pnpm >/dev/null || corepack enable
[ -d "$dir/.git" ] || git clone --depth 1 --branch "$branch" https://github.com/moneymangod/rakazo "$dir"
cd "$dir"
git fetch -q --depth 1 origin "$branch" && git reset -q --hard FETCH_HEAD || true
[ -d apps/api/dist ] || bash infra/codespaces/setup.sh
PORT=8080 exec bash infra/codespaces/start.sh
