# Docker Yum Repository

This is a tiny container based on [Alpine distro](https://alpinelinux.org/) that acts as a 'yum' repository to test your RPMs.

---

* [Docker Image](#docker-image)
* [Requirements](#requirements)
* [Limitations](#limitations)
* [How-to](#how-to)
* [To-Do](#to-do)

---
### Docker Image

[![](https://images.microbadger.com/badges/version/intraway/yumrepo.svg)](https://microbadger.com/images/intraway/yumrepo "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/intraway/squid-proxy.svg)](https://microbadger.com/images/intraway/squid-proxy "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/intraway/squid-proxy.svg)](https://microbadger.com/images/intraway/squid-proxy "Get your own commit badge on microbadger.com") [![](https://images.microbadger.com/badges/license/intraway/squid-proxy.svg)](https://microbadger.com/images/intraway/squid-proxy "Get your own license badge on microbadger.com")

---

### Requirements
* `docker-engine` >= 1.12
* `docker-compose` >= 1.8.1

---

### Limitations
* None

---

### How-to

#### Manually (with `docker run`)

You can manually run these commands:

```bash
docker run -d -v <path_to_rpms>:/var/repo:rw intraway/yumrepo
```

You must mount a directory inside of the container the contains all RPM's that you want serve.
This directory may have other nested directories to respect the structure of a Yum repository; for example 6/x86_64, 6/i386, 7/x86_64.

#### Run via docker-compose

There is a `docker-compose.yml` file to enable launching via [docker compose](https://docs.docker.com/compose/).
To use this you will need a local checkout of this repo and have `docker` and `compose` installed.

> Run the following command in the same directory as the `docker-compose.yml` file:

```bash
 docker-compose up
```

You can customize the `docker-compose.yml`:

```yaml
version: '2'

services:
  yumrepo:
    image: intraway/yumrepo
    hostname: yumrepo
    container_name: yumrepo
    ports:
      - 80
    volumes:
      - ./extras/dummyrepo:/var/repo:rw
      - /etc/localtime:/etc/localtime
    environment:
      - REPO_PORT=80
      - REPO_PATH=/var/repo
      - REPO_DEPTH=2

  centos6:
    image: centos:6
    hostname: centos6-client
    container_name: centos6-client
    links:
      - yumrepo:repo
    volumes:
      - ./extras/yum/container.repo:/etc/yum.repos.d/container.repo:ro
      - /etc/localtime:/etc/localtime
    command: yum --disablerepo=* --enablerepo=container install dummy-package-1.2

  centos7:
    image: centos:7
    hostname: centos7-client
    container_name: centos7-client
    links:
      - yumrepo:repo
    volumes:
      - ./extras/yum/container.repo:/etc/yum.repos.d/container.repo:ro
      - /etc/localtime:/etc/localtime
    command: yum --disablerepo=* --enablerepo=container info dummy-package-1.0_SNAPSHOT
```

#### Tuning

The docker image can be tuned using environment variables.

###### REPO_PORT
Repository listening port. Use the `-e REPO_PORT=80` to set the listening port.

###### REPO_PATH
Base path where the repository will be created inside the container. Use the `-e REPO_PATH=/var/repo`.

###### REPO_DEPTH
Number of levels that will have the repository to create. For example, use `-e REPO_DEPTH=2` if your repository have two levels depth (<relversion>/<architecture>).

---

### To-Do
* Listening for improvements

---

<p align="center"><img src="http://www.catb.org/hacker-emblem/glider.png" alt="hacker emblem"></p>
