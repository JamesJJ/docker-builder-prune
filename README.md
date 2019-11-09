# Docker Builder Prune

[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jamesjj/docker-builder-prune)](https://hub.docker.com/r/jamesjj/docker-builder-prune/)
[![Docker Automated build](https://img.shields.io/docker/cloud/build/jamesjj/docker-builder-prune)](https://hub.docker.com/r/jamesjj/docker-builder-prune/)

The docker build cache may consume a large number of [filesystem inodes](https://en.wikipedia.org/wiki/Inode) especially if building images containing a large number of files.

The docker build cache can be managed with the `docker builder ...` CLI commands. If the cache is large, running the prune command can take several minutes.

Here is a shell script to periodically check inode usage in the `/var/lib/docker` or any other desired directory, and run `docker builder prune ...` if inode usage exceeds the specified threshold.

An example Kubernetes [DaemonSet configuration file](./contrib/k8s-daemonset--docker-builder-prune.yml) shows how this can be run in a [docker container](https://hub.docker.com/r/jamesjj/docker-builder-prune/) on all nodes in a Kubernetes cluster.

One case for use in Kubernetes is with CI/CD agents running inside pods and those agents are connecting to the host's docker daemon to build & push docker container images. Kubernetes itself will [garbage collect images and containers](https://kubernetes.io/docs/concepts/cluster-administration/kubelet-garbage-collection/) that are under K8S control. Other containers and the build cache need to be managed separately. This can help cover the build cache.

## Configuration

The environment variables shown below are available:

| ENVIRONMENT VARIABLE | DEFAULT VALUE | PURPOSE |
|----------------------|----------------------------------------|---|
| `MOUNTPOINTS`        | `/var/lib/docker /data/var_lib_docker` | Space separated list of mountpoints to check. Non-existent locations will be silently skipped |
| `THRESHOLD`          | `50`                                   | Minimum percentage inode usage that will trigger pruning |
| `FILTER`             | `unused-for=1h`                        | Value of `--filter` argument on 	`docker builder prune` command |
| `SLEEP`              | `600`                                  | Time to wait between checks. Value in seconds unless suffixed with `h` or `d` for hours & days respectively |
| `IDENTIFIER`         | Short hostname (from `hostname -s`)    | Included in console logs |
| `HOST_IP`            | Empty                                  | Included in console logs |


## Notes

 * Irrespective of the value of `SLEEP`, the script will wait at least 15 minutes between consecutive executions of `docker builder prune ...`

