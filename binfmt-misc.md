# Binfmt support

Binfmt allows you to run binaries from other architectures.

This tutorial describes how to install `binfmt-support` and force kernel to preload, allowing it to freely run binaries from any architecture without the access to host `/usr/bin`.

There are two possible method, depending on how new is your system:

1. For new systems: Ubuntu Artful 17.10, Debian Buster,
2. For older systems: everything else.

## For new systems

### 1. First make sure that you install needed `qemu-user-static`

```bash
sudo apt-get install -y qemu-user-static
```

### 2. Make sure that your kernel is recent enough, at least 4.8 which allows to preload architecture dependent files

### 3. Add support for binfmts

```bash
sed -i '10s/^$/yes/g' /var/lib/binfmts/qemu-arm /var/lib/binfmts/qemu-aarch64
```

You may need to apply the same trick later if you update `qemu-user-static`.

### 4. Reload configuration

```bash
systemctl restart binfmt-support
```

### 5. Test

```bash
docker run --rm -it arm64v8/busybox echo Hello World
```

## For old systems

### 1. First make sure that you install needed `qemu-user-static`

```bash
sudo apt-get install -y qemu-user-static
```

### 2. Make sure that your kernel is recent enough, at least 4.8 which allows to preload architecture dependent files

### 3. Add support for binfmts to `/etc/rc.local`

```bash
echo -1 > /proc/sys/fs/binfmt_misc/qemu-aarch64 || true
echo -1 > /proc/sys/fs/binfmt_misc/qemu-arm || true
echo ':qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:OCF' > /proc/sys/fs/binfmt_misc/register
echo ':qemu-arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:OCF' > /proc/sys/fs/binfmt_misc/register
```

Run `/etc/rc.local` or restart system.

### 4. Test

```bash
docker run --rm -it arm64v8/busybox echo Hello World
```

## Why and not `binfmt-support`?

`binfmt-support` does not support `F` flag to preload architecture files,
which is useful when you run container images for different architectures.

Thus, this would not be possible:

```bash
docker run --rm -it arm64v8/busybox echo Hello World
```

The first `binfmt-support` version with the ability define `F` flag is 2.17. The 2.18 is distributed starting from Ubuntu Artful and Debian Stretch.