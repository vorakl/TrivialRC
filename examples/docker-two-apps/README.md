# The example of launching two applications within one docker container

In this example we will launch Python Flask application plus uWSGI behind Nginx in one docker container.
They will work simultaneously and communicate to each other inside the same container. 
If any of these serviceses, either uWSGI or Nginx, at any point of time, has stopped working by some reasons, 
the whole container will be stopped as well by TrivialRC.

## Build

Run this command from the directory with the example:

```bash
docker build -t trc-test-2apps .
```

## Test

Let's run a new container with mapping its port 80 to the host's port 8080:

```bash
docker run -d -p 8080:80 --name trc-test-2apps -e RC_VERBOSE=true trc-test-2apps
```

To check if both services were started and a container is up and running, run next commands:

```bash
docker ps -al
docker logs trc-test-2apps
```

Now we can check if the Flask application is answering by accessing port 8080 on the localhost.
It should show a JSON document with HTTP request headers.

```bash
$ curl http://localhost:8080/
{
  "base_url": "http://localhost:8080/", 
  "cookies": {}, 
  "full_path": "/?", 
  "headers": {
    "Accept": "*/*", 
    "Content-Length": "", 
    "Content-Type": "", 
    "Host": "localhost:8080", 
    "User-Agent": "curl/7.51.0"
  }, 
  "host": "52d0ba70fef2", 
  "host_url": "http://localhost:8080/", 
  "method": "GET", 
  "path": "/", 
  "query_string": "", 
  "scheme": "http"
}
```

If you wanna check that a container is really being stopped when uWSGI or Nginx doesn't work in the container,
you can stop any of them while a container is still running and check its status:

```bash
$ docker exec trc-test-2apps pkill nginx

$ docker ps -al
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                       PORTS               NAMES
52d0ba70fef2        trc-test-2apps      "/etc/trc"          12 minutes ago      Exited (143) 8 seconds ago                       trc-test-2apps

$ docker logs trc-test-2apps |& tail -10
WSGI app 0 (mountpoint='') ready in 1 seconds on interpreter 0x559785bca080 pid: 26 (default app)
*** uWSGI is running in multiple interpreter mode ***
spawned uWSGI worker 1 (and the only) (pid: 26, cores: 16)
[pid: 26|app: 0|req: 1/1] 172.17.0.1 () {32 vars in 324 bytes} [Sat Mar  4 21:26:15 2017] GET / => generated 389 bytes in 4 msecs (HTTP/1.1 200) 2 headers in 72 bytes (2 switches on core 1)
[04/Mar/2017:21:26:15 +0000] localhost 172.17.0.1 "GET / HTTP/1.1" 200 389 "-" "curl/7.51.0" "-"
2017-03-04 21:33:31 trc [async/16]: Exiting in the background (exitcode=0): /etc/trc.d/async.nginx
2017-03-04 21:33:31 trc [main/1]: Trying to terminate sub-processes...
2017-03-04 21:33:31 trc [main/1]: terminating the child process <pid=17>
2017-03-04 21:33:31 trc [async/17]: Exiting in the background (exitcode=30): /etc/trc.d/async.uwsgi
2017-03-04 21:33:32 trc [main/1]: Exited (exitcode=143)
```

And don't forget to remove a container manually:)

```bash
$ docker rm trc-test-2apps
```
