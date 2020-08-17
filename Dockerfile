# Stolen outright from the pi-gen project.
#
FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted sudo \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        bsdtar libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc \
        binfmt-support ca-certificates \
	pv pxz \
    && rm -rf /var/lib/apt/lists/*

COPY . /crankshaft/

VOLUME [ "/crankshaft/work", "/crankshaft/deploy"]
