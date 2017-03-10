# In this tricky example will be shown how to create configuration on the fly

In the begging, it has only the `boot` stage.
As long as scripts in this stages run in the same environment with the main process, it can bootstrap itself by creating missing configuration. There to ways:
* create configuration files
* modify command line

In this example, will be shown how to modify a command line, to print out the famous "Hello, World!"
Because the whole bootstrapping logic will reside in one boot file, there are no reasons to create a configuration directory.
That's why there is only one file `trc.boot.make-self-conf`.
And don't forget to change a wait policy, otherwise you won't see the result of executing of all commands!
Let's run it:

```bash
$ RC_WAIT_POLICY=wait_all trc -w .
Hello World
```
