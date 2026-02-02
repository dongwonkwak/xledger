#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
  echo "[devcontainer] .env created from .env.example"
fi
