#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${WRANGLER_CONFIG:-wrangler.toml}"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

CONFIG_DIR="$(cd "$(dirname "$CONFIG_FILE")" && pwd)"
TEMP_CONFIG="$(mktemp "$CONFIG_DIR/.wrangler.XXXXXX.toml")"
trap 'rm -f "$TEMP_CONFIG"' EXIT

cp "$CONFIG_FILE" "$TEMP_CONFIG"

mapfile -t PLACEHOLDERS < <(
  grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$TEMP_CONFIG" \
    | sed -E 's/^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$/\1/' \
    | sort -u
)

MISSING_VARS=()
for key in "${PLACEHOLDERS[@]}"; do
  value="${!key:-}"
  if [ -z "$value" ]; then
    upper_key="$(printf '%s' "$key" | tr '[:lower:]' '[:upper:]')"
    value="${!upper_key:-}"
  fi
  if [ -z "$value" ]; then
    MISSING_VARS+=("$key")
    continue
  fi
  sed -i "s|\${$key}|$value|g" "$TEMP_CONFIG"
done

if [ "${#MISSING_VARS[@]}" -gt 0 ]; then
  echo "❌ Missing required environment variables: ${MISSING_VARS[*]}"
  exit 1
fi

if grep -qE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$TEMP_CONFIG"; then
  echo "❌ Failed to resolve all placeholders in generated config."
  exit 1
fi

echo "🚀 Deploying with rendered config: $CONFIG_FILE"
npx wrangler deploy --config "$TEMP_CONFIG" "$@"
