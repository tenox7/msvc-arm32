# msvc-arm32

Microsoft C/C++ (MSVC 14.44, Visual Studio 2022 17.14) for 32-bit ARM Windows (Thumb-2), under Wine. It runs natively on arm64 (Apple Silicon) and on amd64. 14.44 is the last MSVC with an ARM32 target.

The image contains no Microsoft software. `msvc-setup` downloads MSVC, its ARM32 libraries and the ARM32 Windows 10 SDK from Microsoft into a volume.

## Install

    docker run --rm -e ACCEPT_MSVC_LICENSE=yes -v msvc-arm32:/opt/msvc tenox7/msvc-arm32 msvc-setup

`ACCEPT_MSVC_LICENSE=yes` accepts the [Visual Studio Build Tools license](https://go.microsoft.com/fwlink/?LinkId=2179911). `SDK=0` skips the Windows SDK.

## Use

    docker run --rm -v msvc-arm32:/opt/msvc -v "$PWD":/src tenox7/msvc-arm32 cl hello.c

Tools: `cl link lib dumpbin editbin armasm cvtres nmake undname rc mt`, plus `clang` (`--target=thumbv7-pc-windows-msvc`) and `lldb` (reads PDB). `INCLUDE` and `LIB` point at MSVC and the SDK; `MSVC_ENV=0` leaves them unset. Paths are relative to `/src` or absolute.

## Backup and mirror

    docker run --rm -e ACCEPT_MSVC_LICENSE=yes -v /path/to/backup:/backup tenox7/msvc-arm32 msvc-backup /backup

This saves every ARM32 MSVC and Windows SDK download to `/path/to/backup`, sha256 checked (1.2 GB).

    docker run --rm -e ACCEPT_MSVC_LICENSE=yes -e MSVC_MIRROR=/backup -v /path/to/backup:/backup:ro -v msvc-arm32:/opt/msvc tenox7/msvc-arm32 msvc-setup

`MSVC_MIRROR` makes `msvc-setup` install from that backup instead of from Microsoft, with no network needed.

## Build

    docker build -t tenox7/msvc-arm32 .

`--build-arg ACCEPT_MSVC_LICENSE=yes` puts MSVC in the image, for local use only. Source: https://github.com/tenox7/msvc-arm32
