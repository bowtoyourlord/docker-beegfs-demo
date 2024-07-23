# BeeGFS demo server [![Docker](https://github.com/apriorit/docker-beegfs-demo/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/apriorit/docker-beegfs-demo/actions/workflows/docker-publish.yml)

## Introduction

This repository describes setup of the [BeeGFS](https://www.beegfs.io) server environment for testing purposes. It will create **management**, **metadata** and **storage** nodes with `macvlan` networking (they will have each own ip address accessible from outside). It's supposed to be used with a BeeGFS client running on another machine.

Docker images are based on [RedCoolBeans/docker-beegfs](https://github.com/RedCoolBeans/docker-beegfs) but use Ubuntu 20.04 as the parent image instead of CentOS 7.

> **Note** The instructions are written for a Debian-based system (Debian, Ubuntu, Mint) but can be adopted and run on any other system.

## Pre-requisites

The following packages are required for Ubuntu 20.04:
* git
* docker
* docker-compose

```sh
sudo apt install docker docker-compose git
```

Add a local user to the `docker` group:

```sh
sudo usermod -aG docker $USER
```

> **Note** Make sure the group membership is applied correctly to the user, e.g. re-login to the session or reboot.

## How to run

Clone the repository:

```sh
git clone https://github.com/apriorit/docker-beegfs-demo.git
```

Go to `docker-beegfs-demo` and copy `docker-compose.template.yml` to `docker-compose.yml`:

```sh
cd docker-beegfs-demo
cp docker-compose.template.yml docker-compose.yml
```

Edit `docker-compose.yml` to provide your network configuration:

```yml
networks:
  beegfs:
    driver: macvlan
    driver_opts:
      parent: # interface name, for example: ens33
    ipam:
      # macvlan can't use DHCP so we have provide network configuration manually
      config:
        - subnet: # interface subnet, for example: "192.168.1.0/24"
          ip_range: # ip range assigned to the services, for example: "192.168.1.64/30"
          gateway: # ip address of the gateway, for example: "192.168.1.1"
```

To find the interface name and subnet run:

```sh
ip -o -f inet a
```

```sh
> ip -o -f inet a
1: lo    inet 127.0.0.1/8 scope host lo\       valid_lft forever preferred_lft forever
2: ens33    inet 192.168.136.129/24 brd 192.168.136.255 scope global dynamic noprefixroute ens33\       valid_lft 1693sec preferred_lft 1693sec
```

`ens33` is the interface name, the subnet is `192.168.136.129/24`.

To find the gateway run:

```sh
ip route
```

```sh
> ip route
default via 192.168.136.2 dev ens33 proto dhcp metric 101 
192.168.136.0/24 dev ens33 proto kernel scope link src 192.168.136.129 metric 101 
```

The gateway is `192.168.136.2`.

Choose an ip range in your subnet and set it. Docker will assign ip addresses from the range starting from the first value.

> **Note** Make sure the ip adresses in the range is not allocated already to someone else!

Set the ip range to `192.168.136.64/30` for the case described here. It means the first ip address will be `192.168.136.64`, the second will be `192.168.136.65` and so on.

The resulting file should look like this:

```yml
networks:
  beegfs:
    driver: macvlan
    driver_opts:
      parent: ens33
    ipam:
      # macvlan can't use DHCP so we have provide network configuration manually
      config:
        - subnet: "192.168.136.129/24"
          ip_range: "192.168.136.64/30"
          gateway: "192.168.136.2"
```

Run the containers:

```sh
docker-compose up
```

To stop the containers press `Ctrl+C`.

To stop the containers and clean up resources:

```sh
docker-compose down
```

To find ip addresses allocated to each container run:

```sh
docker inspect docker-beegfs-demo_beegfs
```

```sh
> docker inspect docker-beegfs-demo_beegfs
[
        ...
        "Containers": {
            "aab157e1e08bf1774564df16d762f2c521b1854b3199a8277b58fdb847e1095a": {
                "Name": "docker-beegfs-demo_management_1",
                "EndpointID": "4e70f983f59c897dafedd59bb340b288589413f132f79037f6f16e7cd0e4badd",
                "MacAddress": "02:42:c0:a8:88:40",
                "IPv4Address": "192.168.136.64/24",
                "IPv6Address": ""
            },
            "b7e84c57b34207e73d9a9f6ac48f327e2c822cc2c43ca7c3457bc224073a66ae": {
                "Name": "docker-beegfs-demo_storage1_1",
                "EndpointID": "c47c2b93c83c39a335fde8cf5e2bbf50f51b3f35552f48c9c3319a66580d5783",
                "MacAddress": "02:42:c0:a8:88:41",
                "IPv4Address": "192.168.136.65/24",
                "IPv6Address": ""
            },
            "d40ec08ac0fc9a2226e4ec75269c3f72658d1c808aa8acc98f29e3d42d8396ce": {
                "Name": "docker-beegfs-demo_metadata_1",
                "EndpointID": "a0a802e44d19f59b41e84c376dc4c57d3df7a9c1ffc1b3fc588d8230cc6b88b8",
                "MacAddress": "02:42:c0:a8:88:42",
                "IPv4Address": "192.168.136.66/24",
                "IPv6Address": ""
            },
            "948512a8fe83f093461d2398f240d1d7dc8d88ce29a536714ff860a8fbc9a5e4": {
                "Name": "docker-beegfs-demo_storage2_1",
                "EndpointID": "9ee3da2f1f28968177040d4f9228165632dcd4172e94e82d73ad980364eae81c",
                "MacAddress": "02:42:c0:a8:88:43",
                "IPv4Address": "192.168.136.67/24",
                "IPv6Address": ""
            },

        },
        ...
]
```

Now you can connect to the management node from another machine using its ip address.

## Setup on non-virtual (physical) machine (Ubuntu 22.04) && Potential troubleshooting:
At first, you should follow previously mentioned instructions. Whether there are problems still, you can try the following fixes.

There are few tricky moments that aren’t mentioned here and very poorly mentioned on the internet. The thing is, the physical machine with docker **MUST** be connected via ethernet. Whether it is connected via wifi, it is likely that the addresses of management/metadata/storage nodes couldn’t be pinged.

Another important note is that the client-machine (M1 macOS Sonoma in my case) **MUST NOT** be connected via ethernet, but with wifi instead. For some reason, when both computers use ethernet, the docker is inaccessible.

Lastly, the output of `ip -o -f inet ` which is used to find the subnet, will return you, for example: `192.168.1.26/24 `. If nothing works, you might try the following in docker-compose.yml (subnet) `192.168.1.0/24 `.

## Manual images rebuild
Whether you need to edit the beegfs-[SERVICE].conf file and apply the changes, you must do some additional steps rather than only editing the conf files:
1.	Stop the container:
```sh
docker-compose down
```
2.	Check the existing images ID:
```sh
docker images
```
3.	Delete all related images:
```sh
docker images rmi -f [IMAGE_ID]
```
Use the following docker-compose.yml file (don’t forget put on your parent, subnet, ip_range and gateway)

```yml
version: "2"
 
services:
  management:
    image: beegfs-demo-management
    build: 
      context: management
      dockerfile: Dockerfile
    hostname: node01
    networks:
      beegfs:
        aliases:
          - node01
          - management
    ports:
      - "8008:8008"
      - "8008:8008/udp"
  
  metadata:
    image: beegfs-demo-metadata
    build:
      context: metadata
      dockerfile: Dockerfile
    hostname: node02
    networks:
      beegfs:
        aliases:
          - node02
          - metadata
    environment:
      METADATA_SERVICE_ID: 2
    ports:
      - "8005:8005"
      - "8005:8005/udp"
    depends_on:
      - management
  
  storage1:
    image: beegfs-demo-storage
    build: 
      context: storage
      dockerfile: Dockerfile
    hostname: node03
    networks:
      beegfs:
        aliases:
          - node03
          - storage1
    ports:
      - "8003:8003"
      - "8003:8003/udp"
    volumes:
      - ~/beegfs_storage1:/data
    depends_on:
      - management
 
  storage2:
    image: beegfs-demo-storage
    build:
      context: storage
      dockerfile: Dockerfile
    hostname: node04
    networks:
      beegfs:
        aliases:
          - node04
          - storage2
    ports:
      - "8003:8003"
      - "8003:8003/udp"
    volumes:
      - ~/beegfs_storage2:/data
    depends_on:
      - management
 
networks:
  beegfs:
    driver: macvlan
    driver_opts:
      parent: #for example: eno1
    ipam:
      # macvlan can't use DHCP so we have provide network configuration manually
      config:
        - subnet: #for example: "192.168.1.0/24"
          ip_range: #for example: "192.168.1.64/30"
          gateway: #for example: "192.168.1.1"
```
4.	In the directory where your docker-beegfs.yml file is located, run:
```sh
docker-compose build
```
5.	Run the docker
```sh
docker-compose up
```


## How to add more storage nodes
Currently, `docker-compose.yml` provides 2 services that act as storage nodes: `storage1` and `storage2`.

The main idea behind adding additional storage nodes is to utilize BeeGFS's RAID feature.

The actual stored data is split between them and can be found by these paths:
```
/home/<user>/beegfs_storage1/chunks/
/home/<user>/beegfs_storage2/chunks/
```

To add additional nodes you should simply add an additional storage service into `docker-compose.yml`. However, there are several config parametes that should be modified:

- the storage service name (i.e. storage3)
- the hostname (i.e. node05)
- the aliases
- the path on the host for data to be stored in (i.e. ~/beegfs_storage3:/data)

## How to use RAM disks (tmpfs) for storage
Replace `volumes` to `tmpfs` in the `docker-compose.yml`:
```yml
    #volumes:
    #  - ~/beegfs_storage1:/data
    tmpfs:
      - /data:rw,exec,size=500000k
```
Set the appropriate tmpfs size - there should be enough RAM on your server to accomodate it.

## Links
* [RedCoolBeans/docker-beegfs](https://github.com/RedCoolBeans/docker-beegfs)
* [BeeGFS](https://www.beegfs.io)
