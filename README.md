[![Deploy](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml/badge.svg)](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml)

# zeebo-sdk

Linux/amd64 image with a Zeebo (Tectoy) homebrew toolchain: `armeb-none-eabi` GCC, Ubuntu `arm-none-eabi`, and Qualcomm `elf2mod.exe` under Wine.

## Use

```bash
docker pull hldtux/zeebo-sdk
docker run --rm -it -v "$PWD":/src hldtux/zeebo-sdk
```

The toolchain is on `PATH` under `/opt/zeebo`. `elf2mod.exe` is at `/opt/brew-toolset/bin/elf2mod.exe`.

## Build locally

```bash
docker build --platform linux/amd64 -t zeebo-sdk .
```

Optional Wine-only image (the default image already includes Wine and `elf2mod.exe`):

```bash
docker build --platform linux/amd64 -t zeebo-sdk-wine -f Dockerfile.wine .
```

## Docker Hub

Pushes to `main` run [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml), which builds `linux/amd64` and pushes `hldtux/zeebo-sdk`.

Repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (Docker Hub access token)
