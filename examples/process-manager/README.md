# Managing a group of processes

When your application is quite complex and it relies on a specific group of processes (other applications) there is a need to having a controller of this group as a whole. Usually, all processes have to be in "Up and Running" state all the time for a proper functioning. For this purpose, a process manager restarts some of them in case of failures, writes some messages to the log, etc. If it's not possible to bring back to life a failed app, it should puts down the whole group, notify about this situation and finishes with a proper exit status.

So, that's the solution! It consists of systemd unit that runs TrivialRC that runs, let's say, some three apps. Each of them will be run asynchronously. There is a special routine in each async task that restarts the app if it fails and writes a message about that to the main log using one of [internal functions](https://github.com/vorakl/TrivialRC#integrated-functions). There are available a few function for logging which are printing out messages in the same format as TrivialRC does and depending on values of environment variables (RC_VERBOSE, RC_VERBOSE_EXTRA). Please, follow the link for more information.

To prevent printing out stdout/stderr from all applications to the same log at the same time by making a real mess, each async task will redirect stdout/stderr to the uniq named pipe per task and then another async task will be printing them out, line by line, and prefixing lines by a task id. All uniq pipes for logging will be created at `boot` stage and removed at `halt` stage. By doing this, we will have in the main log only TrivialRC's logs regarding launching tasks and logs from tasks if they were sent by `log` of `warn` functions.
All these messages will be seen via `journalctl`.

## Installation

To try this example you need to acomplish 3 steps:

* Install TrivialRC script in a standart path as `/usr/bin/trc` and give it an execute permission
* Copy configuration into /opt/app, so you've got `/opt/app/trc.d/` with all config files
* Copy Systemd unit `trc-example-procmgr.service` to /etc/systemd/system/ and run `sudo systemctl enable trc-example-procmgr`

## Test

If these steps are done, you can simply start Systemd unit and check via journalctl how it reacts on killing different processes from the group:

```bash
$ sudo systemctl start trc-example-procmgr
$ sudo kill `pidof ss`
$ sudo kill `pidof nc`
$ sudo systemctl stop trc-example-procmgr

$ sudo journalctl -o cat -u trc-example-procmgr
Started The example of running TrivialRC as a process manager.
2017-03-06 23:46:29 trc [main/29871]: The wait policy: wait_any
2017-03-06 23:46:29 trc [main/29871]: Launching in the boot: /opt/app/trc.d/boot.create-logs
2017-03-06 23:46:29 trc [async/29929]: Launching in the background: /opt/app/trc.d/async.netlistener-logger
2017-03-06 23:46:29 trc [async/29933]: Launching in the background: /opt/app/trc.d/async.netmon-logger
2017-03-06 23:46:29 trc [async/29928]: Launching in the background: /opt/app/trc.d/async.netlistener
2017-03-06 23:46:29 trc [async/29931]: Launching in the background: /opt/app/trc.d/async.netmon
2017-03-06 23:46:29 trc [async/29934]: Launching in the background: /opt/app/trc.d/async.netsender
2017-03-06 23:46:29 trc [async/29931]: Start monitoring TCP activity...
netmon: State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
2017-03-06 23:46:29 trc [async/29928]: Start a network listener on the port 1234...
netlistener: Mon Mar  6 23:46:29 CET 2017
netlistener: Mon Mar  6 23:46:30 CET 2017
netlistener: Mon Mar  6 23:46:31 CET 2017
netlistener: Mon Mar  6 23:46:32 CET 2017
netlistener: Mon Mar  6 23:46:33 CET 2017
netlistener: Mon Mar  6 23:46:34 CET 2017
Terminated
017-03-06 23:46:34 trc [async/29931]: Monitoring tool has stopped working!
netlistener: Mon Mar  6 23:46:35 CET 2017
2017-03-06 23:46:35 trc [async/29931]: Start monitoring TCP activity...
netmon: State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
netlistener: Mon Mar  6 23:46:36 CET 2017
netlistener: Mon Mar  6 23:46:37 CET 2017
Terminated
2017-03-06 23:46:37 trc [async/29928]: The network listener has stopped working!
2017-03-06 23:46:38 trc [async/29928]: Start a network listener on the port 1234...
netlistener: Mon Mar  6 23:46:39 CET 2017
netlistener: Mon Mar  6 23:46:40 CET 2017
netlistener: Mon Mar  6 23:46:41 CET 2017
netlistener: Mon Mar  6 23:46:42 CET 2017
netlistener: Mon Mar  6 23:46:43 CET 2017
Stopping The example of running TrivialRC as a process manager...
Terminated
Terminated
Terminated
2017-03-06 23:46:43 trc [main/29871]: Trying to terminate sub-processes...
2017-03-06 23:46:43 trc [async/29931]: Exiting in the background (exitcode=143): /opt/app/trc.d/async.netmon
2017-03-06 23:46:43 trc [async/29929]: Exiting in the background (exitcode=0): /opt/app/trc.d/async.netlistener-logger
2017-03-06 23:46:43 trc [async/29933]: Exiting in the background (exitcode=0): /opt/app/trc.d/async.netmon-logger
2017-03-06 23:46:43 trc [async/29934]: Exiting in the background (exitcode=143): /opt/app/trc.d/async.netsender
2017-03-06 23:46:43 trc [async/29928]: Exiting in the background (exitcode=143): /opt/app/trc.d/async.netlistener
2017-03-06 23:46:43 trc [main/29871]: terminating the child process <pid=29928>
2017-03-06 23:46:43 trc [halt/30183]: Running the shutdown script: /opt/app/trc.d/halt.remove-logs
2017-03-06 23:46:43 trc [main/29871]: Exiting from the shutdown script (exitcode=143): /opt/app/trc.d/halt.remove-logs
2017-03-06 23:46:43 trc [main/29871]: Exited (exitcode=143)
Stopped The example of running TrivialRC as a process manager.
```

## Conclusion

You can notice that two processes were restarted automatically:

```bash
017-03-06 23:46:34 trc [async/29931]: Monitoring tool has stopped working!
2017-03-06 23:46:35 trc [async/29931]: Start monitoring TCP activity...

2017-03-06 23:46:37 trc [async/29928]: The network listener has stopped working!
2017-03-06 23:46:38 trc [async/29928]: Start a network listener on the port 1234...
```
More over, every single line is prefixed by the task name as `netlistener` or `netmon`. This makes possible to filter the stream by the task
