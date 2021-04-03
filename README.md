# Ubuntu Development Image with Systemd and Docker

The purpose of this image is to have almost the full capability of a development VM inside of a Docker container. The image is based on `ubuntu:rolling` with systemd (modeled after [jrei/systemd-ubuntu](https://hub.docker.com/r/jrei/systemd-ubuntu)), docker, and sshd installed.

Since the image is running both systemd and docker, `--privileged` is required as well as bind mounting the host's cgroup: `/sys/fs/cgroup:/sys/fs/cgroup:ro`.
Docker's overlayfs or aufs filesystems do not work inside of a container, so you also must mount your `/var/lib/docker` directory to a volume or bind mount to the host.

The image includes a default user, `user:ruse`.

I recommend using ssh by exposing the docker port on localhost only (as shown below) so the container is not exposed to the whole network. Then you can use ssh proxy through the host machine if you need to connect to it remotely.

## Docker-Compose

```
version: "3"
services:
  dev:
    image: cmulk/ubuntu-systemd-devimage:latest
    container_name: ubuntu-dev
    hostname: dev
    privileged: true
    ports:
      - "127.0.0.1:2222:22" # ssh
    volumes:
      - .:/host # whichever directory contains the code you are working on
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
      - /tmp/dockerlib:/var/lib/docker
 ```
