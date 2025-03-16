#!/bin/sh
set -Eeuo pipefail

export _BTC_USER="${RPC_USER}:${RPC_PASSWORD}"
export _BTC_URL="http://${RPC_HOST}:${RPC_PORT}"

WALLET_NAME0=wallet_eclair_grace7

source /usr/local/bin/create-wallet.sh "${WALLET_NAME0}"
