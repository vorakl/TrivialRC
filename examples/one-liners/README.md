# One Liners

```bash
$ ./trc
```
```bash
$ ./trc echo Hello World

Hello World
```
```bash
$ RC_VERBOSE=true ./trc echo Hello World
2017-02-22 00:19:33 trc [main/12570]: The default wait policy: wait_any
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
2017-02-22 00:20:57 trc [main/12811]: The default wait policy: wait_any
2017-02-22 00:20:57 trc [sync/12821]: Launching on the foreground: exit 111
2017-02-22 00:20:57 trc [sync/12821]: Exiting on the foreground (111): exit 111
2017-02-22 00:20:57 trc [sync/12821]:  - terminating the main <12811>
2017-02-22 00:20:57 trc [main/12811]: Going down. Running shutdown scripts...
2017-02-22 00:20:57 trc [main/12811]: Handling of termination...
2017-02-22 00:20:57 trc [main/12811]: Exited.

$ echo $?
111
```
