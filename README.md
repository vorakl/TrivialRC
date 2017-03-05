[![Build Status](https://api.travis-ci.org/vorakl/TrivialRC.png)](https://travis-ci.org/vorakl/TrivialRC)

# TrivialRC

* [Introduction](#introduction)
* [Installation](#installation)
    * [The installation on top of CentOS Linux base image](#the-installation-on-top-of-centos-linux-base-image)
    * [The installation on top of Alpine Linux base image](#the-installation-on-top-of-alpine-linux-base-image)
* [How to get started?](#how-to-get-started)
* [The verbosity control](#the-verbosity-control)
* [The wait policy](#the-wait-policy)


## Introduction

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

For instance, in docker images when TrivialRC is used as an Entrypoint, it doesn't reveal itself by default,
does not affect any configuration and behaves absolutely transparently. So, you can add it into
any Dockerfiles which do not have an entrypoint yet and get by this the full control under processes 
with fairly detailed logs of what's is going on inside a container. Please, take a look at [examples](https://github.com/vorakl/TrivialRC/tree/master/examples) for more information.

## Installation

Basically, all you need to install TrivialRC is download the latest release of the script from `http://vorakl.github.io/TrivialRC/trc`
and give it an execute permission. By default, it looks for configuration files in the same directory from which it was invoked but this behavior can be changed by setting a work directory (`-w|--workdir` parametr). So, if you are going to use configuration files and keep them in /etc/, then you would probably want to install the script to /etc/ as well and simply run it without specifying any parametrs.
Another option in this case could be to install the script in a more appropriate path but don't forget to specify `--workdir /etc` parametr every time when you invoke this rc system. Both options are possible and depend more on a particular use case.
For instance, in case of using in a docker container, I personaly prefer to have all configuration in separate files in `trc.d/` sub-directory and copy it together with the script in `/etc/` . 

### The installation on top of CentOS Linux base image

This is an example of how it would look like in a Dockerfile with [centos:latest](https://hub.docker.com/_/centos/) as base image:

```bash
FROM centos:latest

RUN curl -sSLfo /etc/trc http://vorakl.github.io/TrivialRC/trc && \
    ( cd /etc && curl -sSLf http://vorakl.github.io/TrivialRC/trc.sha256 | sha256sum -c ) && \
    chmod +x /etc/trc && \
    /etc/trc --version

# Uncomment this if you have configuration files in trc.d/
#COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
```

### The installation on top of Alpine Linux base image

**Attention**! The Alpine Linux comes with Busybox but its functionality as a shell and as a few emulated tools *is not enough* for TrivialRC. To work in this distribution it requires two extra packages: `bash` and `procps`.
As a result, Dockerfile for the [alpine:edge](https://hub.docker.com/_/alpine/) base image would look like:

```bash
FROM alpine:latest

RUN apk add --no-cache bash procps

RUN wget -qP /etc/ http://vorakl.github.io/TrivialRC/trc && \
    ( cd /etc && wget -qO - http://vorakl.github.io/TrivialRC/trc.sha256 | sha256sum -c ) && \
    chmod +x /etc/trc && \
    /etc/trc --version

# Uncomment this if you have configuration files in trc.d/
#COPY trc.d/ /etc/trc.d/

ENTRYPOINT ["/etc/trc"]
```

## How to get started?

To get started there are provided a few examples:

* [One-liners](https://github.com/vorakl/TrivialRC/blob/master/examples/one-liners/README.md) which show most common use cases and features
* The example of using [configuration files](https://github.com/vorakl/TrivialRC/tree/master/examples/config-files) instead of command line parameters
* A docker container that registers itself in a [Service Discovery](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-service-discovery) in the beginning, then starts some application and automatically removes the registration on exit
* This example launches [two different applications](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-two-apps) inside one docker container and controls the availability both of them. If any of applications has stopped working by some reasons, the whole container will be stopped automatically with the appropriate exit status
* The example of building [docker base images](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-base-images) with TrivialRC as an ENTRYPOINT


## The verbosity control

By default, TrivailRC doesn't print any service messages at all.
It only sends `stdout` and `stderr` of all isolated sub-shells to the same terminal.
If another behavior is needed, you can redirect any of them inside each sub-shell separately.
To increase the verbosity of rc system there are provided a few environment variables:

* *RC_DEBUG* (true|false) [false] <br />
    Prints out all commands which are being executed
* *RC_VERBOSE* (true|false) [false] <br />
    Prints out service information
* *RC_VERBOSE_EXTRA* (true|false) [false] <br />
    Prints out additional service information

## The wait policy

The rc system reacts differently when one of controlled processes finishes.
Depending on the value of *RC_WAIT_POLICY* environment variable it makes a decision when exactly it should stop itself.
The possible values are:

* *wait_all* <br />
    stops after exiting all commands and doesn't matter wether they are synchronous or asynchronous
* *wait_any*  [default] <br />
    stops after exiting any of background commands and if there are no foreground commands working at that moment. It makes sense to use this mode if all commands are asynchronous (background)
* *wait_err* <br />
    stops after the first failed command. It make sense to use this mode with synchronous (foreground) commands only. For example, if you need to iterate synchronously over the list of command and to stop only if one of them has failed.
* *wait_forever* <br />
    there is a special occasion when a process has doubled forked to become a daemon, it's still running but for the parent shell such process is considered as finished. So, in this mode, TrivialRC will keep working even if all processes have finished and it has to be stopped by the signal from its parent process (such a docker daemon for example)


##### Version: v1.1.5
##### Copyright (c) 2016, 2017 by Oleksii Tsvietnov, me@vorakl.name
