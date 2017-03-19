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
2017-02-22 23:10:11 trc [main/23630]: The wait policy: wait_any
2017-02-22 23:10:11 trc [sync/23640]: Launching in the foreground: echo Hello World
Hello World
2017-02-22 23:10:11 trc [sync/23640]: Exiting in the foreground (exitcode=0): echo Hello World
2017-02-22 23:10:11 trc [main/23630]: Going down. Running shutdown scripts...
2017-02-22 23:10:11 trc [main/23630]: Handling of termination...
2017-02-22 23:10:11 trc [main/23630]: Exited.

$ echo $?
0
```
```bash
# Exits with a proper exit code
$ ./trc exit 111

$ echo $?
111
```
```bash
# Both commands are running in the foreground but it exits after the first one by default
$ RC_VERBOSE=true \
  RC_VERBOSE_EXTRA=true \
  ./trc -F 'echo Hello'
        echo World
2017-02-22 23:14:35 trc [main/24314]: The wait policy: wait_any
2017-02-22 23:14:35 trc [sync/24324]: Launching in the foreground: echo Hello
Hello
2017-02-22 23:14:35 trc [sync/24324]:  - exit-trap (exitcode=0)
2017-02-22 23:14:35 trc [sync/24324]: Exiting in the foreground (exitcode=0): echo Hello
2017-02-22 23:14:35 trc [sync/24324]:  - terminating the main process <pid=24314>
2017-02-22 23:14:35 trc [main/24314]:  - sig-trap (exitcode=0)
2017-02-22 23:14:35 trc [main/24314]:  - exit-trap (exitcode=0)
2017-02-22 23:14:35 trc [main/24314]: Going down. Running shutdown scripts...
2017-02-22 23:14:35 trc [main/24314]: Handling of termination...
2017-02-22 23:14:35 trc [main/24314]: Exited.
```
```bash
# To achive the same goal it needs to wait for all commands and then we'll see both outputs
$ RC_WAIT_POLICY=wait_all ./trc -F 'echo Hello' echo World
Hello
World
```
```bash
# A few ways to run many commands in the foreground
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
# It's going to create file in the background, waiting for 3 sec and then reading this file 
$ RC_WAIT_POLICY=wait_all \
  ./trc -D 'date > date1.log' \
        -F 'sleep 3' \
        -F 'echo -e "Old time: $(cat date1.log)\nNew time: $(date)"'
        -F 'rm -f date1.log'
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

