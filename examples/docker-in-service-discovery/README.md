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

Press `<Ctrl+C>` to exit 

```bash
$ docker run --rm -it -e RC_VERBOSE=true -e ZKURL="srv1[:port1][,srv2[:port2]...]" trc-test-sd
```
