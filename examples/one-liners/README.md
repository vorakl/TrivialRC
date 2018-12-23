# One Liners

```bash
# The simplest start is to do nothing
$ trc
```
```bash
# But in fact trc does much more than it seems

$ RC_VERBOSE=true RC_VERBOSE_EXTRA=true trc
2017-08-31 18:10:24 trc [main/22776]: The wait policy: wait_any
2017-08-31 18:10:24 trc [main/22776]:  - Looking for 'boot' scripts and commands...
2017-08-31 18:10:24 trc [main/22776]:  - Looking for 'halt' commands...
2017-08-31 18:10:24 trc [main/22776]:  - Looking for 'async' scripts and commands...
2017-08-31 18:10:24 trc [main/22776]:  - Looking for 'sync' scripts and commands...
2017-08-31 18:10:24 trc [main/22776]:  - Looking for a 'bare' command...
2017-08-31 18:10:24 trc [main/22776]:  - exit-trap (exitcode=0)
2017-08-31 18:10:24 trc [main/22776]: Trying to terminate sub-processes...
2017-08-31 18:10:24 trc [main/22776]:  - Removing all unexpected sub-processes
2017-08-31 18:10:24 trc [main/22776]:  - Looking for 'halt' scripts...
2017-08-31 18:10:24 trc [main/22776]: Exited (exitcode=0)
```
```bash
# The most famous test

$ trc echo Hello World
Hello World
```
```bash
# If turn on the logs, it's easy to notice that the command replaces TrivialRC.
# PID of trc and PID of the executed command are the same (3403)
# TrivialRC obviously looses all the control under the process

$ RC_VERBOSE=true trc ls -ld /proc/self
2017-08-31 21:03:53 trc [main/3403]: The wait policy: wait_any
2017-08-31 21:03:53 trc [bare/3403]: handing over the execution to: ls -ld /proc/self
lrwxrwxrwx 1 root root 0 Aug 26 20:31 /proc/self -> 3403
```
```bash
# Let's get back a full control! ;)
# It's going to stop after the first command because a default wait policy
# is 'wait_any'

$ trc -F 'exit 12' -F 'exit 13'

$ echo $?
12
```
```bash
# If a wait policy is set to 'wait_all', it can catch exit codes of all commands
# and exit with a code of the last one

$ { RC_VERBOSE=true RC_WAIT_POLICY=wait_all \
    trc -F 'exit 12' -F 'true' -F 'false' -F 'exit 13'; \
    echo "trc exited with code: $?" >&2; \
  } | sed -n 's/^.*exiting (\(exitcode=.*\)).*$/\1/p'
exitcode=12
exitcode=0
exitcode=1
exitcode=13
trc exited with code: 13
```
```bash
# By setting a wait policy to 'wait_err', it's simple to stop the process
# on the first failed command and catch the exit code

$ { RC_VERBOSE=true RC_WAIT_POLICY=wait_err \
    trc -F 'exit 0' -F 'true' -F 'exit 12' -F 'false'; \
    echo "trc exited with code: $?" >&2; \
  } | sed -n 's/^.*exiting (\(exitcode=.*\)).*$/\1/p'
exitcode=0
exitcode=0
exitcode=12
trc exited with code: 12
```
```bash
# Let's check the difference betwin two ways of running commands
# In the first example, it needs to change the default RC_WAIT_POLICY to run
# all commands

$ RC_WAIT_POLICY=wait_all \
  trc -F 'pstree -sp $BASHPID' \
      -F 'pstree -sp $BASHPID' \
      -F 'pstree -sp $BASHPID'

systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(309)───trc(322)───pstree(325)
systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(309)───trc(328)───pstree(331)
systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(309)───trc(334)───pstree(340)

# All three 'pstree' had different PIDs and all their parrent processes also
# had different PIDS because TrivialRC spawned three different sub-shells for
# each '-F' option. And this is another way

$ trc -F 'pstree -sp $BASHPID; pstree -sp $BASHPID; pstree -sp $BASHPID'

systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(459)───trc(473)───pstree(476)
systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(459)───trc(473)───pstree(477)
systemd(1)───xfce4-terminal(5257)───bash(29798)───trc(459)───trc(473)───pstree(478)

# PIDs of 'pstree' are still different but the parrent process is the same for
# all of them. This happened because there is only one '-F' option and TrivialRC
# spawned the only one sub-shell. That's why 'RC_WAIT_POLICY' wasn't also
# changed, all commands were run in the same sub shell.

```
```bash
# In this example, it's going to run a few jobs in parallel and wait until they
# all have finished. It doesn't matter if some of them fails because TrivialRC
# in the 'wait_all' mode will wait for all jobs and exit with the exit code
# of the last finished process
```

```bash
# It assigns environment variables in the boot-block an then uses them in the foreground-block
./trc -B 'export myhost=$(hostname) user=$(id -un)' \
      -F 'echo -e "Username: $user\nHostname: $myhost"'
Username: vorakl
Hostname: marche
```
```bash
# It catches all exit codes of all background processes and prints them out in a readable way
$ RC_VERBOSE=true \
  RC_WAIT_POLICY=wait_all \
  ./trc -D 'exit 2' \
        -D 'false' \
        -D 'exit 4' \
        -D 'true' | \
  sed -n 's|^.*(exitcode=\([[:digit:]]*\)): \(.*\)$|\2\t : \1|p'
exit 2	 : 2
true	 : 0
false	 : 1
exit 4	 : 4
```
```bash
# It catches an exit code of the first failed command.
# It's `exit 4` because `exit 0` didn't fail and all other commands stil run
# For this example it needs a `wait_err` wait policy
$ RC_WAIT_POLICY=wait_err ./trc -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5

$ echo $?
4

# And now, let's run the same example but with a `wait_all` wait policy. 
# In this case, it will wait for all commands and exit with a status of the last command which is `sleep 2; exit 3`
$ RC_WAIT_POLICY=wait_all ./trc -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5

$ echo $?
3
```

