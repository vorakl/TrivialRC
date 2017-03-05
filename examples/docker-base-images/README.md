# The example of building docker base images with TrivialRC as an ENTRYPOINT

In this example, as base images were taken CentOS and Alpine.
Basically, it shows two different approaches which are specific for each distribution.

## Build

Run these commands from the directory with the example

```bash
$ docker build -t centos-base -f Dockerfile.centos .
$ docker build -t alpine-base -f Dockerfile.alpine .
```

## Test

Let's test that TrivialRC works as expected

```bash
$ docker run --rm -e RC_VERBOSE=true centos-base
2017-03-05 22:31:15 trc [main/1]: The wait policy: wait_any
2017-03-05 22:31:15 trc [main/1]: Trying to terminate sub-processes...
2017-03-05 22:31:15 trc [main/1]: Exited (exitcode=0)

$ docker run --rm -e RC_VERBOSE=true alpine-base
2017-03-05 22:31:29 trc [main/1]: The wait policy: wait_any
2017-03-05 22:31:29 trc [main/1]: Trying to terminate sub-processes...
2017-03-05 22:31:29 trc [main/1]: Exited (exitcode=0)
```
