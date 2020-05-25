# ARMv7l (32-bit) Certbot Docker Containers
Set of Certbot docker containers (core and its plugins) compiled in ARMv7l (32-bit) ready to run on raspbian or other ARMv7 32-bits systems. Inspited by its forked [certbot-docker](https://github.com/certbot-docker/certbot-docker)

```bash
$ docker login
$ export CERTBOT_VERSION="1.4.0" # If left empty it will fetch the latest release from Github
$ export DOCKER_REPO="kitos9112/certbot-armv7l"
$ ./build.sh
```

## Notes
For the time being, I am using my own Raspberry Pi 3B+ for building and pushing purposes