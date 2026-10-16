# MSVC 14.44 (VS 2022 17.14, the last MSVC with an ARM32 target) cross compiler for 32-bit
# ARM Windows (Thumb-2) under Wine: the arm64-hosted compiler on linux/arm64, the x64-hosted
# one on linux/amd64. The image holds no Microsoft software; msvc-setup downloads it from
# Microsoft (README.md). A local build can include it, but must not be pushed:
#   docker build --build-arg ACCEPT_MSVC_LICENSE=yes -t msvc-arm32 .
FROM debian:trixie
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wine wine64 ca-certificates curl jq unzip msitools clang lld llvm lldb make && rm -rf /var/lib/apt/lists/*
ENV WINEDEBUG=-all WINEPREFIX=/opt/wine XDG_RUNTIME_DIR=/run/xdg
RUN mkdir -m 700 /run/xdg && wine wineboot --init && wineserver -w
COPY msvc-setup msvc-backup fetch-msvc.sh wine-msvc entrypoint /usr/local/bin/
COPY README.md /usr/local/share/msvc-arm32/
RUN for t in cl link lib dumpbin editbin armasm cvtres nmake undname rc mt; do \
      printf '#!/bin/sh\nexec wine-msvc %s "$@"\n' $t > /usr/local/bin/$t && chmod +x /usr/local/bin/$t; done
ARG ACCEPT_MSVC_LICENSE=
RUN [ "$ACCEPT_MSVC_LICENSE" != yes ] || msvc-setup
WORKDIR /src
ENTRYPOINT ["entrypoint"]
