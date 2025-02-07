# Crankshaft

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

A turnkey GNU/Linux solution that transforms a Raspberry Pi to an Android Auto head unit.

https://getcrankshaft.com/

# Docker build image

- Ensure binfmt support installed [binfmt-support](binfmt-misc.md)

- Create config for pi-gen
```bash
cp config.example config
```
- Build image
```bash
./build-docker.sh
```
