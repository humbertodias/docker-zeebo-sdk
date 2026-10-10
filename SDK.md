# BREW SDK

The image downloads the headers while it builds. They are not committed in this repository.

Two installers are fetched from the Internet Archive:

- [BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe](https://archive.org/download/bmp-brewplatform-4.0.2.20-setup-0/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe) — BREW 4.0.2 SP19. The build keeps `BREW 4.0.2 SP19/inc` and `BREW 4.0.2 SP19/sdk`.
- [ZeeboSDKInstaller.msi](https://archive.org/download/zeebo-sdkinstaller/ZeeboSDKInstaller.msi) — Zeebo IHID extension for BREW 4.0.2. The build copies its headers, sources, and device pack into the same tree.

`sdk/inc` includes headers with the relative path `../../inc/`, so `inc` and `sdk` stay siblings. Inside the image:

```text
/opt/brew/
├── inc/                 BREW 4.0.2 SP19/inc
│   ├── AEEEvent.h
│   ├── AEEIDisplay.h
│   └── ...
├── sdk/                 BREW 4.0.2 SP19/sdk
│   ├── examples/
│   ├── inc/             AEE.h, AEEDisp.h, AEEAppGen.h, AEEIHID.h, ...
│   └── src/             AEEModGen.c, AEEAppGen.c, AEEHIDButtons.c, ...
└── devicepacks/
    └── Zeebo_Device
```

`BREWDIR` is `/opt/brew/sdk`. An applet compile uses `/opt/brew/sdk/inc/AEE.h` and `/opt/brew/sdk/src/AEEAppGen.c`. The Zeebo gamepad headers are in the same `inc/` directory, starting at `AEEIHID.h`.
