# One Liners

```bash
# The simplest start is doing nothing
$ ./trc
```
```bash
# The most famous one
$ ./trc echo Hello World
Hello World
```
```bash
# Turns on logs
$ RC_VERBOSE=true ./trc echo Hello World
2017-02-22 00:19:33 trc [main/12570]: The wait policy: wait_any
2017-02-22 00:19:33 trc [sync/12580]: Launching on the foreground: echo Hello World
Hello World
2017-02-22 00:19:33 trc [sync/12580]: Exiting on the foreground (0): echo Hello World
2017-02-22 00:19:33 trc [sync/12580]:  - terminating the main <12570>
2017-02-22 00:19:33 trc [main/12570]: Going down. Running shutdown scripts...
2017-02-22 00:19:33 trc [main/12570]: Handling of termination...
2017-02-22 00:19:33 trc [main/12570]: Exited.

$ echo $?
0
```
```bash
# Exits with a proper exit code
$ RC_VERBOSE=true ./trc exit 111
2017-02-22 00:20:57 trc [main/12811]: The wait policy: wait_any
2017-02-22 00:20:57 trc [sync/12821]: Launching on the foreground: exit 111
2017-02-22 00:20:57 trc [sync/12821]: Exiting on the foreground (111): exit 111
2017-02-22 00:20:57 trc [sync/12821]:  - terminating the main <12811>
2017-02-22 00:20:57 trc [main/12811]: Going down. Running shutdown scripts...
2017-02-22 00:20:57 trc [main/12811]: Handling of termination...
2017-02-22 00:20:57 trc [main/12811]: Exited.

$ echo $?
111
```
```bash
# Both commands are running on the foreground but it exits after the first one
$ RC_VERBOSE=true ./trc -F 'echo Hello' echo World
2017-02-22 00:52:20 trc [main/16530]: The wait policy: wait_any
2017-02-22 00:52:20 trc [sync/16538]: Launching on the foreground: echo Hello
Hello
2017-02-22 00:52:20 trc [sync/16538]: Exiting on the foreground (0): echo Hello
2017-02-22 00:52:20 trc [sync/16538]:  - terminating the main <16530>
2017-02-22 00:52:20 trc [main/16530]: Going down. Running shutdown scripts...
2017-02-22 00:52:20 trc [main/16530]: Handling of termination...
2017-02-22 00:52:20 trc [main/16530]: Exited.
```
```bash
# The same goal and it waits for all commands
$ RC_VERBOSE=true \
  RC_WAIT_POLICY=wait_all \
  ./trc -F 'echo Hello' \
        echo World
2017-02-22 00:54:02 trc [main/16794]: The wait policy: wait_all
2017-02-22 00:54:02 trc [sync/16802]: Launching on the foreground: echo Hello
Hello
2017-02-22 00:54:02 trc [sync/16802]: Exiting on the foreground (0): echo Hello
2017-02-22 00:54:02 trc [sync/16810]: Launching on the foreground: echo World
World
2017-02-22 00:54:02 trc [sync/16810]: Exiting on the foreground (0): echo World
2017-02-22 00:54:02 trc [main/16794]: Going down. Running shutdown scripts...
2017-02-22 00:54:02 trc [main/16794]: Handling of termination...
2017-02-22 00:54:02 trc [main/16794]: Exited.
```
```bash
# A few ways to run commands on the foreground
$ RC_WAIT_POLICY=wait_all \ 
  ./trc -F 'echo Hello' \
        -F 'sleep 1' \
        -F 'echo World'
Hello
World

$ ./trc -F 'echo Hello; sleep 1; echo World'
Hello
World
```
```bash
# Here we're gonna create file on the background, wait for 3 sec and then, read this file 
$ RC_WAIT_POLICY=wait_all \
  ./trc -D 'date > date1.log' \
        -F 'sleep 3' \
        -F 'echo -e "Old time: $(cat date1.log)\nNew time: $(date)"; rm -f date1.log'
Old time: Wed Feb 22 14:15:20 CET 2017
New time: Wed Feb 22 14:15:23 CET 2017

$ ls -l date1.log
ls: cannot access 'date1.log': No such file or directory
```
```bash
# It assigns environment variables in the boot-block an then uses them in the foreground-block
./trc -B 'export myhost=$(hostname) user=$(id -un)' \
      -F 'echo -e "Username: $user\nHostname: $myhost"'
Username: vorakl
Hostname: marche
```
