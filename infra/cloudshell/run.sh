#!/usr/bin/env bash
# Runs Rakazo in Google Cloud Shell (free, no card). Needs DATABASE_URL, DATABASE_MIGRATION_URL, RAKAZO_SECRET in the environment.
# Open the result with Web Preview -> Preview on port 8080.
set -euo pipefail
branch="${RAKAZO_BRANCH:-claude/huggingface-space}"
dir="$HOME/rakazo"
if ! node -v 2>/dev/null | grep -q '^v24'; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  . "$NVM_DIR/nvm.sh"
  nvm install 24
fi
[ -d "$dir/.git" ] || git clone --depth 1 --branch "$branch" https://github.com/moneymangod/rakazo "$dir"
cd "$dir"
[ -d apps/api/dist ] || bash infra/codespaces/setup.sh
PORT=8080 exec bash infra/codespaces/start.sh
