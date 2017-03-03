FROM alpine:edge
MAINTAINER "Oleksii Tsvietnov" <me@vorakl.name>

# Alpine doesn't have BASH but it's needed for the TrivialRC
RUN apk add --no-cache bash

RUN wget -qP /etc/ http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version

COPY trc.d /etc/

ENTRYPOINT ["/etc/trc"]
