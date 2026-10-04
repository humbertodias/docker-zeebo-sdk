# BREW SDK

The image does not contain the Qualcomm BREW headers. They stay on your machine, under `sdk/brew`, and are gitignored. Do not commit them.

If `/opt/brew/sdk/inc/AEE.h` is missing when the container starts, it downloads [BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe](https://archive.org/download/bmp-brewplatform-4.0.2.20-setup-0/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe) and unpacks `inc/` and `sdk/` into `/opt/brew`. Mount `sdk/brew` there if you want that copy to persist.

The BREW installer does not include the Zeebo IHID headers (`AEEIHID.h` and the files beside it). If `/opt/brew/sdk/inc/AEEIHID.h` is missing, the container also downloads [ZeeboSDKInstaller.msi](https://archive.org/download/zeebo-sdkinstaller/ZeeboSDKInstaller.msi) and copies the BREW 4.0.2 extension into the SDK:

```text
sdk/inc/          AEEIHID.h, AEEIHIDDevice.h, AEEHIDButtons.h, ...
sdk/src/          AEEHIDButtons.c, AEEHIDThumbsticks.c
devicepacks/      Zeebo_Device
```

The tree comes from the NSIS installer `BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe` (BREW 4.0.2 SP19). Only two directories inside that archive are required: `BREW 4.0.2 SP19/inc` and `BREW 4.0.2 SP19/sdk`.

From the repository root, with [7-Zip](https://www.7-zip.org/) installed:

```bash
make sdk/unzip INSTALLER=/path/to/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe
```

`sdk/inc` includes headers with the relative path `../../inc/`, so `inc` and `sdk` must stay siblings. After the move, `sdk/brew` looks like this:

```text
sdk/brew/
├── .gitkeep
├── inc/                 BREW 4.0.2 SP19/inc
│   ├── AEEEvent.h
│   ├── AEEIDisplay.h
│   └── ...
└── sdk/                 BREW 4.0.2 SP19/sdk
    ├── examples/
    ├── inc/             legacy applet API (AEE.h, AEEDisp.h, AEEAppGen.h)
    └── src/             AEEModGen.c, AEEAppGen.c
```

The container treats the SDK as present when this file exists:

```text
/opt/brew/sdk/inc/AEE.h
```

That is `sdk/brew/sdk/inc/AEE.h` in the repository. The applet build also needs `sdk/brew/sdk/src/AEEAppGen.c`.

Mount this directory when you run the image:

```bash
docker run --rm -it -v "$PWD":/src -v "$PWD/sdk/brew":/opt/brew hldtux/zeebo-sdk
```

`BREWDIR` inside the container is `/opt/brew/sdk`.
