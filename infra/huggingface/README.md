---
title: Rakazo
sdk: docker
app_port: 7860
---

# Rakazo on a Hugging Face Space

Runs the API, worker and web app in one container. State lives in an external Postgres
(for example a free Neon database), so the Space can sleep or restart without losing anything.

Space secrets: `DATABASE_URL`, `DATABASE_MIGRATION_URL` (owner login, optional),
`BETTER_AUTH_SECRET`, `ENCRYPTION_KEY`, `SCREEN_PROXY_SECRET`, `SANDBOX_SUPERVISOR_TOKEN`
(each 32+ random characters; `ENCRYPTION_KEY` is 64 hex). Keep `ENCRYPTION_KEY` stable.
Bot computers need a remote provider (E2B or Daytona) because a Space has no Docker.

Deploy: `bash infra/huggingface/deploy.sh <user>/<space>`.
