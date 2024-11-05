FROM debian:bookworm

ARG DEBIAN_FRONTEND="noninteractive"
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

ENV VERSION=10.10.1+deb12
ENV NEO_VERSION=24.39.31294.12
ENV GMMLIB_VERSION=22.5.2
ENV IGC_VERSION=1.0.17791.9
ENV LEVEL_ZERO_VERSION=1.6.31294.12

# install jellyfin
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests -y ca-certificates gnupg wget gnupg apt-transport-https curl && \
    wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | apt-key add -  &&\
    echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | tee /etc/apt/sources.list.d/jellyfin.list && \
    apt update && \
    apt install -y --no-install-recommends --no-install-suggests iproute2 openssl locales fonts-noto-cjk fonts-noto-cjk-extra jellyfin=${VERSION} && \
# install intel driver
    mkdir intel-compute-runtime && \
    cd intel-compute-runtime && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/libigdgmm12_${GMMLIB_VERSION}_amd64.deb && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-core_${IGC_VERSION}_amd64.deb  && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-opencl_${IGC_VERSION}_amd64.deb  && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-opencl-icd_${NEO_VERSION}_amd64.deb  && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-level-zero-gpu_${LEVEL_ZERO_VERSION}_amd64.deb  && \
    apt-get install --no-install-recommends --no-install-suggests -y ./*.deb  && \
    cd ..  && \
# clean up
    rm -rf intel-compute-runtime  && \
    apt-get remove gnupg wget apt-transport-https -y  && \
    apt-get clean autoclean -y  && \
    apt-get autoremove -y  && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    mkdir -p /cache /config /media && \
    chmod 777 /cache /config /media && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV HEALTHCHECK_URL=http://localhost:8096/health
EXPOSE 8096
VOLUME ["/cache", "/config", "/media"]
ENTRYPOINT ["/usr/bin/jellyfin", "--datadir=/config", "--cachedir=/cache", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg", "--webdir=/usr/share/jellyfin/web"]
HEALTHCHECK --start-period=10s CMD curl -Lk "${HEALTHCHECK_URL}" || exit 1
