# Zeebo (Tectoy) homebrew toolchain (linux/amd64 and linux/arm64).
#   docker build --platform linux/amd64 -t zeebo-sdk .
#   docker build --platform linux/arm64 -t zeebo-sdk .
#
# Toolchain only: does not clone a game repo or bake Bennu into the image.
# The console is an ARM1136 (ARMv6, soft-float) running BREW. Shipped modules
# are little-endian, so the compiler used for bgdi is Ubuntu's arm-none-eabi.
# The armeb toolchain below stays in the image from the original layer; cmake
# does not use it.
# Qualcomm elf2mod.exe is included so CI can pack an ELF into a .mod.

FROM ubuntu:22.04

ARG ZEEBO_BINUTILS_VERSION=2.42
ARG ZEEBO_GCC_VERSION=13.3.0
ARG ZEEBO_NEWLIB_VERSION=4.4.0.20231231

ENV DEBIAN_FRONTEND=noninteractive \
    PLATFORM=zeebo \
    PATH="/opt/zeebo/bin:${PATH}" \
    ZEEBO_TOOLCHAIN=/opt/zeebo

RUN apt-get update && apt-get install -y --no-install-recommends \
        bison \
        build-essential \
        ca-certificates \
        cmake \
        flex \
        git \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        ninja-build \
        pkg-config \
        python3 \
        texinfo \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && git config --system --add safe.directory '*'

RUN set -eux; \
    mkdir -p /tmp/src /opt/zeebo; \
    cd /tmp/src; \
    wget -q "https://ftp.gnu.org/gnu/binutils/binutils-${ZEEBO_BINUTILS_VERSION}.tar.xz"; \
    wget -q "https://ftp.gnu.org/gnu/gcc/gcc-${ZEEBO_GCC_VERSION}/gcc-${ZEEBO_GCC_VERSION}.tar.xz"; \
    wget -q "https://sourceware.org/pub/newlib/newlib-${ZEEBO_NEWLIB_VERSION}.tar.gz"; \
    tar -xf "binutils-${ZEEBO_BINUTILS_VERSION}.tar.xz"; \
    tar -xf "gcc-${ZEEBO_GCC_VERSION}.tar.xz"; \
    tar -xf "newlib-${ZEEBO_NEWLIB_VERSION}.tar.gz"; \
    mkdir build-binutils && cd build-binutils; \
    "../binutils-${ZEEBO_BINUTILS_VERSION}/configure" \
        --target=armeb-none-eabi \
        --prefix=/opt/zeebo \
        --disable-nls \
        --disable-werror \
        --with-sysroot=/opt/zeebo/armeb-none-eabi; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp/src; \
    mkdir build-gcc && cd build-gcc; \
    "../gcc-${ZEEBO_GCC_VERSION}/configure" \
        --target=armeb-none-eabi \
        --prefix=/opt/zeebo \
        --with-sysroot=/opt/zeebo/armeb-none-eabi \
        --with-arch=armv6 \
        --with-float=soft \
        --with-mode=arm \
        --disable-multilib \
        --disable-shared \
        --disable-nls \
        --disable-threads \
        --disable-tls \
        --disable-libssp \
        --disable-libgomp \
        --disable-libquadmath \
        --enable-languages=c,c++ \
        --with-newlib \
        --without-headers \
        --with-gnu-as \
        --with-gnu-ld; \
    make -j"$(nproc)" all-gcc all-target-libgcc; \
    make install-gcc install-target-libgcc; \
    cd /tmp/src; \
    mkdir build-newlib && cd build-newlib; \
    "../newlib-${ZEEBO_NEWLIB_VERSION}/configure" \
        --target=armeb-none-eabi \
        --prefix=/opt/zeebo \
        --enable-newlib-io-long-long \
        --enable-newlib-io-c99-formats \
        --enable-newlib-register-fini; \
    make -j"$(nproc)" CFLAGS_FOR_TARGET="-O2 -ffunction-sections -fdata-sections -march=armv6 -mtune=arm1136j-s -mfloat-abi=soft -marm"; \
    make install; \
    cd /tmp/src/build-gcc; \
    make -j"$(nproc)" all-target-libstdc++-v3; \
    make install-target-libstdc++-v3; \
    cd /; \
    rm -rf /tmp/src; \
    echo 'int main(void){return 0;}' | armeb-none-eabi-gcc -specs=nosys.specs -o /tmp/zeebo-smoke.elf -xc -; \
    armeb-none-eabi-readelf -h /tmp/zeebo-smoke.elf | grep -E 'Data:|Machine:|Flags:'; \
    rm -f /tmp/zeebo-smoke.elf; \
    chmod -R a+rX /opt/zeebo

# elf2mod.exe and cifc.exe are 32-bit Windows tools. amd64 uses wine32.
# arm64 has no i386 Wine, so it runs an x86_64 WoW64 Wine build under box64.
# Keep this layer after the toolchain so a tool update does not rebuild GCC.
ARG TARGETARCH
RUN set -eux; \
    apt-get update; \
    if [ "$TARGETARCH" = "amd64" ]; then \
        dpkg --add-architecture i386; \
        apt-get update; \
        wine_pkgs="wine wine32"; \
    else \
        wine_pkgs=""; \
    fi; \
    apt-get install -y --no-install-recommends \
        $wine_pkgs gcc-arm-none-eabi libnewlib-arm-none-eabi p7zip-full msitools \
    && rm -rf /var/lib/apt/lists/* \
    && if [ "$TARGETARCH" != "amd64" ]; then \
        git clone --depth 1 --branch v0.4.4 https://github.com/ptitSeb/box64 /tmp/box64; \
        cmake -S /tmp/box64 -B /tmp/box64/build -DCMAKE_BUILD_TYPE=RelWithDebInfo; \
        cmake --build /tmp/box64/build -j"$(nproc)"; \
        cmake --install /tmp/box64/build; \
        rm -rf /tmp/box64; \
        wget -O /tmp/wine.tar.xz --tries=8 --timeout=60 --waitretry=15 \
            "https://github.com/Kron4ek/Wine-Builds/releases/download/11.19/wine-11.19-amd64-wow64.tar.xz"; \
        mkdir -p /opt/wine-amd64; \
        tar -xJf /tmp/wine.tar.xz -C /opt/wine-amd64 --strip-components=1; \
        rm -f /tmp/wine.tar.xz; \
        printf '%s\n' \
            '#!/bin/sh' \
            'export WINEDEBUG="${WINEDEBUG:--all}"' \
            'export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree,mshtml=}"' \
            'export BOX64_NOBANNER=1' \
            'export BOX64_LOG=0' \
            'exec /usr/local/bin/box64 /opt/wine-amd64/bin/wine "$@"' \
            > /usr/local/bin/wine; \
        chmod 755 /usr/local/bin/wine; \
    fi \
    && mkdir -p /opt/brew-toolset/bin/elf2mod/src/gnu /opt/zeebo/bin \
    && test -d /usr/lib/arm-none-eabi/include \
    && ln -sfn /usr/lib/arm-none-eabi /opt/zeebo/arm-none-eabi \
    && for tool in gcc g++ ar ranlib strip nm objcopy objdump readelf; do \
         ln -sfn "/usr/bin/arm-none-eabi-${tool}" "/opt/zeebo/bin/arm-none-eabi-${tool}"; \
       done \
    && echo 'int main(void){return 0;}' \
         | arm-none-eabi-gcc -marm -march=armv6 -mtune=arm1136j-s -mfloat-abi=soft \
             -specs=nosys.specs -o /tmp/zeebo-smoke.elf -xc - \
    && arm-none-eabi-readelf -h /tmp/zeebo-smoke.elf | grep -q "little endian" \
    && rm -f /tmp/zeebo-smoke.elf

COPY bin/elf2mod.exe /opt/brew-toolset/bin/elf2mod.exe
COPY bin/elf2mod/src/gnu/elf2mod.x /opt/brew-toolset/bin/elf2mod/src/gnu/elf2mod.x
COPY bin/cifc.exe /opt/brew-toolset/bin/cifc.exe
RUN chmod 755 /opt/brew-toolset/bin/elf2mod.exe /opt/brew-toolset/bin/cifc.exe

ENV WINEDEBUG=-all

# BREW 4.0.2 SP19, then the Zeebo IHID extension from ZeeboSDKInstaller.msi.
# Downloaded at build time so the image already has the headers.
ENV BREWDIR=/opt/brew/sdk
RUN set -eux; \
    fetch() { \
        wget -O "$2" \
            --tries=8 \
            --timeout=60 \
            --waitretry=15 \
            --retry-connrefused \
            --retry-on-http-error=403,429,500,502,503,504 \
            --user-agent="zeebo-sdk build (https://github.com/humbertodias/docker-zeebo-sdk)" \
            "$1"; \
        test "$(stat -c%s "$2")" -gt 1000000; \
    }; \
    brew_exe=$(mktemp); \
    zeebo_msi=$(mktemp); \
    fetch "https://archive.org/download/bmp-brewplatform-4.0.2.20-setup-0/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe" "$brew_exe"; \
    mkdir -p /opt/brew; \
    7z x "$brew_exe" -o/opt/brew \
        "BREW 4.0.2 SP19/inc" \
        "BREW 4.0.2 SP19/sdk"; \
    mv "/opt/brew/BREW 4.0.2 SP19/inc" /opt/brew/inc; \
    mv "/opt/brew/BREW 4.0.2 SP19/sdk" /opt/brew/sdk; \
    rmdir "/opt/brew/BREW 4.0.2 SP19"; \
    rm -f "$brew_exe"; \
    test -f /opt/brew/sdk/inc/AEE.h; \
    test -f /opt/brew/sdk/src/AEEAppGen.c; \
    fetch "https://archive.org/download/zeebo-sdkinstaller/ZeeboSDKInstaller.msi" "$zeebo_msi"; \
    tmp=$(mktemp -d); \
    ( cd "$tmp" && msiextract "$zeebo_msi" >/dev/null ); \
    ext="$tmp/BREW402SP09 IHID Extension Folder"; \
    packs="$tmp/BREW402SP09 Devicepacks Folder/devicepacks"; \
    test -f "$ext/sdk/inc/AEEIHID.h"; \
    cp -a "$ext/sdk/inc/." /opt/brew/sdk/inc/; \
    cp -a "$ext/sdk/src/." /opt/brew/sdk/src/; \
    mkdir -p /opt/brew/devicepacks; \
    cp -a "$packs/." /opt/brew/devicepacks/; \
    rm -rf "$tmp" "$zeebo_msi"; \
    test -f /opt/brew/sdk/inc/AEEIHID.h

WORKDIR /src
CMD ["bash"]
