#!/usr/bin/env bash
# Runs migrations, then the API, worker and web app. Stops everything if any one exits.
set -euo pipefail
cd /app
: "${DATABASE_URL:?Set DATABASE_URL as a Space secret}"
: "${DATABASE_MIGRATION_URL:=$DATABASE_URL}"
export BETTER_AUTH_URL="${BETTER_AUTH_URL:-https://${SPACE_HOST:-localhost}}"
export RAKAZO_HOST="${RAKAZO_HOST:-${SPACE_HOST:-localhost}}"
export WEB_ORIGIN="${WEB_ORIGIN:-$BETTER_AUTH_URL}"

(cd apps/api && DATABASE_URL="$DATABASE_MIGRATION_URL" pnpm db:migrate)

node --enable-source-maps apps/api/dist/index.js & api=$!
node --enable-source-maps apps/worker/dist/index.js & worker=$!
(cd apps/web && exec node_modules/.bin/vite preview --host 0.0.0.0 --port 7860) & web=$!

trap 'kill $api $worker $web 2>/dev/null' EXIT
wait -n $api $worker $web
