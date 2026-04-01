#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../Sources/Checkpoints/Assets"
BASE_URL="https://raw.githubusercontent.com/horizontalsystems/bitcoin-kit-android/master"

# Mapping: "local_file|android_path"
MAPPINGS=(
  "Bitcoin/MainNet-last.checkpoint|bitcoinkit/src/main/resources/MainNet.checkpoint"
  "BitcoinCash/MainNet-last.checkpoint|bitcoincashkit/src/main/resources/MainNetBitcoinCash.checkpoint"
  "Dash/MainNet-last.checkpoint|dashkit/src/main/resources/MainNetDash.checkpoint"
  "Litecoin/MainNet-last.checkpoint|litecoinkit/src/main/resources/MainNetLitecoin.checkpoint"
  "ECash/MainNet-last.checkpoint|ecashkit/src/main/resources/MainNetECash.checkpoint"
)

updated=0
skipped=0
failed=0

for mapping in "${MAPPINGS[@]}"; do
  local_file="${mapping%%|*}"
  android_path="${mapping##*|}"
  dest="$ASSETS_DIR/$local_file"
  url="$BASE_URL/$android_path"

  http_code=$(curl -s -o "$dest" -w "%{http_code}" "$url")
  if [ "$http_code" = "200" ]; then
    echo "Updated: $local_file"
    ((updated++))
  elif [ "$http_code" = "404" ]; then
    echo "Skipped (not found in Android repo): $local_file"
    ((skipped++))
  else
    echo "Failed (HTTP $http_code): $local_file"
    ((failed++))
  fi
done

echo ""
echo "Done. Updated: $updated, Skipped: $skipped, Failed: $failed"
