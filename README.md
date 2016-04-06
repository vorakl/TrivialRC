# TrivialRC

The minimalistic startup manager for usage primarily in containers

### Installation

Basically, you need the only one file (trc) that can be downloaded
directly from GitHub, but as long as it likely is going to be used
in Containers, you need to add into your Dockerfile something like

RUN curl -sSLo /etc/trc https://raw.githubusercontent.com/vorakl/TrivialRC/master/trc && \
    chmod +x /etc/trc


##### Version: 1.0.3
##### Copyright (c) by Oleksii Tsvietnov, me@vorakl.name
