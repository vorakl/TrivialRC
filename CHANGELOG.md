* 1.1.0
    * FIX: fixed the bug in catching exit code of foregraound processes in "wait_any" mode
    * ADD: on exitting from sub-process it tries to kill all possible child process if any
    * ADD: added a new mode "boot" (`-B` command option or `boot.*` files) that runs in the main namespace and is visible from iall other subprocesses
    * ADD: more way to present configs: 
        * ./trc.d/{boot,sync,async,halt}.*
        * ./trc.{boot,sync,async,halt}.*
    * ADD: added examples
