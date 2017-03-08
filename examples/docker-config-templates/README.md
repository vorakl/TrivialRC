# Changing configuration of HAProxy in a docker container at run-time

## Build

Run this command from the directory with the example

```bash
docker build -t trc-test-conftpl .
```

## Environment

To test HAProxy by balancing some traffic, there will be used three instances with Nginx + uWSGI + Python Flask application which was explained in the another example - [Two applications in one docker image](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-two-apps). They all will be started from the same docker image on three different IP addresses and port 80.

Let's create three additional IP addresses on the localhost for future instances:

```bash
$ sudo ip addr add 127.0.0.2/32 dev lo
$ sudo ip addr add 127.0.0.3/32 dev lo
$ sudo ip addr add 127.0.0.4/32 dev lo
```

And run three containers:

```bash
$ docker run -d -p 127.0.0.2:80:80 --name trc-test-2apps-1 -e RC_VERBOSE=true trc-test-2apps
$ docker run -d -p 127.0.0.3:80:80 --name trc-test-2apps-2 -e RC_VERBOSE=true trc-test-2apps
$ docker run -d -p 127.0.0.4:80:80 --name trc-test-2apps-3 -e RC_VERBOSE=true trc-test-2apps
```

So, now there are 3 instances with the same web application and they all are answering on the port 80 but on different IPs.
Take a look at the `host` field, it will be needed later for finding out that balancing works:

```bash
$ curl http://127.0.0.2/
{
  "base_url": "http://127.0.0.2/",
  "cookies": {},
  "full_path": "/?",
  "headers": {
    "Accept": "*/*",
    "Content-Length": "",
    "Content-Type": "",
    "Host": "127.0.0.2",
    "User-Agent": "curl/7.51.0"
  },
  "host": "2254f0879ac2",
  "host_url": "http://127.0.0.2/",
  "method": "GET",
  "path": "/",
  "query_string": "",
  "scheme": "http"
}

$ curl http://127.0.0.3/
{
  "base_url": "http://127.0.0.3/",
  "cookies": {},
  "full_path": "/?",
  "headers": {
    "Accept": "*/*",
    "Content-Length": "",
    "Content-Type": "",
    "Host": "127.0.0.3",
    "User-Agent": "curl/7.51.0"
  },
  "host": "e758ded171f6",
  "host_url": "http://127.0.0.3/",
  "method": "GET",
  "path": "/",
  "query_string": "",
  "scheme": "http"
}

$ curl http://127.0.0.4
{
  "base_url": "http://127.0.0.4/",
  "cookies": {},
  "full_path": "/?",
  "headers": {
    "Accept": "*/*",
    "Content-Length": "",
    "Content-Type": "",
    "Host": "127.0.0.4",
    "User-Agent": "curl/7.51.0"
  },
  "host": "50afa4eba886",
  "host_url": "http://127.0.0.4/",
  "method": "GET",
  "path": "/",
  "query_string": "",
  "scheme": "http"
}
```

## Preparation

The last piece of a puzzle - load balancer. 
A docker image with HAProxy has only a template of its configuration.
You can modify a final configuration of HAProxy by changing these environment variables.
They all, except BACKEND, have have default values.

* *BACKEND* (array) []
* *BIND_IP* (scalar) [127.0.0.1]
* *MAXCONN* (scalar) [2000]
* *TIMEOUT_CONNECT* (scalar) [5000]
* *TIMEOUT_CLIENT* (scalar) [10000]
* *TIMEOUT_SERVER* (scalar) [10000]

This HAProxy is gonna use host's network to simplify things. The list of backend's names and addresses should be put in the BACKEND array variable. All logs could be found in the host's systemd journal.

## Test

It's time to run a container with HAProxy

```bash
$ docker run -d --name trc-test-conftpl -e RC_VERBOSE=true -e BACKEND="([web1]=127.0.0.2 [web2]=127.0.0.3 [web3]=127.0.0.4)" --net=host -v /run/systemd/journal/:/host-journal trc-test-conftpl

$ docker logs -f trc-test-conftpl
2017-03-08 18:56:48 trc [main/1]: The wait policy: wait_any
2017-03-08 18:56:48 trc [main/1]: Launching on the boot: /etc/trc.d/boot.make-conf
2017-03-08 18:56:48 trc [main/1]: Building a new config file from the template:
global
    log /host-journal/dev-log local0
    maxconn 2000
    stats socket /tmp/haproxy.sock
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    option  redispatch
    option  forwardfor
    timeout connect 5000
    timeout client  10000
    timeout server  10000
frontend web
    bind 127.0.0.1:80
    default_backend web_dyn
backend web_dyn
   balance roundrobin
   server web1 127.0.0.2:80 check
   server web2 127.0.0.3:80 check
   server web3 127.0.0.4:80 check
2017-03-08 18:56:48 trc [async/30]: Launching on the background: /etc/trc.d/async.haproxy
<7>haproxy-systemd-wrapper: executing /usr/local/sbin/haproxy -p /run/haproxy.pid -f /usr/local/etc/haproxy/haproxy.cfg -Ds 
```

Everything is Up and Running!
We can access localhost port 80 three times in row and get the answer from three different containers:

```bash
$ curl -s http://127.0.0.1/ | grep '"host"'
  "host": "2254f0879ac2", 

$ curl -s http://127.0.0.1/ | grep '"host"'
  "host": "e758ded171f6", 

$ curl -s http://127.0.0.1/ | grep '"host"'
  "host": "50afa4eba886", 
```

All logs from HAProxy is being put the host's Journal and can be accessed as following:

```bash
$ sudo journalctl -b -f _COMM=haproxy
Mar 08 19:59:02 marche haproxy[11492]: 127.0.0.1:58086 [08/Mar/2017:18:59:02.514] web web_dyn/web1 0/0/0/2/2 200 566 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
Mar 08 19:59:06 marche haproxy[11492]: 127.0.0.1:58102 [08/Mar/2017:18:59:06.123] web web_dyn/web2 0/0/0/2/2 200 566 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
Mar 08 19:59:09 marche haproxy[11492]: 127.0.0.1:58118 [08/Mar/2017:18:59:09.474] web web_dyn/web3 0/0/0/2/2 200 566 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
```

Let's remove all these containers and IP addresses:

```bash
$ docker rm -f trc-test-conftpl trc-test-2apps-1 trc-test-2apps-2 trc-test-2apps-3
trc-test-conftpl
trc-test-2apps-1
trc-test-2apps-2
trc-test-2apps-3

$ sudo ip addr del 127.0.0.2/32 dev lo
$ sudo ip addr del 127.0.0.3/32 dev lo
$ sudo ip addr del 127.0.0.4/32 dev lo
```

