# Keeping the configuration in files

In this examples it will set a few variables and defining a new function in the `boot` mode.
Then in the background (in the `async` mode) it will create a file using the new function and values of variables.
On the next step, it will run in `sync` mode (in the foreground). Here, trc first sleeps for a defined number of seconds
and then prints out the content of the file. On the last step, it will run in `halt` mode and remove previously created file.
A required RC_WAIT_POLICY for this example is wait_all.

### The structure of `trc.d` directory

```bash
$ ls -1 trc.d/
async.info
boot.funcs
boot.setvars
halt.delfile
sync.1
sync.2
```

### The execution order

1. boot.funcs
2. boot.setvars
3. async.info
4. sync.1
5. sync.2
6. halt.delfile

### Results

* without logs

```bash
$ RC_WAIT_POLICY=wait_all ./trc
host:	marche
ip:     127.0.0.1
login:	vorakl
```

* with logs

```bash
$ RC_VERBOSE=true RC_WAIT_POLICY=wait_all ./trc
2017-02-23 01:04:16 trc [main/7207]: The wait policy: wait_all
2017-02-23 01:04:16 trc [main/7207]: Launching in the boot: ./trc.d/boot.funcs
2017-02-23 01:04:16 trc [main/7207]: Launching in the boot: ./trc.d/boot.setvars
2017-02-23 01:04:16 trc [async/7225]: Launching in the background: ./trc.d/async.info
2017-02-23 01:04:16 trc [sync/7231]: Launching in the foreground: ./trc.d/sync.1
2017-02-23 01:04:16 trc [async/7225]: Exiting in the background (exitcode=0): ./trc.d/async.info
2017-02-23 01:04:18 trc [sync/7231]: Exiting in the foreground (exitcode=0): ./trc.d/sync.1
2017-02-23 01:04:18 trc [sync/7244]: Launching in the foreground: ./trc.d/sync.2
host:	marche
ip:     127.0.0.1
login:	vorakl
2017-02-23 01:04:18 trc [sync/7244]: Exiting in the foreground (exitcode=0): ./trc.d/sync.2
2017-02-23 01:04:18 trc [main/7207]: Going down. Running shutdown scripts...
2017-02-23 01:04:18 trc [halt/7256]: Running the shutdown script: ./trc.d/halt.delfile
2017-02-23 01:04:18 trc [main/7207]: Handling of termination...
2017-02-23 01:04:18 trc [main/7207]: Exited.
```
