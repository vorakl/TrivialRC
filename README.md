[![Build Status](https://api.travis-ci.org/vorakl/TrivialRC.png)](https://travis-ci.org/vorakl/TrivialRC)

# TrivialRC

The minimalistic Run-time Configuration (RC) system and process manager.
It's written in pure BASH and uses just a few external utilities like ls, ps, date and sleep.
In the minimum intallation TrivialRC consists of only one file which can be downloaded directly from the Github.
Originaly, it was designed for using in containers but it also can be well used for running a group of processes
asynchronously and synchronously, managing their running order and exit codes.

TrivialRC is not a replacement for an init process that usually resides in /sbin/init
and has a PID 1. In containers for this purpose could be used projects like
[dumb-init](https://github.com/Yelp/dumb-init) or [tini](https://github.com/krallin/tini).
Although, in most cases, having only TrivialRC as a first/main process (PID 1) in containers is quite enough.
In terms of Docker, the best place for it is ENTRYPOINT.

TrivialRC is an equivalent to well known /etc/rc for xBSD users. The RC system that is used for
managing startup and shutdown processes. It can start and stop one or more processes,
in parallel or sequentially, on back- or foreground, react differently in case of process failures, etc.
All commands can be specified in the command line if they are relatively simple, or in separate files
if a more comprehensive scenario is needed. That's why it can be used as a simplest tool for managing 
a group of process and be a lightweight replacement for solutions like [Supervisor](https://github.com/Supervisor/supervisor).

For instance, in Docker images when TrivialRC is used as an Entrypoint, it doesn't reveal itself by default,
does not affect any configuration and behaves absolutely transparently. So, you can add it into
any Dockerfiles which do not have an entrypoint yet and get by this the full control under processes 
with fairly detailed logs of what's is going on inside a container. Please, take a look at [examples](https://github.com/vorakl/TrivialRC/tree/master/examples) for more information.


### The installation

Basically, all you need to install TrivialRC is download the latest release of the script from `http://vorakl.github.io/TrivialRC/trc`
and give it an execute permission. By default, it looks for configuration files in the same directory from which it was invoked but this behavior can be changed by setting a work directory (-w|--workdir parametr). So, if you are going to use configuration files and keep them in /etc/, then you would probably want to install the script to /etc/ as well and simply run it without specifying any parametrs.
Another option in this case could be to install the script in a more appropriate path but don't forget to specify '--workid /etc' parametr every time when you invoke this rc system. Both options are possible and depend more on a particular use case.
For instance, in case of using in a Docker container, I personaly prefer to have all configuration in separate files in `trc.d/` sub-directory and copy it together with the script in /etc/ . 

#### The installation on top of CentOS Linux base image

This is an example of how it will look like in a Dockerfile with [centos:latest](https://hub.docker.com/_/centos/) as base image:

```bash
FROM centos:latest

RUN curl -sSLfo /etc/trc http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version

COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
```

#### The installation on top of Alpine Linux base image

**Attention**! The Alpine Linux comes with Busybox but its functionality as a shell and as a few emulated tools *is not enough* for TrivialRC. To work in this distribution it requires two extra packages: `bash` and `procps`.
As a result, Dockerfile for the [alpine:edge](https://hub.docker.com/_/alpine/) base image will look like:

```bash
FROM alpine:edge

RUN apk add --no-cache bash procps

RUN wget -qP /etc/ http://vorakl.github.io/TrivialRC/trc && \
    chmod +x /etc/trc && \
    /etc/trc --version

COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
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


##### Version: v1.1.5
##### Copyright (c) 2016, 2017 by Oleksii Tsvietnov, me@vorakl.name
