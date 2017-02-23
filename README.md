# TrivialRC

The minimalistic is a Run-time Configuration (RC) system and process manager.
Originaly, it was designed for usage primarily in containers but it can be alse very useful 
for running a group of processes asynchronously/synchronously, managing their running order and exit codes.

TrivialRC is not a replacement for an init process that usually exists as /sbin/init
and has a PID 1. In containers for this purpose could be used projects like
[dumb-init](https://github.com/Yelp/dumb-init) or [tini](https://github.com/krallin/tini).

This is an equivalent to a common, for xBSD, /etc/rc. RC system that is used for
managing startup and shutdown processes. It can start and stop one or more processes,
in parallel or sequentially, on back- or foreground. All commands can be specified
in the command line if they are simple, or in a separate file, if a more comprehensive
scenario is needed.

For instance, in Docker images, TrivialRC can be used as an Entrypoint. By default, it does not show itself,
does not affect any configuration and behaves transparently. So, you can add it into
any Dockerfiles which do not have an entrypoint. Please, have a look at examples for more information.

Although, in case of usege in Docker containers, to be sure that all processes will be stopped on exit 
and all zombies are properly reaped, at least for now, it is highly recommended, in addition, to use some 
init process like one of mentioned above.


### Installation

This is an example of the installation in a Docker image.
Basically, you need the only one file (trc) which can be downloaded directly from GitHub and
added into a Dockerfile as something like

```bash
RUN curl -sSLo /etc/trc https://raw.githubusercontent.com/vorakl/TrivialRC/master/trc && \
    chmod +x /etc/trc
```

- If you are going to use it in pair with an init, for example dumb-init

```bash
RUN curl -sSLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64 && \
    chmod +x /sbin/dumb-init
```

- If you need to change a behavior of rc system, set appropriate variables like

```bash
ENV RC_VERBOSE true
ENV RC_VERBOSE_EXTRA true
ENV RC_WAIT_POLICY wait_all
```

- If you have additional files, add them all at once

```bash
COPY trc* /etc/
```

- Eventually, if you do not use init process, specify only trc as an Entrypoint

```bash
ENTRYPOINT ["/etc/trc"]
```

Otherwise, which is RECOMMENDED, add an init process and rc system together, for example as

```bash
ENTRYPOINT ["/sbin/dumb-init", "/etc/trc"]
```

### Examples

All examples can be found [here](https://github.com/vorakl/TrivialRC/tree/master/examples)


##### Version: 1.1.0
##### Copyright (c) 2016, 2017 by Oleksii Tsvietnov, me@vorakl.name
