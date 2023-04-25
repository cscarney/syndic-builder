FROM ubuntu:rolling AS buildkde

RUN apt-get update && \
    apt-get install -y git libyaml-libyaml-perl libio-socket-ssl-perl cmake make libc6-dev gcc g++ bzip2 qmake6 qt6-base-dev qt6-base-private-dev qt6-declarative-dev qt6-svg-dev qt6-shadertools-dev qt6-5compat-dev qt6-tools-dev libxkbcommon-dev gperf

COPY kdesrc-buildrc.syndicdeps /opt/kdesrc-buildrc.syndicdeps

ENV PATH=/usr/lib/qt6/bin:/opt/kde/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && git clone --depth=1 https://invent.kde.org/sdk/kdesrc-build.git && \
    kdesrc-build/kdesrc-build --rc=/opt/kdesrc-buildrc.syndicdeps

RUN cd /opt && git clone --depth=1 https://invent.kde.org/ccarney/qreadable.git && \
    mkdir qreadable-build && cd qreadable-build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/kde/usr ../qreadable && \
    make && make install

FROM ubuntu:rolling

RUN apt-get update && \
    apt-get install --no-install-recommends -y git ca-certificates cmake make clang qt6-base-dev-tools qt6-base-dev qt6-declarative-dev qt6-l10n-tools qt6-tools-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=buildkde /opt/kde /opt/kde

CMD /bin/bash
