FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# install build dependencies
RUN apk add --no-cache --update curl jq

COPY create-wallet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-wallet.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT  [ "/entrypoint.sh" ]
