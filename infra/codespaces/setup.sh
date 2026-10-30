#!/usr/bin/env bash
# One-time build for a Codespace.
set -euo pipefail
corepack enable
pnpm install --frozen-lockfile
pnpm --filter @rakazo/db generate
pnpm --filter @rakazo/api --filter @rakazo/worker build
RAKAZO_ALLOW_DEV_SECRETS=1 pnpm --filter @rakazo/web build
