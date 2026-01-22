#!/usr/bin/env bash
set -euo pipefail

: "${TOOLCHAIN:=/opt/flip}"

# sysroot "giusto" per compilare: quello della toolchain (completo di crt*.o)
TOOLCHAIN_SYSROOT="$("${TOOLCHAIN}/bin/aarch64-flip-linux-gnu-gcc" -print-sysroot)"

# opzionale: se monti anche il sysroot del device, lo tieni separato
: "${DEVICE_SYSROOT:=/device-sysroot}"

export PATH="${TOOLCHAIN}/bin:${TOOLCHAIN}/aarch64-flip-linux-gnu/bin:${PATH}"

# Usa i wrapper, NON i .br_real
export CC="${TOOLCHAIN}/bin/aarch64-flip-linux-gnu-gcc"
export CXX="${TOOLCHAIN}/bin/aarch64-flip-linux-gnu-g++"
export AR="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/ar"
export AS="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/as"
export LD="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/ld"
export NM="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/nm"
export OBJCOPY="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/objcopy"
export OBJDUMP="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/objdump"
export RANLIB="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/ranlib"
export READELF="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/readelf"
export STRIP="${TOOLCHAIN}/aarch64-flip-linux-gnu/bin/strip"

# Flags coerenti col sysroot toolchain
export SYSROOT="${TOOLCHAIN_SYSROOT}"
export CPPFLAGS="--sysroot=${SYSROOT}"
export CFLAGS="--sysroot=${SYSROOT} -O2 -fPIC"
export CXXFLAGS="--sysroot=${SYSROOT} -O2 -fPIC"
#export LDFLAGS="--sysroot=${SYSROOT}"
export LDFLAGS="--sysroot=$SYSROOT -Wl,--as-needed --dynamic-linker=/lib/ld-linux-aarch64.so.1 -L$SYSROOT/usr/lib -L$SYSROOT/lib"
#export LDFLAGS="--sysroot=$SYSROOT -Wl,--as-needed"

# pkg-config coerente col sysroot toolchain
export PKG_CONFIG="${TOOLCHAIN}/bin/pkg-config"
export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"
export PKG_CONFIG_LIBDIR="${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig:${SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${SYSROOT}/usr/share/pkgconfig"
unset PKG_CONFIG_PATH

# set fake wrapper for toolchain
cat > /usr/local/bin/aarch64-flip-linux-gnu-pkg-config <<'EOF'
#!/bin/sh
export PKG_CONFIG_SYSROOT_DIR="${PKG_CONFIG_SYSROOT_DIR}"
export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}"
exec /opt/flip/bin/pkg-config "$@"
EOF
chmod +x /usr/local/bin/aarch64-flip-linux-gnu-pkg-config

exec "$@"

