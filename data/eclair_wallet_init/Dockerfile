FROM alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

# install build dependencies
RUN apk add --no-cache --update curl jq

COPY create-wallet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-wallet.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT  [ "/entrypoint.sh" ]
