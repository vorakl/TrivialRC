# The example of launching two applications within one docker container

In this example we will launch Python Flask application plus UWSGI behind Nginx in one docker container. They will work simultaneously and communicate to each other inside the same container. If any of these processes, either UWSGI or Nginx, at some point of time, stopped working by some reasons, the whole container will be stopped as well by TrivialRC

## Build

Run this command from the directory with the example

```bash
docker build -t trc-test-2apps .
```

## Test

