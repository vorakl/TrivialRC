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
# Both commans are running on the foreground but it exits after the first one
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
$ RC_VERBOSE=true RC_WAIT_POLICY=wait_all ./trc -F 'echo Hello' echo World
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
$ RC_WAIT_POLICY=wait_all ./trc -F 'echo Hello' -F 'sleep 1' -F 'echo World'
Hello
World

$ ./trc sh -c 'echo Hello; sleep 1; echo World'
Hello
World
```
