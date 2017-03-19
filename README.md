[![Build Status](https://api.travis-ci.org/vorakl/TrivialRC.png)](https://travis-ci.org/vorakl/TrivialRC)

# TrivialRC

* [Introduction](#introduction)
* [Installation](#installation)
    * [The installation on top of CentOS Linux base image](#the-installation-on-top-of-centos-linux-base-image)
    * [The installation on top of Alpine Linux base image](#the-installation-on-top-of-alpine-linux-base-image)
* [How to get started (examples)?](#how-to-get-started)
* [Command line options](#command-line-options)
* [Run stages](#run-stages)
* [Wait policies](#wait-policies)
* [Verbose levels](#verbose-levels)
* [Integrated functions](#integrated-functions)
* [Useful global variables](#useful-global-variables)

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
with fairly detailed logs of what's is going on inside a container. 
Please, take a look at [examples](https://github.com/vorakl/TrivialRC/tree/master/examples) for more information.

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
As a result, Dockerfile for the [alpine:latest](https://hub.docker.com/_/alpine/) base image would look like:

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

To get started and find out some features, basically, I suggest to go through [all available examples](https://github.com/vorakl/TrivialRC/tree/master/examples) and read their readmes plus comments along the code but to start from [one-liners](https://github.com/vorakl/TrivialRC/blob/master/examples/one-liners/README.md) which show most common use cases and features.

## Command line options

That's important to notice that the order of command line options *is not* equal to their run order.
In general it looks like:

```bash
$ trc [-h|--help] [-v|--version] [-w|--workdir 'dir'] [-B 'cmds' [...]] [-H 'cmds' [...]] [-D 'cmds' [...]] [-F 'cmds' [...]] [command [args]]
```

Where 

* `-h` or `--help`, prints a short help message
* `-v` or `--version`, prints a current version  
* `-w 'directory'` or `--workdir 'directory'`, sets a location with configuration files
* `-B 'command1; command2; ...'`, boot commands
* `-H 'command1; command2; ...'`, halt commands
* `-D 'command1; command2; ...'`, async commands
* `-F 'command1; command2; ...'`, sync commands
* `command [args]`, a sync command

So, command line options have to be supplied in the next order

1. `-B`, zero or more 
2. `-H`, zero or more
3. `-D`, zero or more
4. `-F`, zero or more
5. `command with arguments` (without an option), zero or only one

Examples:

```bash
$ trc -B 'name=$(id -un); echo booting...' -H 'echo halting...' -F 'echo Hello, ${name}!'

$ RC_WAIT_POLICY=wait_all trc -D 'echo Hello' -D 'sleep 2; echo World' echo waiting...

$ RC_VERBOSE=true trc -F 'echo -n "Hello "; echo World'

$ trc --workdir /opt/app
```

## Run stages

The life cycle of TrivialRC consists of different stages, with different isolation.
By default, all configuration files (or trc.d/ directory with them) are searched in the directory from which was executed `trc` itself. For instance, if you've installed trc in /usr/bin/ and run it by using only its name, like `trc`, then configuration will also be searched in /usr/bin/. Though, you can place configuration files anywhere you like and specify their location in the `-w|--workdir` option, like `trc -w /etc/`. 

Let's check:

```bash
$ which trc
/usr/bin/trc

$ trc -B 'echo $dir_name'
/usr/bin

$ trc -w /etc -B 'echo $dir_name'
/etc
```
All stages are executed through in the next order:

1. *boot* <br />
   **Execution order**: trc.boot.* -> trc.d/boot.* -> [-B 'cmds' [...]] <br />
   Commands run in a same environment as the main process and that's why it has to be used with caution.
   It's useful for setting up global variables which are seen in all other isolated environments.
2. *async* <br />
   **Execution order**: trc.async.* -> trc.d/async.* -> [-D 'cmds' [...]] <br />
   Commands run in the separate environment, asynchronously (all run in parallel), in the background and do not affect the main process.
If you are going to run more than one async commands, don't forget that default RC_WAIT_POLICY is set to 'wait_any' and the executing process will be stopped after the first finished command and only if there wasn't any running foreground (sync) command that could block the reaction on the TERM signal. So, there are two options: 
   * to wait until all async commands have finished, you need to set RC_WAIT_POLICY to 'wait_all'.
   * to wait for the first finished command, do not change the default value of RC_WAIT_POLICY but run only async commands.
3. *sync* <br />
   **Execution order**: trc.sync.* -> trc.d/sync.* -> [-F 'cmds' [...]] -> [cmd] <br />
   Commands run in the separate environment, synchronously (one by one), in the foreground and do not affect the main process.
   if you are going to run more than one sync commands, don't forget to change RC_WAIT_POLICY to 'wait_all' or 'wait_err', otherwise, the executing process will be stopped after the first command.
4. *halt* <br />
   **Execution order**: trc.halt.* -> trc.d/halt.* -> [-H 'cmds' [...]] <br />
   Commands run in the separate environment, synchronously (one by one) when the main process is finishing (on exit).
   An exit status from the last halt command has precedence under an exit status from the main process which was supplied as ${_exit_status} variable. So you are able to keep a main exit status (by finishing as `exit ${_exit_status}`) or rewrite it to something else but anyway, if you have at least one halt command, TrivialRC will finish with an exit status of this halt command.

## Wait policies

The rc system reacts differently when one of controlled processes finishes.
Depending on the value of *RC_WAIT_POLICY* environment variable it makes a decision when exactly it should stop itself.
The possible values are:

* *wait_all* <br />
    stops after exiting all commands and it doesn't matter whether they are synchronous or asynchronous. Just keep in mind, if you need to catch a signal in the main process, it doesn't have to be blocked by some foreground (sync) process. For example, this mode can be helpful if you need to troubleshoot a container (with `wait_any` policy) where some async task fails and the whole container gets stopped by this immediately. In this case, you can change a policy to `wait_all` and run BASH in the foreground like `docker -e RC_WAIT_POLICY=wait_all some-container bash`
* *wait_any*  [default] <br />
    stops after exiting any of background commands and if there are no foreground commands working at that moment. It makes sense to use this mode if all commands are **asynchronous** (background). For example, if you need to start more than one process in the docker container, they all have to be asynchronous. Then, the main processed will be able to catch signals (for instance, from a docker daemon) and wait for finishing all other async processes.
* *wait_err* <br />
    stops after the first failed command. It make sense to use this mode with **synchronous** (foreground) commands only. For example, if you need to iterate sequentially over the list of commands and to stop only if one of them has failed.
* *wait_forever* <br />
    there is a special occasion when a process has doubled forked to become a daemon, it's still running but for the parent shell such process is considered as finished. So, in this mode, TrivialRC will keep working even if all processes have finished and it has to be stopped by the signal from its parent process (such as docker daemon for example).

## Verbose levels

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

## Integrated functions

You can also use some of internal functions in async/sync tasks:

* *say* <br />
    prints only if RC_VERBOSE is set
* *log* <br />
    does the same as `say` but add additional info about time, PID, namespace, etc
* *warn* <br />
    does the say as `log` but sends a mesage to stderr
* *err* <br />
    does the same as `warn` but exits with an error (exit status = 1)
* *debug* <br />
    does the same as `log` but only if RC_VERBOSE_EXTRA is set
* *run* <br />
    launches builtin or external commands without checking functions with the same name
    For instance, if you wanna run only external command from the standart PATH list, use `run -p 'command'`
    Or, if you need to check existence of the command, try `run -v 'command'`

## Useful global variables

* `MAINPID`, for sending signals to the main process ([example1](https://github.com/vorakl/TrivialRC/tree/master/examples/reliable-tests-for-docker-images))
* `_exit_status`, for checking or rewriting an exit status of the whole script ([example1](https://github.com/vorakl/TrivialRC/blob/master/examples/process-manager/trc.d/halt.remove-logs), [example2](https://github.com/vorakl/TrivialRC/blob/master/examples/docker-service-discovery/trc.d/halt.sd-unreg))


##### Version: v1.1.9
##### Copyright (c) 2016, 2017 by Oleksii Tsvietnov, me@vorakl.name
