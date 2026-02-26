#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${WRANGLER_CONFIG:-wrangler.toml}"

echo "🚀 Deploying with config: $CONFIG_FILE"
npx wrangler deploy --config "$CONFIG_FILE" "$@"
