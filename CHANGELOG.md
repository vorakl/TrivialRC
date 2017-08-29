    * CHNG: a bare command is executed in the same shell
    * CHNG: the download path has been changed from / to /files/
* 1.1.10
    * FIX: many README files have been fixed. Thanks to Oren Schulman.
* 1.1.7
    * ADD: more examples
    * DEL: deprecated names of configuration files have been removed 
           (`trc.fg.*`, `trc.bg.*`, `trc.sd.*`)
* 1.1.6
    * FIX: now it ignores errors in the main exit hook
    * ADD: more examples
    * ADD: sha256 chaeck sum for the release
* 1.1.5
    * ADD: new command line options `-v` and `--version` to print the version
    * ADD: new command line options `-h` and `--help` to print a short help
           message
    * ADD: new command line options `-w` and `--workdir` to set the directory
           with config files
* 1.1.4
    * ADD: a new wait policy `wait_err` which waits for a first failed command
    * ADD: a new stage "halt" (`-H` command line option or `halt.*` files) that
           runs on exit from the main process
* 1.1.3
    * ADD: a new command line option `-F` that runs commands in the foreground
           (to run more than one foreground processes)
* 1.1.2
    * ADD: on exiting from sub-process it tries to kill all possible child
           processes if any
* 1.1.1
    * FIX: fixed the bug in catching exit code of foregraound processes in
           "wait_any" mode
* 1.1.0
    * ADD: a new stage "boot" (`-B` command line option or `boot.*` files) that
           runs in the main namespace and results (like environment variables)
           are "visible" in all other sub-processes
    * ADD: more ways to present configs: 
        * ./trc.d/{boot,sync,async,halt}.*
        * ./trc.{boot,sync,async,halt}.*
    * ADD: examples
    * ADD: tests
