# Hugging Face Space image: API, worker and web app in one container on port 7860.
# Postgres is external (DATABASE_URL secret). The Space's repo root must hold this file as `Dockerfile`;
# infra/huggingface/deploy.sh pushes it that way.
FROM node:24.22.1-bookworm
ENV COREPACK_HOME=/usr/local/share/corepack
RUN corepack enable
WORKDIR /app
COPY --chmod=755 . .
RUN corepack install && chmod -R a+rX "${COREPACK_HOME}" \
  && pnpm install --frozen-lockfile \
  && pnpm --filter @rakazo/db generate \
  && pnpm --filter @rakazo/api --filter @rakazo/worker build \
  && RAKAZO_ALLOW_DEV_SECRETS=1 pnpm --filter @rakazo/web build \
  && install -d -m 750 -o node -g node /data /app/apps/web/node_modules/.vite-temp /app/apps/web/asset-archive
ENV NODE_ENV=production \
  DATA_DIR=/data \
  API_HOST=127.0.0.1 \
  API_URL=http://127.0.0.1:3100 \
  API_PROXY_TARGET=http://127.0.0.1:3100 \
  RAYON_NUM_THREADS=4
EXPOSE 7860
USER node
CMD ["bash", "infra/huggingface/start.sh"]
