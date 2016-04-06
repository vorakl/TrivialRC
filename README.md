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

TrivialRC is designed to be used as an Entrypoint. By default, it does not show itself,
does not affect any configuration and behaves transparently. So, you can add it into
any containers which do not have an entrypoint. Please, have a look at examples for more information.

Anyway, to be sure that all processes will be stopped on exit and all zombies are properly reaped,
at least for now, it is highly recommended to use inside containers some init process like one
of mentioned above.


### Installation

Basically, you need the only one file (trc) that can be downloaded directly from GitHub,
but as long as it likely is going to be used in containers...

- You need to add into your Dockerfile something like

```bash
RUN curl -sSLo /etc/trc https://raw.githubusercontent.com/vorakl/TrivialRC/master/trc && \
    chmod +x /etc/trc
```

If you are going to use it in pair with init, for example dumb-init

```bash
RUN curl -sSLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64 && \
    chmod +x /sbin/dumb-init
```

- If you need to change a behavior of rc system, set appropriate variables like

```bash
ENV RC_VERBOSE true
ENV RC_WAIT_POLICY wait_all
```

- If you have additional files, add them all at once

```bash
COPY trc.* /etc/
```

- Eventually, if you do not use init process, specify only rc system

```bash
ENTRYPOINT ["/etc/trc"]
```

Otherwise, which is RECOMMENDED, add an init process and rc system together, for example

```bash
ENTRYPOINT ["/sbin/dumb-init", "/etc/trc"]
```

### Environment variables

### Еhe boot sequence


##### Version: 1.0.4
##### Copyright (c) by Oleksii Tsvietnov, me@vorakl.name
