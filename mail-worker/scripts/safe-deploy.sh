#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${WRANGLER_CONFIG:-wrangler.toml}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

has_block() {
  local block_name="$1"
  rg -n "^[[:space:]]*\\[\\[$block_name\\]\\]" "$CONFIG_FILE" > /dev/null
}

missing_blocks=()
for block in d1_databases kv_namespaces; do
  if ! has_block "$block"; then
    missing_blocks+=("$block")
  fi
done

if [ ${#missing_blocks[@]} -gt 0 ]; then
  echo "❌ Refusing to deploy with $CONFIG_FILE."
  echo "Missing required binding blocks: ${missing_blocks[*]}"
  echo "This guard prevents Cloudflare deploy from dropping existing bindings."
  echo "Fix wrangler config first, or use: npm run deploy:unsafe"
  exit 1
fi

if ! has_block "r2_buckets"; then
  echo "⚠️  No [[r2_buckets]] block in $CONFIG_FILE (R2 is optional)."
fi

echo "🚀 Deploying with config: $CONFIG_FILE"
npx wrangler deploy --config "$CONFIG_FILE" "$@"
