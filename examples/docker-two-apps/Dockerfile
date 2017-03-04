FROM alpine:edge
MAINTAINER "Oleksii Tsvietnov" <me@vorakl.name>

RUN apk add --no-cache bash nginx uwsgi uwsgi-python3 && \
    pip3 install --upgrade pip && \
    pip3 install flask

RUN mkdir /run/uwsgi && \
    chown nginx:nginx /run/uwsgi
COPY app/ /app/

# The required packages for TrivialRC to be run on Alpine Linux
RUN apk add --no-cache bash procps
RUN wget -qP /etc/ http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version
COPY etc/ /etc/

EXPOSE 80

ENTRYPOINT ["/etc/trc"]
