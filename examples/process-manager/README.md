# Managing a group of processes

When your application is quite complex and it relies on a specific group of processes (other applications) there is a need to having a controller of this group as a whole. Usually, all processes have to be in UP state all the time for a proper functioning and a process manager restarts some of them in case of failures, writes some messages to the log, etc. If it's not possible to bring back to life a failed app, it should puts down the whole group, notify about this error and finishes with a proper exit status.

So, this is the solution. It consists of systemd unit that runs TrivialRC that runs some three apps. Each of them will be run asynchronously. There is a special routine in each async task that restarts the app if it fails and writes a message about that to the main log using one of [internal functions](https://github.com/vorakl/TrivialRC#integrated-functions). There are available a few function for logging which are printing out messages in the same format as TrivialRC does and depending on values of environment variables (RC_VERBOSE, RC_VERBOSE_EXTRA). Please, follow the link for more information.

To prevent printing out stdout/stderr from all applications to the same tty at the same time by making a real mess, each async task will redirect stdout/stderr to the uniq file per task and then another async task will be tailing them line by line and prefixing lines by a task id. All uniq files for logging will be created at `boot` stage and removed at `halt` stage. By doing this, we will have on the main tty only TrvialRC's logs regarding launching tasks and probably some logs from tasks if they were sent by `log` of `warn` functions.
All these messages will be seen by running via `journalctl`.

Of course, you can ignore configuring extra async task for printing messages from apps' tasks with uniq prefixes and keep logs persistently in the same files without creating/removing them at `boot` and `halt` stages.
