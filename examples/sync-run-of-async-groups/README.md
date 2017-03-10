# Serial launching of group of parallel processes and fails immediately if some group failed

This example uses the idea of ["create configuration on the fly"](https://github.com/vorakl/TrivialRC/tree/master/examples/self-configuring) example. The trick is to run one TrivialRC with one wait policy a group of other TrivialRCs with another wait policy. The goal of a first copy of TrivialRC is:

* to construct a proper list of sync tasks
* itereate over the list checking exit status after each task (because this trc is run with 'wait_err' wait policy)

Each sync task runs another copy of TrivialRC with another wait policy ('wait_all') to iterate over a smaller group of IP address (or other parameters from a command line) by running commands in parallel. All final commands will be forms at the `boot` stage in the same way.

So, it would look like:

```bash
RC_WAIT_POLICY=wait_err trc --workdir .
    \- RC_WAIT_POLICY=wait_all trc --workdir sub-trc IP1 IP2 IP3 ... IP10
           a \- cmd IP1
           s \- cmd IP2
           y \- cmd IP3
           n \- .......
           c \- cmd IP10
   s \- .....        
   y \- .....
   n \- .....
   c \- RC_WAIT_POLICY=wait_all trc --workdir sub-trc IP1 IP2 IP3 ... IP10
           a \- cmd IP1
           s \- cmd IP2
           y \- cmd IP3
           n \- .......
           c \- cmd IP10
```
The main idea is to have only boot scripts for bootstrapping subsequent behavior of the first TrivialRC copy by
running one by one another copy of TrivialRC which eventually runs commands in parallel (one command per one IP).

A number of parallel tasks and a command can be changed by environment variables ASYNC_TASKS and TASK_CMD accordingly.

## Test

```bash
$ RC_WAIT_POLICY=wait_err trc -w .

$ TASK_CMD="uname -a" RC_WAIT_POLICY=wait_err trc -w .

$ ASYNC_TASKS=20 TASK_CMD="id -un" RC_WAIT_POLICY=wait_err trc -w .
```
