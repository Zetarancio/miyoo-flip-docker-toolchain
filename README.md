# miyoo-flip-docker-toolchain
This is a docker toolchain for Miyoo Flip v2 Rockchip handheld device using GLIBC 2.38.
It is compatible with SpruceOS but can probably be adapted to other OS.
You can find the required system variables in entrypoint.sh

## Dump sysroot
In order to work on your device you need to dump a sysroot from the device:

`export DEV="spruce@10.72.222.251"`

`export SYSROOT="$HOME/spruce-sysroot"`

`mkdir -p "$SYSROOT"`

`rsync -aH --numeric-ids --info=progress2 
  --rsync-path=/mnt/SDCARD/spruce/bin64/rsync 
  --ignore-errors --partial 
  --exclude={"/proc/*","/sys/*","/dev/*","/tmp/*","/run/*","/mnt/*","/media/*","/var/*","home/*","root/*"} 
  --exclude="/usr/lib/libfreeimage-3.18.0.so" 
  "$DEV":/ "$SYSROOT"`

## Obtain toolchain
Download [Steward-Fu toolchain](https://steward-fu.github.io/website/handheld/mymini_cpp_setup.htm). 

`wget https://github.com/steward-fu/website/releases/download/miyoo-flip/flip-toolchain-v1.0.tar.gz`

`tar xvf flip-toolchain-v1.0.tar.gz`

`mv flip ./flip-toolchain-v1.0`

## Build and run docker container
`UID=$(id -u) GID=$(id -g) docker compose run --rm flip-build`

`UID=$(id -u) GID=$(id -g) docker compose build --no-cache`

## Check for GLIBC and libraries compatibility of a compiled binary
**ON DEVICE**
`/lib/ld-linux-aarch64.so.1 --version | head -n 1`

`strings /usr/lib/libc.so.6 | grep -o 'GLIBC_[0-9]+.[0-9]+' | sort -V | tail -n 1`

`strings /usr/lib/libstdc++.so.6 | grep -o 'GLIBCXX'`

`/lib/ld-linux-aarch64.so.1 --list MYBINARY`

**ON FILE**

`strings ./MYBINARY | grep GLIBC_`

`readelf --version-info ./MYBINARY`

`readelf -l MYBINARY | grep 'Requesting program interpreter'`

`readelf -d MYBINARY | grep NEEDED`

# Build an application (es. Retroarch):
No need to export variables since they are set when the docker starts:

`PKG_CONFIG="${TOOLCHAIN}/bin/pkg-config" 
PKG_CONFIG_SYSROOT_DIR="$SYSROOT" 
PKG_CONFIG_LIBDIR="${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig:${SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${SYSROOT}/usr/share/pkgconfig"
PKG_CONFIG_PATH= 
CC=aarch64-flip-linux-gnu-gcc 
CXX=aarch64-flip-linux-gnu-g++ 
AR=aarch64-flip-linux-gnu-ar 
RANLIB=aarch64-flip-linux-gnu-ranlib 
STRIP=aarch64-flip-linux-gnu-strip 
CFLAGS="--sysroot=$SYSROOT -O2 -pipe" 
CPPFLAGS="--sysroot=$SYSROOT -O2 -pipe" 
LDFLAGS="--sysroot=$SYSROOT -Wl,--dynamic-linker=/lib/ld-linux-aarch64.so.1 -L$SYSROOT/usr/lib -L$SYSROOT/lib" \./configure 
  --host=aarch64-flip-linux-gnu 
  --prefix=/usr 
  --disable-x11 --disable-wayland --disable-vulkan --disable-opengl --disable-qt 
  --enable-opengles --enable-opengles3 --enable-sdl2 --enable-sdl --enable-mali_fbdev --disable-kms 
  --enable-alsa --disable-pulse --disable-jack --disable-oss 
  --enable-networking --enable-ssl --enable-command --enable-builtinzlib --enable-zlib --enable-freetype 
  --enable-ffmpeg --disable-discord --disable-udev`
`make`

**RETROARCH MINIMUM SETTINGS
**
video_driver = "gl"
video_context_driver = "sdl_gl"
input_driver = "sdl2"
audio_driver = "alsa"
video_fullscreen = "true"
video_scale_integer = "true"
video_smooth = "false"`
