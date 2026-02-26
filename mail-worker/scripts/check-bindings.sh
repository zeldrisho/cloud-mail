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

first_value() {
  local key="$1"
  rg -n "^[[:space:]]*$key[[:space:]]*=" "$CONFIG_FILE" \
    | head -n 1 \
    | sed -E "s/^[^=]+=[[:space:]]*\"?([^\"]*)\"?.*$/\\1/"
}

is_placeholder() {
  local value="$1"
  [[ -z "$value" || "$value" =~ ^\$\{ || "$value" =~ ^REPLACE_ || "$value" =~ ^YOUR_ || "$value" =~ ^TODO_ ]]
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
  exit 1
fi

d1_id="$(first_value database_id || true)"
kv_id="$(first_value id || true)"

if is_placeholder "$d1_id"; then
  echo "❌ Invalid D1 binding value in $CONFIG_FILE: database_id=\"$d1_id\""
  echo "Set a real D1 database_id to avoid accidental binding loss."
  exit 1
fi

if is_placeholder "$kv_id"; then
  echo "❌ Invalid KV binding value in $CONFIG_FILE: id=\"$kv_id\""
  echo "Set a real KV namespace id to avoid accidental binding loss."
  exit 1
fi

if has_block "r2_buckets"; then
  bucket_name="$(first_value bucket_name || true)"
  if is_placeholder "$bucket_name"; then
    echo "❌ Invalid R2 binding value in $CONFIG_FILE: bucket_name=\"$bucket_name\""
    echo "Set a real R2 bucket_name or remove [[r2_buckets]] intentionally."
    exit 1
  fi
else
  echo "⚠️  No [[r2_buckets]] block in $CONFIG_FILE (R2 is optional)."
fi

echo "✅ Binding check passed for $CONFIG_FILE"
