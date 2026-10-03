[![Deploy](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml/badge.svg)](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml)

# zeebo-sdk

Linux/amd64 image with a Zeebo (Tectoy) homebrew toolchain: `armeb-none-eabi` GCC, Ubuntu `arm-none-eabi` and Qualcomm `elf2mod.exe` under Wine.

## Use

```bash
docker pull hldtux/zeebo-sdk
docker run --rm -it -v "$PWD":/src hldtux/zeebo-sdk
```

The toolchain is on `PATH` under `/opt/zeebo`. `elf2mod.exe` is at `/opt/brew-toolset/bin/elf2mod.exe`.
