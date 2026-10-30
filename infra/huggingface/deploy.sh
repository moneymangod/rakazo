#!/usr/bin/env bash
# Pushes this checkout to a Hugging Face Space with the Space Dockerfile and README at the root.
# Usage: deploy.sh <user>/<space>   (run `hf auth login` first)
set -euo pipefail
space="${1:?usage: deploy.sh <user>/<space>}"
root="$(git rev-parse --show-toplevel)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
git -C "$root" archive HEAD | tar -x -C "$work"
cp "$root/infra/huggingface/Dockerfile" "$work/Dockerfile"
cp "$root/infra/huggingface/README.md" "$work/README.md"
hf upload "$space" "$work" . --repo-type space --commit-message "Deploy Rakazo"
