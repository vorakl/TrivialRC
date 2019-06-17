FROM haproxy:1.7-alpine

# Install TrivialRC
RUN apk add --no-cache bash procps
RUN wget -qP /etc/ http://trivialrc.cf/trc && \
    ( cd /etc && wget -qO - http://trivialrc.cf/trc.sha256 | sha256sum -c ) && \
    chmod +x /etc/trc && \
    /etc/trc --version
COPY trc.d/ /etc/trc.d/

# Install FakeTpl
RUN wget -qP /usr/bin/ http://faketpl.vorakl.name/faketpl && \
    ( cd /usr/bin && wget -qO - http://faketpl.vorakl.name/faketpl.sha256 | sha256sum -c )

# Add a template. The config file will be made at run-time
COPY haproxy.cfg.ftpl /usr/local/etc/haproxy/

ENTRYPOINT ["/etc/trc"]
