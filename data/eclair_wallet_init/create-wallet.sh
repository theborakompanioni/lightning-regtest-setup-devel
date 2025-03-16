#!/bin/sh
set -Eeuo pipefail

WALLET_NAME=${1:-default_wallet}

echo "Creating wallet ${WALLET_NAME}..."
payload="{\
    \"jsonrpc\":\"2.0\",\
    \"id\":\"curl\",\
    \"method\":\"createwallet\",\
    \"params\":{\
        \"wallet_name\":\"${WALLET_NAME}\",\
        \"descriptors\":true,\
        \"load_on_startup\":true\
    }\
}"
curl --silent --user "${_BTC_USER}" --data-binary "${payload}" "${_BTC_URL}" > /dev/null 2>&1

echo "Successfully created ${WALLET_NAME}."
