# Reliable tests of docker images

If you have automated builds of docker images, you need to be sure that these images are not only built successfuly but also run services. Sometimes, services fail immidiately after they were started up. 

This is an example of how services can be reliably tested without any extra efforts by adding a test proccess on the background and then, checking the exit status on exit. 

As an example docker image I'm going to use [OpenSMTPD](https://github.com/vorakl/docker-images/tree/master/centos-opensmtpd) service image. Then, inject a background test command. In case of a success test, it will send a specific signal to the main process and cause by this (because a default wait policy is `wait_any`) a stop the whole container. On exit, I'll inject a `halt` command to check if the main process has cought my signal (128 + 10 = 138). If yes, I'll rewrite an exit status to 0 (success). Otherwise, the script will finish with some other error.

So many words but in fact it looks much more simple. It just a one-liner:

```bash
$ docker run --rm vorakl/centos-opensmtpd -H 'if [[ ${_exit_status} -eq 138 ]]; then exit 0; else exit ${_exit_status}; fi' -D 'sleep 3; smtpctl show status && kill -10 ${MAINPID}'

2017-03-16 21:40:50 trc [main/1]: The wait policy: wait_any
2017-03-16 21:40:50 trc [async/15]: Launching on the background: /etc/trc.d/async.opensmtpd
2017-03-16 21:40:50 trc [async/16]: Launching on the background: sleep 3; smtpctl show status && kill -10 ${MAINPID}
info: OpenSMTPD 6.0.2p1 starting
setup_peer: klondike -> control[28] fd=4
setup_peer: klondike -> pony express[30] fd=5
setup_done: ca[27] done
setup_proc: klondike done
setup_peer: control -> klondike[27] fd=5
setup_peer: control -> lookup[29] fd=6
setup_peer: control -> pony express[30] fd=7
setup_peer: control -> queue[31] fd=8
setup_peer: control -> scheduler[32] fd=9
setup_done: control[28] done
setup_proc: control done
setup_peer: scheduler -> control[28] fd=9
setup_peer: scheduler -> queue[31] fd=10
setup_peer: lookup -> control[28] fd=6
setup_peer: lookup -> pony express[30] fd=7
setup_peer: lookup -> queue[31] fd=8
setup_done: lka[29] done
setup_proc: lookup done
setup_peer: pony express -> control[28] fd=7
setup_peer: queue -> control[28] fd=8
setup_peer: pony express -> klondike[27] fd=8
setup_peer: queue -> pony express[30] fd=9
setup_peer: queue -> lookup[29] fd=10
setup_peer: queue -> scheduler[32] fd=11
setup_peer: pony express -> lookup[29] fd=9
setup_peer: pony express -> queue[31] fd=10
setup_done: pony[30] done
setup_proc: pony express done
setup_done: queue[31] done
setup_proc: scheduler done
setup_done: scheduler[32] done
smtpd: setup done
warn: purge_task: opendir: No such file or directory
setup_proc: queue done
MDA running
MTA running
SMTP running
2017-03-16 21:40:53 trc [async/16]: Exiting on the background (exitcode=0): sleep 3; smtpctl show status && kill -10 ${MAINPID}
2017-03-16 21:40:53 trc [main/1]: Trying to terminate sub-processes...
2017-03-16 21:40:53 trc [main/1]: terminating the child process <pid=15>
info: Terminated, shutting down
info: control process exiting
info: ca agent exiting
info: pony agent exiting
info: queue handler exiting
info: lookup agent exiting
info: scheduler handler exiting
warn: parent terminating
2017-03-16 21:40:53 trc [async/15]: Exiting on the background (exitcode=0): /etc/trc.d/async.opensmtpd
2017-03-16 21:40:54 trc [halt/60]: Running the shutdown command: if [[ ${_exit_status} -eq 138 ]]; then exit 0; else exit ${_exit_status}; fi
2017-03-16 21:40:54 trc [main/1]: Exiting from the shutdown command (exitcode=0): if [[ ${_exit_status} -eq 138 ]]; then exit 0; else exit ${_exit_status}; fi
2017-03-16 21:40:54 trc [main/1]: Exited (exitcode=0)
```
