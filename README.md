# Crankshaft
A turnkey GNU/Linux solution that transforms a Raspberry Pi to an Android Auto head unit.

https://getcrankshaft.com/

# Docker build image

- Ensure binfmt support installed [binfmt-support](binfmt-misc.md)
- Clone Prebuilts
``` bash
git clone https://github.com/opencardev/prebuilts.git
```
- Create config for pi-gen
```bash
cp config.example config
```
- Build image
```bash
./build-docker.sh
```
