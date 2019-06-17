FROM centos
MAINTAINER "Oleksii Tsvietnov" <vorakl@protonmail.com>

ENV RC_VERBOSE true
ENV ZKURL 127.0.0.1

RUN curl -sSLfo /etc/trc http://trivialrc.vorakl.name/trc && \
    ( cd /etc && wget -qO - http://trivialrc.vorakl.name/trc.sha256 | sha256sum -c ) && \
    chmod +x /etc/trc && \
    /etc/trc --version

RUN curl -sSLfo /usr/bin/zookeepercli https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli && \
    chmod +x /usr/bin/zookeepercli

COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
