[![Build Status](https://api.travis-ci.org/vorakl/TrivialRC.png)](https://travis-ci.org/vorakl/TrivialRC)

# TrivialRC

The minimalistic Run-time Configuration (RC) system and process manager.
Originaly, it was designed for usage primarily in containers but it can be also very useful 
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
RUN curl -sSLfo /etc/trc http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc
```

- If you need to change a behavior of rc system, set appropriate variables like

```bash
ENV RC_VERBOSE true
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

### How to get started?

The best way to get started is trying simple [one-line examples](https://github.com/vorakl/TrivialRC/blob/master/examples/one-liners/README.md) which follow you from "zero" to almost all available features. 
Many other use cases and examples can be found [here](https://github.com/vorakl/TrivialRC/tree/master/examples).

### Environment variables

* RC_DEBUG (true|false) [false]
    Prints out all commands which are being executed
* RC_VERBOSE (true|false) [false]
    Prints out service information
* RC_VERBOSE_EXTRA (true|false) [false]
    Prints out additional service information
* RC_WAIT_POLICY (wait_all|wait_any|wait_forever) [wait_any]
    - wait_all      quit after exiting the last command (back- or foreground)
    - wait_any      quit after exiting any of command (including zero commands)
    - wait_forever  will be waiting forever after exiting all commands.
                    Usefull in case of daemons which are detaching and exiting
    - wait_err      quits after the first failed command


##### Version: v1.1.4
##### Copyright (c) 2016, 2017 by Oleksii Tsvietnov, me@vorakl.name
