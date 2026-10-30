#!/usr/bin/env bash
# Starts Rakazo on port 7860 in a Codespace. Postgres is external, so a stopped Codespace loses nothing.
set -euo pipefail
cd "$(dirname "$0")/../.."
: "${DATABASE_URL:?Add DATABASE_URL as a Codespaces secret}"
: "${RAKAZO_SECRET:?Add RAKAZO_SECRET as a Codespaces secret}"
derive() { printf %s "$1" | openssl dgst -sha256 -hmac "$RAKAZO_SECRET" -r | cut -d' ' -f1; }
export BETTER_AUTH_SECRET="$(derive auth)" ENCRYPTION_KEY="$(derive encryption)"
export SCREEN_PROXY_SECRET="$(derive screen)" SANDBOX_SUPERVISOR_TOKEN="$(derive supervisor)"
export NODE_ENV=production DATA_DIR="$PWD/data" API_HOST=127.0.0.1 API_URL=http://127.0.0.1:3100
export API_PROXY_TARGET=http://127.0.0.1:3100 RAYON_NUM_THREADS=4
if [ -n "${CODESPACE_NAME:-}" ]; then
  export RAKAZO_HOST="${CODESPACE_NAME}-7860.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
  export BETTER_AUTH_URL="https://$RAKAZO_HOST" WEB_ORIGIN="https://$RAKAZO_HOST"
fi
mkdir -p "$DATA_DIR"
(cd apps/api && DATABASE_URL="${DATABASE_MIGRATION_URL:-$DATABASE_URL}" pnpm db:migrate)
node --enable-source-maps apps/api/dist/index.js & api=$!
node --enable-source-maps apps/worker/dist/index.js & worker=$!
(cd apps/web && exec node_modules/.bin/vite preview --host 0.0.0.0 --port 7860) & web=$!
trap 'kill $api $worker $web 2>/dev/null' EXIT
wait -n $api $worker $web
