#!/bin/bash

add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse"

apt-get update
apt-get upgrade -y

apt-get install -y cmake clang-15 clang++-15 libxcursor-dev libxcursor1 \
	libpthread-stubs0-dev libgl1-mesa-dev libx11-dev libxrandr-dev libfreetype6-dev \
	libglew-dev libjpeg8-dev libsndfile1-dev libopenal-dev libudev-dev libxcb-image0-dev \
	libjpeg-dev libflac-dev

dpkg --add-architecture i386

apt-get update

apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libx11-dev libxmu-dev \
	libglu1-mesa-dev libgl2ps-dev libxi-dev libzip-dev libpng-dev libcurl4-gnutls-dev \
	libfontconfig1-dev libsqlite3-dev libglew-dev libssl-dev libgtk-3-dev binutils \
	libxxf86vm-dev chrpath rsync

update-alternatives --install /usr/bin/cc cc /usr/bin/clang-15 100
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-15 100