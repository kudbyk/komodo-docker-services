FROM alpine:latest

RUN apk add --no-cache openssl bash

WORKDIR /opt/outline/persisted-state

COPY generate.sh /usr/local/bin/generate.sh
RUN chmod +x /usr/local/bin/generate.sh

ENTRYPOINT ["/usr/local/bin/generate.sh"]
