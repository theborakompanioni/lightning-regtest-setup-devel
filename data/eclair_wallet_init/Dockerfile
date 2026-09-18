FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

# install build dependencies
RUN apk add --no-cache --update curl jq

COPY create-wallet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-wallet.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT  [ "/entrypoint.sh" ]
