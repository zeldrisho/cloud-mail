#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${WRANGLER_CONFIG:-wrangler.toml}"

WRANGLER_CONFIG="$CONFIG_FILE" bash ./scripts/check-bindings.sh

echo "🚀 Deploying with config: $CONFIG_FILE"
npx wrangler deploy --config "$CONFIG_FILE" "$@"
