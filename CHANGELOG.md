* 1.1.0
    * FIX: fixed the bug in catching exit code of foregraound processes in "wait_any" mode
    * FIX: now it ignors errors in the main exit hook
    * ADD: on exiting from sub-process it tries to kill all possible child processes if any
    * ADD: a new mode "boot" (`-B` command line option or `boot.*` files) that runs in the main namespace and results (like environment variables) are "visible" in all other sub-processes
    * ADD: a new command line option `-F` that runs commands on the foreground (to run more than one foreground processes)
    * ADD: a new command line option `-H` that runs commands on exiting
    * ADD: new command line options `-v` and `--version` to print the version
    * ADD: new command line options `-h` and `--help` to print a short help message
    * ADD: more ways to present configs: 
        * ./trc.d/{boot,sync,async,halt}.*
        * ./trc.{boot,sync,async,halt}.*
    * ADD: examples
    * ADD: tests
    * ADD: a new wait policy `wait_err` which waits for the first failed command
    * CHANGE: supresses stderr for background processes
