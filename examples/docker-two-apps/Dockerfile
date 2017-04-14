FROM alpine:edge
MAINTAINER "Oleksii Tsvietnov" <me@vorakl.name>

RUN apk add --no-cache nginx uwsgi uwsgi-python3 && \
    pip3 install --upgrade pip && \
    pip3 install flask

RUN mkdir /run/uwsgi && \
    chown nginx:nginx /run/uwsgi
COPY app/ /app/

# The required packages for TrivialRC to be run on Alpine Linux
RUN apk add --no-cache bash procps
RUN wget -qP /etc/ http://trivialrc.vorakl.name/trc && \
    ( cd /etc && wget -qO - http://trivialrc.vorakl.name/trc.sha256 | sha256sum -c ) && \
    chmod +x /etc/trc && \
    /etc/trc --version
COPY etc/ /etc/

EXPOSE 80

ENTRYPOINT ["/etc/trc"]
