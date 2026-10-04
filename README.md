[![Deploy](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml/badge.svg)](https://github.com/humbertodias/docker-zeebo-sdk/actions/workflows/deploy.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/hldtux/zeebo-sdk.svg?logo=docker)](https://hub.docker.com/r/hldtux/zeebo-sdk)

# zeebo-sdk

Linux/amd64 image with a Zeebo homebrew toolchain.

```bash
docker run --rm -it -v "$PWD":/src hldtux/zeebo-sdk
```

The BREW headers are not in the image. If `sdk/brew` is mounted and still empty, the container downloads the installer and unpacks it. [SDK.md](SDK.md) has the details. Mount that directory to compile an applet:

```bash
docker run --rm -it -v "$PWD":/src -v "$PWD/sdk/brew":/opt/brew hldtux/zeebo-sdk
```

## Example

```bash
make -C examples/hello
```

[`examples/hello`](examples/hello) draws **Hello World from Zeebo**. It runs on [zeebx](https://github.com/ZeebxTeam/zeebx-emu).

<img width="1920" height="543" alt="image" src="https://github.com/user-attachments/assets/cfbe1288-7446-43e5-9508-5654afeccc4f" />

<img width="1089" height="715" alt="image" src="https://github.com/user-attachments/assets/84bcd570-4bad-496b-9952-8f846cfaab82" />
