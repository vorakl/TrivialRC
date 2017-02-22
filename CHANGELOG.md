* 1.1.0
    * FIX: fixed the bug in catching exit code of foregraound processes in "wait_any" mode
    * FIX: now it ignors errors in the main exit hook
    * ADD: on exitting from sub-process it tries to kill all possible child process if any
    * ADD: added a new mode "boot" (`-B` command line option or `boot.*` files) that runs in the main namespace and results (like environment variables) are "visible" in all other sub-processes
    * ADD: added a new command line option `-F` that runs on the foreground (to run more than one foreground processes)
    * ADD: more way to present configs: 
        * ./trc.d/{boot,sync,async,halt}.*
        * ./trc.{boot,sync,async,halt}.*
    * ADD: added examples
    * CHANGE: supresses stderr for background processes
