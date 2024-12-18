# Keepalived 

[![trivy](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/trivy.yml/badge.svg)](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/trivy.yml)
[![docker-hub-description](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/docker-hub-description.yml/badge.svg)](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/docker-hub-description.yml)
[![build status](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/main.yml/badge.svg)](https://github.com/visibilityspots/dockerfile-keepalived/actions/workflows/main.yml)
[![gitHub release](https://img.shields.io/github/v/release/visibilityspots/dockerfile-keepalived)](https://github.com/visibilityspots/dockerfile-keepalived/releases)
[![docker image size](https://img.shields.io/docker/image-size/visibilityspots/keepalived/latest)](https://hub.docker.com/r/visibilityspots/keepalived)
[![docker pulls](https://img.shields.io/docker/pulls/visibilityspots/keepalived.svg)](https://hub.docker.com/r/visibilityspots/keepalived/)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fvisibilityspots%2Fdockerfile-keepalived.svg?type=shield&issueType=license)](https://app.fossa.com/projects/git%2Bgithub.com%2Fvisibilityspots%2Fdockerfile-keepalived?ref=badge_shield&issueType=license)


a docker container which runs [keepalived.org](http://keepalived.org/)

orginally based on the work of [linkvt](https://github.com/linkvt/docker-keepalived) but simplified the approach for my own needs along the way.

## run

This image require the kernel module ip_vs loaded on the host (`modprobe ip_vs`) and need to be run with : --cap-add=NET_ADMIN --net=host

```
$ docker run --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=host --name keepalived --rm visibilityspots/keepalived:latest
```

## Configuration

Environment variables defaults are set in the Dockerfile and can be overriden;

ENV KEEPALIVED_INTERFACE eth0
ENV KEEPALIVED_STATE BACKUP
ENV KEEPALIVED_ROUTER_ID 21
ENV KEEPALIVED_PRIORITY 150
ENV KEEPALIVED_UNICAST_PEERS 192.168.0.11 - 192.168.0.12
ENV KEEPALIVED_VIRTUAL_IPS 192.168.0.10
ENV KEEPALIVED_VIRTUAL_ROUTES 192.168.0.0/24 dev eth0 scope link src 192.168.0.10
ENV KEEPALIVED_PASSWORD d0ck3r
ENV KEEPALIVED_NOTIFY notify "/usr/local/bin/keepalived-notify.sh"

### Override ENV variables

Environment variables can be set by adding the --env argument in the command line, for example:


```
$ docker run --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=host --env KEEPALIVED_INTERFACE="eno1" --env KEEPALIVED_PASSWORD="password!" --env KEEPALIVED_PRIORITY="100" --name keepalived --rm visibilityspots/keepalived:latest
```

## build

```
$ docker build -t visibilityspots/keepalived:latest .
```

### buildx

```
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
$ docker buildx build -t visibilityspots/keepalived:latest --platform linux/amd64,linux/arm/v6,linux/arm/v7 --push .
```

### dgoss

I wrote some tests in a goss.yaml file which can be executed by [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) to test the created image

```
$ dgoss run visibilityspots/keepalived:2.2.8
INFO: Starting docker container
INFO: Container ID: 6e6ea44f
INFO: Sleeping for 0.2
INFO: Container health
INFO: Running Tests
File: /usr/local/bin/keepalived-notify.sh: exists: matches expectation: true
File: /etc/keepalived/keepalived.conf: exists: matches expectation: true
File: /etc/keepalived/keepalived.conf.tmpl: exists: matches expectation: true
Command: keepalived --version: exit-status: matches expectation: 0
Package: keepalived: installed: matches expectation: true
Package: keepalived: version: matches expectation: ["2.2.8-r0"]
Package: envsubst: gettext-envsubst: installed: matches expectation: true


Total Duration: 0.006s
Count: 7, Failed: 0, Skipped: 0
INFO: Deleting container
```

### act

using [act](https://github.com/nektos/act#overview----) for local testing of the written github actions makes my life and commit history a lot easier;

```
Stage  Job ID  Job name  Workflow name           Workflow file               Events
0      update  update    docker-hub-description  docker-hub-description.yml  push
0      main    main      CI                      main.yml                    push
0      scan    scan      trivy                   trivy.yml                   push,schedule
```

## License

Distributed under the [MIT license](https://github.com/visibilityspots/dockerfile-keepalived/blob/master/LICENSE)
