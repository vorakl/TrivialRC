# TrivialRC

The minimalistic init system and process manager for usage primarily in containers.

From here and further, by a container I mean Docker.

TrivialRC is not a replacement for an init process that usually exists in /sbin/init
and has a PID 1. In containers for this purpose are being used projects like
[dumb-init](https://github.com/Yelp/dumb-init) or [tini](https://github.com/krallin/tini).

This is an equivalent to a common, for xBSD, /etc/rc. Init system that is used for
managing startup and shutdown process. It can start and stop one or more processes,
in parallel or sequentially, on back- or foreground. All commands can be specified
in the command line if they are simple, or in a separate file, if more comprehensive
scenario is needed.

Anyway, to be sure that all processes will be stopped on exit, at least for now,
it is highly recommended to use inside Containers some init process like one of mentioned
above.


### Installation

Basically, you need the only one file (trc) that can be downloaded directly from GitHub,
but as long as it likely is going to be used in Containers, you need to add into your
Dockerfile something like:

```bash
RUN curl -sSLo /etc/trc https://raw.githubusercontent.com/vorakl/TrivialRC/master/trc && \
    chmod +x /etc/trc
```

##### Version: 1.0.3
##### Copyright (c) by Oleksii Tsvietnov, me@vorakl.name
