[![Deploy](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml/badge.svg)](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/hldtux/docker-zeebo-sdk.svg?logo=docker)](https://hub.docker.com/r/hldtux/docker-zeebo-sdk)


# zeebo-sdk

Linux/amd64 image with a Zeebo homebrew toolchain: `armeb-none-eabi` GCC, Ubuntu `arm-none-eabi` and Qualcomm `elf2mod.exe` under Wine.

## Use

```bash
docker run --rm -it -v "$PWD":/src hldtux/zeebo-sdk
```

The toolchain is on `PATH` under `/opt/zeebo`. `elf2mod.exe` and `cifc.exe` are under `/opt/brew-toolset/bin`.

The Qualcomm BREW 4.0.2 headers are not in the image. On startup the container warns until you mount your own SDK at `/opt/brew` (`inc/` and `sdk/`, `BREWDIR=/opt/brew/sdk`). How to unpack the installer into `sdk/brew` is in [SDK.md](SDK.md).

```bash
docker run --rm -it -v "$PWD":/src -v /path/to/brew:/opt/brew hldtux/zeebo-sdk
```

## Example

[`examples/hello`](examples/hello) paints the screen black and draws **Hello World from Zeebo** in white, centered. What each file is for is in [`examples/hello/README.md`](examples/hello/README.md).

```bash
make -C examples/hello
```

Running on [zeebx-emu](https://github.com/ZeebxTeam/zeebx-emu)

<img width="1920" height="543" alt="image" src="https://github.com/user-attachments/assets/cfbe1288-7446-43e5-9508-5654afeccc4f" />

<img width="1089" height="715" alt="image" src="https://github.com/user-attachments/assets/84bcd570-4bad-496b-9952-8f846cfaab82" />

