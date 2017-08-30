
The minimalistic Run-time Configuration (RC) system and process manager
#######################################################################

:slug: info
:summary: The minimalistic Run-time Configuration system and process manager

|build-status|

* Introduction_
* `Getting deeper`_
* Installation_
    * `The installation in Docker on top of CentOS Linux base image`_
    * `The installation in Docker on top of Alpine Linux base image`_
* `How to get started?`_
* `Command line options`_
* `Run stages`_
* `Wait policies`_
* `Verbose levels`_
* `Integrated functions`_
* `Useful global variables`_


Introduction
============

The minimalistic Run-time Configuration (RC) system and process manager is
written in pure Bash and uses just a few external tools like ``ls`` or ``ps``.
Minimally, installation of TrivialRC consists of the only one file which can be
downloaded directly from Github. Originaly, it was designed for use in
containers but it also can be easily used independently of containers for
running a group of processes asynchronously and synchronously, as well as
managing their running order and exit codes.

In the container's world, TrivialRC is not a replacement for an init process
that usually resides in ``/sbin/init`` and has a PID 1. For this purpose there
are few projects like dumb-init_ or tini_. Although, in most cases, having only
TrivialRC as a first/main process (PID 1) in a container is quite enough.
In terms of Docker, the best place for it is the ENTRYPOINT.

TrivialRC somehow reminds a well known ``/etc/rc`` for xBSD users. It can
start and stop one or more processes, in parallel or sequentially, react
differently in case of process failures, etc. All commands can be specified in
the command line if they are relatively simple, or in separate files if a more
comprehensive scenario is needed. That's why it can be used as the simplest tool
for managing a group of process and be a lightweight replacement for solutions
like Supervisor_.


Getting deeper
==============

Regardless of a chosen running mode, at a startup, TrivialRC runs in
the ``boot`` stage which can be used for run-time configuration by running
a number of commands/scripts in the same shell environment. For example, it's
a right place for setting global variables, creating configuration files from
templates, etc.

Besides doing this, in Docker containers, TrivialRC is basically used to get
one of the patterns:

* ``one process per container`` (the default one), when the only one process 
  is running inside a container and has a PID 1. In this mode, the process gets
  signals directly from a Docker daemon. This mode is activated when only
  ``bare`` command with arguments were specified in the command line.
* ``one service per container``, when a logically linked group of process are
  running inside a container. In this case, TrivialRC runs with a PID 1,
  controls a processess' invocation order, their running states and reacts
  properly on incoming signals. This is when it works as a ``process manager``
  and this mode is activated when processes were specified as ``sync``, 
  ``async`` or ``halt``.

In other words, if you run the only one command (plus arguments) in the command
line, then TrivialRC is fully compatible with the main ideology of Docker
because it ``exec``'utes one process per container. But, if you need to run
sequentially a few isolated (in a sub-shell) processes and control their exit
statuses or even run more than one process at the same time inside a container,
then TrivailRC needs to get a PID 1 and act as a process manager for them.

For instance, in docker containers, when TrivialRC is used as an entrypoint, it
doesn't reveal itself by default, does not affect any configurations and behaves
absolutely transparently. This happens because a ``bare command``, which is run
by a ``CMD`` instruction without using any special running stages of TrivialRC 
is actually being ``exec``'uted in the same shell environment. As a result,
a ``bare command`` appears with PID 1. So, you can add it into any Dockerfiles
which haven't had an entrypoint yet and later turn on detailed logs of
a startup process, add some extra actions in a specific order before running
a main container's command or even run a few different processes at the same
time inside the same container. For more information, please take a look
at the examples__.

__ https://github.com/vorakl/TrivialRC/tree/master/examples


Installation
============

Basically, all you need to install TrivialRC is download the latest release of
the script from ``http://trivialrc.vorakl.name/files/trc`` (or stick to any
available releases in ``https://github.com/vorakl/TrivialRC/releases``) and give
it an execute permission. By default, it looks for configuration files in the
same directory from which it was invoked but this behavior can be changed by
setting a work directory (``-w|--workdir`` parameter). So, if you are going to
use configuration files and keep them in ``/etc/``, then you would probably want
to install the script to /etc/ as well and simply run it without specifying
any parameters.

Another option in this case could be to install the script in a more appropriate
place but don't forget to specify ``--workdir /etc`` parameter every time when
you invoke this rc system. Both options are possible and it depends more on
a particular use case. For instance, in case of using in a docker container,
I personaly prefer to have all configuration in separate files in ``trc.d/``
sub-directory and copy it together with the script in ``/etc/``. 


The installation in Docker on top of CentOS Linux base image
------------------------------------------------------------

This is an example of how it would look in a Dockerfile with `centos:latest`_
as base image:

.. code-block:: bash

    FROM centos:latest

    RUN curl -sSLfo /etc/trc http://trivialrc.vorakl.name/trc && \
        ( cd /etc && curl -sSLf http://trivialrc.vorakl.name/trc.sha256 |\
          sha256sum -c ) && \
        chmod +x /etc/trc && \
        /etc/trc --version

    # Uncomment this if you have configuration files in trc.d/
    # COPY trc.d/ /etc/trc.d/

    ENTRYPOINT ["/etc/trc"]


The installation in Docker on top of Alpine Linux base image
------------------------------------------------------------

**Attention**! The Alpine Linux comes with Busybox but its functionality as
a shell and as a few emulated tools ``is not enough`` for TrivialRC. To work in
this distribution it requires two extra packages: ``bash`` and ``procps``.
As a result, Dockerfile for the `alpine:latest`_ base image would look like:

.. code-block:: bash

    FROM alpine:latest

    RUN apk add --no-cache bash procps

    RUN wget -qP /etc/ http://trivialrc.vorakl.name/trc && \
        ( cd /etc && wget -qO - http://trivialrc.vorakl.name/trc.sha256 |\
          sha256sum -c ) && \
        chmod +x /etc/trc && \
        /etc/trc --version

    # Uncomment this if you have configuration files in trc.d/
    # COPY trc.d/ /etc/trc.d/

    ENTRYPOINT ["/etc/trc"]


How to get started?
===================

To get started and find out some features, basically, I suggest to go through
`all available examples`_ and read their readmes plus comments along the code
and start from `one-liners`_ which show most common use cases and features.


Command line options
====================

It is important to notice that the order of command line options **is not**
equal to their run order.
In general it looks like:

.. code-block:: bash

    $ trc [-h|--help] [-v|--version] [-w|--workdir 'dir'] \
          [-B 'cmds' [...]] \
          [-H 'cmds' [...]] \
          [-D 'cmds' [...]] \
          [-F 'cmds' [...]] \
          [bare_command [args]]

Where 

* ``-h`` or ``--help``, prints a short help message
* ``-v`` or ``--version``, prints a current version  
* ``-w 'directory'`` or ``--workdir 'directory'``, sets a path to configuration
* ``-B 'command1; command2; ...'``, ``[B]oot`` commands
* ``-H 'command1; command2; ...'``, ``[H]alt`` commands
* ``-D 'command1; command2; ...'``, ``async`` ([D]etouched) commands
* ``-F 'command1; command2; ...'``, ``sync`` ([F]oreground) commands
* ``bare-command [args]``, a ``bare`` command with arguments, 
  without quotation marks

So, command line options have to be supplied in the next order

1. ``-B``, zero or more which run in the same shell
2. ``-H``, zero or more which run in a sub-shell
3. ``-D``, zero or more which run in a sub-shell
4. ``-F``, zero or more which run in a sub-shell
5. ``bare command with arguments`` (without an option), zero or only one, takes
   the whole execution control from the main process

Examples:

.. code-block:: bash

    $ trc -B 'name=$(id -un); echo booting...' \
          -H 'echo halting...' \
          -F 'echo Hello, ${name}!'

    $ RC_VERBOSE=true \
      trc -F 'echo -n "Hello "; echo World'

    $ trc --workdir /opt/app


Run stages
==========

The life cycle of TrivialRC consists of different stages, with a different
isolation. By default, all configuration files (or trc.d/ directory with them)
are searched in the directory from which a script was executed. For instance,
if you've installed trc in /usr/bin/ and run it by using only its name, like
``trc``, then configuration will also be searched in /usr/bin/. Though, you can
place configuration files anywhere you like and specify their location in the
``-w|--workdir`` option, like ``trc -w /etc/``. 

Let's check:

.. code-block:: bash

    $ which trc
    /usr/bin/trc

    $ trc -B 'echo $work_dir'
    /usr/bin

    $ trc -w /etc -B 'echo $work_dir'
    /etc


All stages are executed in the next order:

1. ``boot``
       **Execution order**: trc.boot.* -> trc.d/boot.* -> [-B 'cmds' [...]]

       This stage runs always without any isolation.
       Commands run in the same shell environment as the main process and
       that's why it has to be used with caution. It's useful for setting up
       global variables which are seen in all other isolated environments.
2. ``async``
       **Execution order**: trc.async.* -> trc.d/async.* -> [-D 'cmds' [...]]

       This stage is a part of a ``process manager`` and it's always isolated.
       Commands run in a sub-shell, asynchronously (all run in parallel),
       in the background and do not affect the main process.
       If you are going to run more than one async commands, don't forget that
       default RC_WAIT_POLICY is set to 'wait_any' and the executing process
       will be terminated after the first finished command and only if there
       wasn't any running foreground (``sync``) commands that could block
       the reaction on the TERM signal. So, there are two options: 

       * wait until all ``async`` commands have finished, you need to set
         RC_WAIT_POLICY to 'wait_all'.
       * wait for the first finished command, do not change the default value of
         RC_WAIT_POLICY but run only ``async`` commands.
3. ``sync``
       **Execution order**: trc.sync.* -> trc.d/sync.* -> [-F 'cmds' [...]]

       This stage is a part of a ``process manager`` and it's always isolated.
       Commands run in a sub-shell, synchronously (one by one), in the
       foreground and do not affect the main process. If you are going to run
       more than one ``sync`` command, don't forget to change RC_WAIT_POLICY to
       'wait_all' or 'wait_err', otherwise, the executing process will be
       terminated after the first finished command.
4. ``halt``
       **Execution order**: trc.halt.* -> trc.d/halt.* -> [-H 'cmds' [...]]

       This stage is a part of a ``process manager``, it's always isolated.
       Commands run in a sub-shell, synchronously (one by one) when the main
       process is terminating. This can happen only in two ocasions:

       * there **isn't** provided a ``bare`` command which always takes over an
         execution control from the main process
       * the process manager terminates by following one of the WAIT_POLICY
         instructions after some ``sync`` or ``async`` command has finished.
       
       An exit status from the last ``halt`` command has precedence under an
       exit status from the main process which was supplied as the
       ${exit_status} variable. So you are able to keep a main exit status
       (by finishing as **exit ${exit_status}**) or rewrite it to something
       else but anyway, if you have at least one ``halt`` command, TrivialRC
       will finish with an exit status of this ``halt`` command.

       It's important to notice that the ``halt`` stage will not be executed if
       there is a ``bare`` command or a process manager wasn't terminated by a
       ``sync`` or ``async`` command.
5. ``bare`` command
       This is a rarely used stage. A command can be supplied only in
       the command line which is always being executed by ``exec`` call and
       leads to the replacement of the main shell process. This stage is needed
       for the ability to run a command as a PID 1 in the Docker container after
       a zero or more ``boot`` commands which can be useful for preconfiguring
       a container. But there is not too much sense to run a ``bare`` command
       with ``sync``, ``async`` and ``halt`` commands at the same time


Wait policies
=============

The rc system reacts differently when one of controlled processes finishes.
Depending on the value of **RC_WAIT_POLICY** environment variable it makes
a decision when exactly it should stop itself. The possible values are:

* ``wait_all``
        stops after exiting all commands and it doesn't matter whether they are
        ``sync`` or ``async``. Just keep in mind, if you need to catch a signal
        in the main process, it doesn't have to be blocked by some foreground 
        (``sync``) process. For example, this mode can be helpful if you need
        to troubleshoot a container (with `wait_any` policy) where some
        ``async`` task fails and the whole container gets stopped by this
        immediately. In this case, you can change the policy to `wait_all` and
        run BASH in the foreground like 
        ``docker -e RC_WAIT_POLICY=wait_all some-container bash``
* ``wait_any``  [default]
        stops after exiting any of background (``async``) commands and if there
        are no foreground (``sync``) commands working at that moment. It makes
        sense to use this mode if all commands are **asynchronous**.
        For example, if you need to start more than one process in a docker
        container, they all have to be ``async``. Then, the main processed
        will be able to catch signals (for instance, from a docker daemon) and
        wait for finishing all other ``async`` processes.
* ``wait_err``
        stops after the first failed command. It make sense to use this mode
        with **synchronous** commands only. For example, if you need 
        to iterate sequentially over the list of commands and to stop only if
        one of them has failed.
* ``wait_forever``
        there is a special occasion when a process has doubled forked to become
        a daemon, it's still running but for the parent shell such process is
        considered as finished. So, in this mode, TrivialRC will keep working
        even if all processes have finished and it has to be stopped by
        the signal from its parent process (such as docker daemon for example).


Verbose levels
==============

By default, TrivailRC doesn't print any service messages at all.
It only sends ``stdout`` and ``stderr`` of all isolated sub-shells to the same
terminal. If another behavior is needed, you can redirect any of them inside
each sub-shell separately. To increase the verbosity of rc system there are
provided a few environment variables:

* ``RC_DEBUG`` (true|false) [false]
        Prints out all commands which are being executed
* ``RC_VERBOSE`` (true|false) [false]
        Prints out service information
* ``RC_VERBOSE_EXTRA`` (true|false) [false]
        Prints out additional service information


Integrated functions
====================

You can also use some of internal functions in async/sync tasks:

* ``say``
        prints only if RC_VERBOSE is set
* ``log``
        does the same as ``say`` but add additional info about time, PID, etc
* ``warn``
        does the say as ``log`` but sends a mesage to stderr
* ``err``
        does the same as ``warn`` but exits with an error (exit status = 1)
* ``debug``
        does the same as ``log`` but only if RC_VERBOSE_EXTRA is set
* ``run``
        launches builtin or external commands without checking functions with
        the same name. For instance, if you wanna run only external command from
        the standart PATH list, use ``run -p 'command'``. Or, if you need
        to check an existence of a command, try ``run -v 'command'``


Useful global variables
=======================

* ``MAIN_PID``, for sending signals to the main process
  (see `Testing of Docker images`_)
* ``exit_status``, for checking or rewriting an exit status of the whole script
  (see `Process Manager`_, `Service Discovery`_)

.. Links

.. |build-status| image:: https://travis-ci.org/vorakl/TrivialRC.svg?branch=master
   :target: https://travis-ci.org/vorakl/TrivialRC
   :alt: Travis CI: continuous integration status
.. _dumb-init: https://github.com/Yelp/dumb-init
.. _tini: https://github.com/krallin/tini
.. _Supervisor: https://github.com/Supervisor/supervisor
.. _`centos:latest`: https://hub.docker.com/_/centos/
.. _`alpine:latest`: https://hub.docker.com/_/alpine/
.. _`all available examples`: https://github.com/vorakl/TrivialRC/tree/master/examples
.. _`one-liners`: https://github.com/vorakl/TrivialRC/blob/master/examples/one-liners
.. _`Testing of Docker images`: https://github.com/vorakl/TrivialRC/tree/master/examples/reliable-tests-for-docker-images
.. _`Process Manager`: https://github.com/vorakl/TrivialRC/blob/master/examples/process-manager/trc.d/halt.remove-logs
.. _`Service Discovery`: https://github.com/vorakl/TrivialRC/blob/master/examples/docker-service-discovery/trc.d/halt.sd-unreg
