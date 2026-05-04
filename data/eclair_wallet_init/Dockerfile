FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

# install build dependencies
RUN apk add --no-cache --update curl jq

COPY create-wallet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-wallet.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT  [ "/entrypoint.sh" ]
