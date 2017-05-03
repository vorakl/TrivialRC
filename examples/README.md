# TrivialRC's examples

* [One-liners](https://github.com/vorakl/TrivialRC/blob/master/examples/one-liners/README.md) which show most common use cases and features
* The example of using [configuration files](https://github.com/vorakl/TrivialRC/tree/master/examples/config-files) instead of command line parameters
* A docker container that registers itself in a [Service Discovery](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-service-discovery) in the beginning, then starts some application and automatically removes the registration on exit
* This example launches [two different applications](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-two-apps) inside one docker container and controls the availability both of them. If any of applications has stopped working by some reasons, the whole container will be stopped automatically with an appropriate exit status
* The example of building [docker base images](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-base-images) with TrivialRC as an ENTRYPOINT
* Another useful use case is using TrivialRC for [process managing](https://github.com/vorakl/TrivialRC/tree/master/examples/process-manager) of a group of processes which represent one compound application and can be invoked then on the system from the Sysdemd 
* This solution shows how to [configure services in a docker container by using templates](https://github.com/vorakl/TrivialRC/tree/master/examples/docker-config-templates) and environment variables
* This example goes even further and shows how easy to [download a configuration from remote resource at run-time](https://github.com/vorakl/docker-images/tree/master/centos-opensmtpd#download-configuration-at-run-time-from-a-remote-resource) in docker container
* This trick shows how to [create configuration on the fly](https://github.com/vorakl/TrivialRC/tree/master/examples/self-configuring) from the `boot` stage
* [Serial launching of a group of parallel processes](https://github.com/vorakl/TrivialRC/tree/master/examples/sync-run-of-async-groups) and failing immediately if some group failed
* [Reliable tests](https://github.com/vorakl/TrivialRC/tree/master/examples/reliable-tests-for-docker-images) for docker images

