FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d

# install build dependencies
RUN apk add --no-cache --update curl jq

COPY create-wallet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-wallet.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT  [ "/entrypoint.sh" ]
