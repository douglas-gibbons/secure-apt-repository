This image creates an APT repository and serves it over HTTP. There's also a simple means of adding new packages to the repository, which takes care of all the fiddly details around GPG keys etc.

## Use case

I want to serve up Debian packages so that others can install them.

## Environment Variables

* __NAME__ - name for the GPG key.
* __EMAIL__ - Email address for the GPG key
* __CODENAME__ - APT repo codebase. For example "jessie" for Deian Jessie, or just use "all"
* __ARCHITECTURES__ - e.g. "386 amd64 armhf". These are the _supported_ architectures

## Volumes and Directories

* /var/www/html - this is where the apt files (including packages) are kept
* /packages - this is where packages are uploaded
* /root/.gnupg - the GPG keys. This may be important to you if you set up third party trusts

## Ports

The Apt repository is served on port __80__

## Example Use (With Docker)

```
docker run                                  \
    -e NAME='Douglas Gibbons'               \
    -e EMAIL=doug@ something dot com        \
    -e CODENAME=all                         \
    -e ARCHITECTURES='386 amd64 armhf'      \
    -p 8088:80                              \
    dougg/secure-apt-repository
```

## Example Use (With Docker Compose)

```
version: '2'

services:

  apt:
    image: dougg/secure-apt-repository
    restart: "no"
    ports:
      - "8088:80"
    volumes:
      - repo:/var/www/html
      - key:/root/.gnupg
      - packages:/packages
    environment:
      - NAME="Douglas Gibbons"
      - EMAIL="doug@ something dot com"
      - CODENAME=all
      - ARCHITECTURES=386 amd64 armhf

volumes:
  repo:
    driver: local
  key:
    driver: local
  packages:
    driver: local
```

## Adding a Package to the Repository

Copy it over to the /packages directory. For example:
```
docker cp my_debian_package.deb <container>:/packages/.
```

Update the APT repository with the new package:
```
docker exec <container> /update.sh
```

## Installing Packages From the Repository

Install wget if it not already there:
```
which wget || apt update && apt install -y wget
```

Then add the GPG public key and add the repository:
```
wget -O - http://<host>:<port>/keyFile | apt-key add -
add-apt-repository "deb http://<host>:<port>/ <CODENAME> main"
apt update
```

If you don't have add-apt-repository installed, use this instead:
```
echo "deb http://<host>:<port>/ <CODENAME> main" >> /etc/apt/sources.list
```


In this example we've bound to port 8006 on the docker host, and used "all" as the ```CODENAME``` variable:
```
wget -O - http://172.17.0.1:8006/keyFile | apt-key add -
add-apt-repository "deb http://172.17.0.1:8006/ all main"
apt update
```

## Solutions to Problems

### GPG key creation takes ages, with "Not enough random bytes available"

Check that there's enough entropy __on the docker host__:
```
cat /proc/sys/kernel/random/entropy_avail
42
```

That's not much, so can create some more __on the docker host__:
```
sudo apt install rng-tools
sudo rngd -r /dev/urandom
```

### /update.sh is taking ages to run

Clear out the /packages directory.

