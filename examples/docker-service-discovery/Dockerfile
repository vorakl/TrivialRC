FROM centos
MAINTAINER "Oleksii Tsvietnov" <me@vorakl.name>

ENV RC_VERBOSE true
ENV ZKURL 127.0.0.1

RUN curl -sSLfo /etc/trc http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version

RUN curl -sSLfo /usr/bin/zookeepercli https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli && \
    chmod +x /usr/bin/zookeepercli

COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
