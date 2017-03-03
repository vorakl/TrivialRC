# The example of a registration a newly created docker container in the Service Discovery

In this example, after a docker container has started up, 
it's going to register in the Service Discovery as a first step. 
After that, it will start the main application and, in the end, on exit by any reasons
the container will remove itself from the Service Discovery as the last step.

As a Service Discovery is used ZooKeeper and you can specify the URL during the docker run.

## Build

Run this command from the directory with the example

```bash
docker build -t trc-test-sd .
```

## Test

To test this example you need an IP of a working ZooKeeper cluster.
The 'virtual app' can be interrupted by pressing `<Ctrl+C>`.

The command line will look like

```bash
$ docker run --rm -it -e ZKURL="srv1[:port1][,srv2[:port2]...]" trc-test-sd
```
For example:

```bash
$ docker run --rm -it -e ZKURL=192.168.1.173 trc-test-sd 2017-03-03 16:49:06 trc [main/1]: The wait policy: wait_any
2017-03-03 16:49:06 trc [main/1]: Launching on the boot: /etc/trc.d/boot.sd-reg
2017-03-03 16:49:06 trc [main/1]: 2a3556e6f646 has been registered at 192.168.1.173
2017-03-03 16:49:06 trc [sync/29]: Launching on the foreground: /etc/trc.d/sync.app
I am alive! Press <Ctrl+C> to exit...
I am alive! Press <Ctrl+C> to exit...
I am alive! Press <Ctrl+C> to exit...
^C2017-03-03 16:49:08 trc [sync/29]: Exiting on the foreground (exitcode=130): /etc/trc.d/sync.app
2017-03-03 16:49:09 trc [main/1]: Trying to terminate sub-processes...
2017-03-03 16:49:09 trc [halt/44]: Running the shutdown script: /etc/trc.d/halt.sd-unreg
2017-03-03 16:49:09 trc [halt/44]: 2a3556e6f646 has been unregistered at 192.168.1.173
2017-03-03 16:49:09 trc [main/1]: Exiting from the shutdown script (exitcode=0): /etc/trc.d/halt.sd-unreg
2017-03-03 16:49:09 trc [main/1]: Exited.

$ echo $?
0
```
