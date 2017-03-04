FROM alpine:edge
MAINTAINER "Oleksii Tsvietnov" <me@vorakl.name>

ENV RC_VERBOSE true

RUN apk add --no-cache bash nginx uwsgi uwsgi-python3 && \
    pip3 install --upgrade pip && \
    pip3 install flask

# The required packages for TrivialRC to be run on Alpine Linux
RUN apk add --no-cache bash procps

RUN wget -qP /etc/ http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version

COPY etc/ /etc/
COPY app/ /app/

EXPOSE 80

ENTRYPOINT ["/etc/trc"]
